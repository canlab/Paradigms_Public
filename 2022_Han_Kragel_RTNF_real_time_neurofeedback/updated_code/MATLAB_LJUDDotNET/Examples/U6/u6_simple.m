%
% Basic command/response example using the MATLAB, .NET and the UD driver.
%
% support@labjack.com
%

clc  % Clear the MATLAB command window
clear  % Clear the MATLAB variables

% Make the UD .NET assembly visible in MATLAB.
ljasm = NET.addAssembly('LJUDDotNet');
ljudObj = LabJack.LabJackUD.LJUD;

try
    % Read and display the UD version.
    disp(['UD Driver Version = ' num2str(ljudObj.GetDriverVersion())])

    % Open the first found LabJack U6.
    [ljerror, ljhandle] = ljudObj.OpenLabJackS('LJ_dtU6', 'LJ_ctUSB', '0', true, 0);

    % First some configuration commands.  These will be done with the ePut
    % function which combines the add/go/get into a single call.

    % Configure the resolution of the analog inputs (pass a non-zero value for
    % quick sampling). See section 2.6 / 3.1 for more information.
    ljudObj.ePutSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chAIN_RESOLUTION', 0, 0);

    % Configure the analog input range on channels 2 and 3 for
    % bipolar 10v (LJ_rgBIP10V = 2).
    LJ_rgBIP10V = ljudObj.StringToConstant('LJ_rgBIP10V');
    ljudObj.ePutS(ljhandle, 'LJ_ioPUT_AIN_RANGE', 2, LJ_rgBIP10V, 0);
    ljudObj.ePutS(ljhandle, 'LJ_ioPUT_AIN_RANGE', 3, LJ_rgBIP10V, 0);

    % Enable Counter0 which will appear on FIO0 (assuming no other program has
    % enabled any timers or Counter1).
    ljudObj.ePutS(ljhandle, 'LJ_ioPUT_COUNTER_ENABLE', 0, 1, 0);

    % Now we add requests to write and read I/O.  These requests
    % will be processed repeatedly by go/get statements in every
    % iteration of the while loop below.

    % Request AIN2 and AIN3.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioGET_AIN', 2, 0, 0, 0);

    ljudObj.AddRequestS(ljhandle, 'LJ_ioGET_AIN', 3, 0, 0, 0);

    % Set DAC0 to 2.5 volts.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DAC', 0, 2.5, 0, 0);

    % Read digital input FIO1.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioGET_DIGITAL_BIT', 1, 0, 0, 0);

    % Set digital output FIO2 to output-high.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', 2, 1, 0, 0);

    % Read digital inputs FIO3 through FIO7.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioGET_DIGITAL_PORT', 3, 0, 5, 0);

    % Request the value of Counter0.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioGET_COUNTER', 0, 0, 0, 0);

    % Constant values used in the loop.
    LJ_ioGET_AIN = ljudObj.StringToConstant('LJ_ioGET_AIN');
    LJ_ioGET_DIGITAL_BIT = ljudObj.StringToConstant('LJ_ioGET_DIGITAL_BIT');
    LJ_ioGET_DIGITAL_PORT = ljudObj.StringToConstant('LJ_ioGET_DIGITAL_PORT');
    LJ_ioGET_COUNTER = ljudObj.StringToConstant('LJ_ioGET_COUNTER');
    LJE_NO_MORE_DATA_AVAILABLE = ljudObj.StringToConstant('LJE_NO_MORE_DATA_AVAILABLE');

    requestedExit = false;
    while requestedExit == false
        % Execute the requests.
        ljudObj.GoOne(ljhandle);

        % Get all the results.  The input measurement results are stored.  All
        % other results are for configuration or output requests so we are just
        % checking whether there was an error.
        [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetFirstResult(ljhandle, 0, 0, 0, 0, 0);

        finished = false;
        while finished == false
            switch ioType
                case LJ_ioGET_AIN
                    switch int32(channel)
                        case 2
                            value2 = dblValue;
                        case 3
                            value3 = dblValue;
                    end
                case LJ_ioGET_DIGITAL_BIT
                    valueDIBit = dblValue;
                case LJ_ioGET_DIGITAL_PORT
                    valueDIPort = dblValue;
                case LJ_ioGET_COUNTER
                    valueCounter = dblValue;
            end

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
                % Report non LJE_NO_MORE_DATA_AVAILABLE error.
                if(finished == false)
                    throw(e)
                end
            end
        end
        disp(['AIN2 = ' num2str(value2)])
        disp(['AIN3 = ' num2str(value3)])
        disp(['FIO1 = ' num2str(valueDIBit)])
        disp(['FIO3-FIO7 = ' num2str(valueDIPort)]) %Will read 31 if all 5 lines are pulled-high as normal.
        disp(['Counter0 (FIO0) = ' num2str(valueCounter)])

        str = input('Press Enter to go again or (q) and then Enter to quit ','s');
        if(str == 'q')
            requestedExit = true;
        end
    end
catch e
    showErrorMessage(e)
end

