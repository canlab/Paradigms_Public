% -------------------------------------------------------------------------
% SHT Example: Using EI-1050 to take Temperature and Humidity Measurements
% This example has been written to use the U3 to read the EI-1050's
% temperature and humidity measurements. Refer to
% http://labjack.com/support/datasheets/ei-1050-sample-windows
% for the wiring configuration of the EI-1050 with the U3.
% FIO4: Power / Enable
% FIO5: Clock
% FIO6: Data
% -------------------------------------------------------------------------

clc %clear the MATLAB command window
clear global %Clears MATLAB global variables

ljud_LoadDriver; % Loads LabJack UD Function Library
ljud_Constants; % Loads LabJack UD constant file

% Returns ljHandle for open LabJack
[Error ljHandle] = ljud_OpenLabJack(LJ_dtU3,LJ_ctUSB,'1',1); 
Error_Message(Error) % Check for and display any Errors

%Start by using the pin_configuration_reset IOType so that all
%pin assignments are in the factory default condition.
Error = ljud_ePut (ljHandle, LJ_ioPIN_CONFIGURATION_RESET, 0, 0, 0);
Error_Message(Error)

% Set FIO6 as the data channel for the SHT probe
Error = ljud_AddRequest(ljHandle,LJ_ioSHT_DATA_CHANNEL,6,0,0,0);
Error_Message(Error)

% Execute above requests
Error = ljud_GoOne(ljHandle);
Error_Message(Error)

% Set FIO5 as the clock channel for the SHT probe
Error = ljud_AddRequest(ljHandle,LJ_ioSHT_CLOCK_CHANNEL,5,0,0,0);
Error_Message(Error)

% Set FIO4 to Digital High to Provide 3.3 Volts to Power Probe
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_DIGITAL_BIT,4,1,0,0);
Error_Message(Error)

% Set FIO4 to Digital Low to disable Probe
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_DIGITAL_BIT,4,0,0,0);
Error_Message(Error)

% Execute above requests
Error = ljud_GoOne(ljHandle);
Error_Message(Error)

% Get all results just to check for errors
Error = ljud_GetFirstResult(ljHandle,0,0,0,0,0);
Error_Message(Error)

% Run while loop until Error 1006 is returned to ensure that the device has
% fully configured its channels before continuing.
while (Error ~= 1006) % 1006 Equates to LJE_NO_MORE_DATA_AVAILABLE
    Error = ljud_GetNextResult(ljHandle,0,0,0,0,0);
    if ((Error ~= 0) && (Error ~= 1006))
        Error_Message (Error)
        break
    end
end 

% Set FIO4 to Digital High to Enable Probe
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_DIGITAL_BIT,4,1,0,0);
Error_Message(Error)

% Execute above request
Error = ljud_GoOne(ljHandle);
Error_Message(Error)

pause (1) % Pause program for 1 second

% Get Temp data from probe 
[Error TemperatureK] = ljud_eGet(ljHandle,LJ_ioSHT_GET_READING,LJ_chSHT_TEMP,0,0);
Error_Message(Error)
TemperatureK %Display Temperature in Kelvin
% Display Temperature in Fahrenheit
TemperatureF = (TemperatureK - 273)*1.8 + 32  

% Get Temp data from probe
[Error RH] = ljud_eGet(ljHandle,LJ_ioSHT_GET_READING,LJ_chSHT_RH,0,0);
Error_Message(Error)
RH % Diplay The Relative Humidity

% Set FIO4 to Digital Low to disable Probe
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_DIGITAL_BIT,4,0,0,0);
Error_Message(Error)

% Execute above requests
Error = ljud_GoOne(ljHandle);
Error_Message(Error)