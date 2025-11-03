%
% Demonstrates talking to a EI-1050 probes using MATLAB, .NET and the UD
% driver.
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

    % Open the first found LabJack U3.
    [ljerror, ljhandle] = ljudObj.OpenLabJackS('LJ_dtU3', 'LJ_ctUSB', '0', true, 0);

    % Start by using the pin_configuration_reset IOType so that all pin
    % assignments are in the factory default condition.
    ljudObj.ePutS(ljhandle, 'LJ_ioPIN_CONFIGURATION_RESET', 0, 0, 0);

    % Set the Data line to FIO4, which is the default anyway.
    ljudObj.ePutSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chSHT_DATA_CHANNEL', 4, 0);

    % Set the Clock line to FIO5, which is the default anyway.
    ljudObj.ePutSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chSHT_CLOCK_CHANNEL', 5, 0);

    % Set FIO6 to output-high to provide power to the EI-1050.
    ljudObj.ePutS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', 6, 1, 0);

    % Connections for probe:
    %     Red (Power)         FIO6
    %     Black (Ground)      GND
    %     Green (Data)        FIO4
    %     White (Clock)       FIO5
    %     Brown (Enable)      FIO6

    % Now, an add/go/get block to get the temp & humidity at the same time.
    % Request a temperature reading from the EI-1050.
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioSHT_GET_READING', 'LJ_chSHT_TEMP', 0, 0, 0);

    % Request a humidity reading from the EI-1050.
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioSHT_GET_READING', 'LJ_chSHT_RH', 0, 0, 0);

    % Execute the requests.  Will take about 0.5 seconds with a USB high-high or
    % Ethernet connection, and about 1.5 seconds with a normal USB connection.
    ljudObj.GoOne(ljhandle);

    % Get the temperature reading.
    [ljerror, dblValue] = ljudObj.GetResultSS(ljhandle, 'LJ_ioSHT_GET_READING', 'LJ_chSHT_TEMP', 0);
    disp(['Temp Probe A = ' num2str(dblValue) ' deg K']);
    disp(['Temp Probe A = ' num2str((dblValue-273.15)) ' deg C']);
    disp(['Temp Probe A = ' num2str((((dblValue-273.15)*1.8)+32)) ' deg F']);

    % Get the humidity reading.
    [ljuderror, dblValue] = ljudObj.GetResultSS(ljhandle, 'LJ_ioSHT_GET_READING', 'LJ_chSHT_RH', 0);
    disp(['RH Probe A = ' num2str(dblValue) ' percent']);
catch e
    showErrorMessage(e)
end
