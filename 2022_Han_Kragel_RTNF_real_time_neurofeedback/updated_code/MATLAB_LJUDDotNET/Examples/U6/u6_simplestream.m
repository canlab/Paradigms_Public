%
% 2 channel stream of AIN0 and AIN1 example using MATLAB, .NET and the UD
% driver.
%
% support@labjack.com
%

clc  % Clear the MATLAB command window
clear  % Clear the MATLAB variables

% Make the UD .NET assembly visible in MATLAB.
ljasm = NET.addAssembly('LJUDDotNet');
ljudObj = LabJack.LabJackUD.LJUD;

i = 0;
k = 0;
ioType = 0;
channel = 0;
dblValue = 0;
dblCommBacklog = 0;
dblUDBacklog = 0;
scanRate = 2000;
numScans = 1000;
numScansRequested = 0;
loopAmount = 10;  % Number of times to loop and read stream data
% Variables to satisfy certain method signatures
dummyInt = 0;
dummyDouble = 0;
dummyDoubleArray = [0];

try
    % Read and display the UD version.
    disp(['UD Driver Version = ' num2str(ljudObj.GetDriverVersion())])

    % Open the first found LabJack U6.
    [ljerror, ljhandle] = ljudObj.OpenLabJackS('LJ_dtU6', 'LJ_ctUSB', '0', true, 0);

    % Stop any previous stream.
    try
        ljudObj.eGet(ljhandle, 'LJ_ioSTOP_STREAM', 0, 0, 0);
    catch
    end

    % Configure the resolution of the analog inputs (pass a non-zero value for quick sampling).
    % See section 2.6 / 3.1 for more information.
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chAIN_RESOLUTION', 0, 0, 0);

    % Configure the analog input range on channel 0 for bipolar +-10 volts (LJ_rgBIP10V).
    LJ_rgBIP10V = ljudObj.StringToConstant('LJ_rgBIP10V');
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_AIN_RANGE', 0, LJ_rgBIP10V, 0, 0);

    % Set the scan rate.
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chSTREAM_SCAN_FREQUENCY', scanRate, 0, 0);

    % Give the driver a 5 second buffer (scanRate * 2 channels * 5 seconds).
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chSTREAM_BUFFER_SIZE', scanRate*2*5, 0, 0);

    % Configure reads to retrieve whatever data is available with waiting.
    LJ_swSLEEP = ljudObj.StringToConstant('LJ_swSLEEP');
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chSTREAM_WAIT_MODE', LJ_swSLEEP, 0, 0);

    % Define the scan list as AIN0 then AIN1.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioCLEAR_STREAM_CHANNELS', 0, 0, 0, 0);
    ljudObj.AddRequestS(ljhandle, 'LJ_ioADD_STREAM_CHANNEL', 0, 0, 0, 0);
    ljudObj.AddRequestS(ljhandle, 'LJ_ioADD_STREAM_CHANNEL', 1, 0, 0, 0);

    % Execute the list of requests.
    ljudObj.GoOne(ljhandle);

    % Get all the results just to check for errors.
    LJE_NO_MORE_DATA_AVAILABLE = ljudObj.StringToConstant('LJE_NO_MORE_DATA_AVAILABLE');
    finished = false;
    while finished == false
        try
            [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetNextResult(ljhandle, 0, 0, 0, 0, 0);
        catch e
            if(isa(e, 'NET.NetException'))
                eNet = e.ExceptionObject;
                if(isa(eNet, 'LabJack.LabJackUD.LabJackUDException'))
                    % If we get an error, report it. If the error is
                    % LJE_NO_MORE_DATA_AVAILABLE we are done.
                    if(int32(eNet.LJUDError) == LJE_NO_MORE_DATA_AVAILABLE)
                        finished = true;
                    end
                end
            end
            % Report non NO_MORE_DATA_AVAILABLE error.
            if(finished == false)
                throw(e)
            end
        end
    end

    % Start the stream.
    [ljerror, dblValue] = ljudObj.eGetS(ljhandle, 'LJ_ioSTART_STREAM', 0, 0, 0);

    % The actual scan rate is dependent on how the desired scan rate divides into
    % the LabJack clock.  The actual scan rate is returned in the value parameter
    % from the start stream command.
    disp(['Actual Scan Rate = ' num2str(dblValue)])
    disp(['Actual Sample Rate = ' num2str(2*dblValue) sprintf('\n')]) % # channels * scan rate

    % Get the enums for LJ_ioGET_STREAM_DATA and LJ_chALL_CHANNELS which we use
    % in the read stream data loop.
    typeIO = ljasm.AssemblyHandle.GetType('LabJack.LabJackUD.LJUD+IO');
    LJ_ioGET_STREAM_DATA = typeIO.GetEnumValues.Get(22);  % Use enum index for GET_STREAM_DATA 
    typeCHANNEL = ljasm.AssemblyHandle.GetType('LabJack.LabJackUD.LJUD+CHANNEL');
    LJ_chALL_CHANNELS = typeCHANNEL.GetEnumValues.Get(99);  % Use the enum index for ALL_CHANNELS

    % Read stream data
    for i=1:loopAmount
        % Loop will run the number of times specified by loopAmount variable
        % Since we are using wait mode LJ_swSLEEP, the stream read waits for a
        % certain number of scans and control how fast the program loops.

        % Init array to store data.
        adblData = NET.createArray('System.Double', 2*numScans);  %Max buffer size (#channels*numScansRequested)

        % Read the data. The array we pass must be sized to hold enough SAMPLES,
        % and the Value we pass specifies the number of SCANS to read.
        numScansRequested = numScans;
        % Use eGetPtr when reading arrays in 64-bit MATLAB. Also compatible with
        % 32-bits.
        [ljerror, numScansRequested] = ljudObj.eGetPtr(ljhandle, LJ_ioGET_STREAM_DATA, LJ_chALL_CHANNELS, numScansRequested, adblData);

        % Display the number of scans that were actually read.
        disp(['Iteration # = ' num2str(i)])
        disp(['Number read = ' num2str(numScansRequested)])

        % Display the first scan.
        disp(['First scan = ' num2str(adblData(1)) ', ' num2str(adblData(2))])

        % Retrieve the current backlog. The UD driver retrieves stream data
        % from the U6 in the background, but if the computer or code is too slow
        % the driver might not be able to read the data as fast as the U6 is
        % acquiring it, and thus there will be data left over in the U6 buffer.
        [ljerror, dblCommBacklog] = ljudObj.eGetSS(ljhandle, 'LJ_ioGET_CONFIG', 'LJ_chSTREAM_BACKLOG_COMM', dblCommBacklog, dummyDoubleArray);
        disp(['Comm Backlog = ' num2str(dblCommBacklog)])

        [ljerror, dblUDBacklog] = ljudObj.eGetSS(ljhandle, 'LJ_ioGET_CONFIG', 'LJ_chSTREAM_BACKLOG_UD', dblUDBacklog, dummyDoubleArray);
        disp(['UD Backlog = ' num2str(dblUDBacklog) sprintf('\n')])
    end

    % Stop the stream
    ljudObj.eGetS(ljhandle, 'LJ_ioSTOP_STREAM', 0, 0, 0);

    disp('Done')
catch e
    showErrorMessage(e)
end
