% ------------------------------------------------------
% SHT Example: Using EI-1050 to take Temperature and Humidity Measurements
% This example has been written to use the UE9 to read the EI-1050's
% temperature and humidity measurements. Refer to
% http://labjack.com/support/datasheets/ei-1050-sample-windows
% for the wiring configuration of the EI-1050 with the UE9.
%
% FIO0: Data
% FIO1: Clock
% FIO2: Power / Enable
% ------------------------------------------------------

clc %clear the MATLAB command window
clear global %Clears MATLAB global variables

ljud_LoadDriver; % Loads LabJack UD Function Library
ljud_Constants; % Loads LabJack UD constant file

% Returns ljHandle for open LabJack
[Error ljHandle] = ljud_OpenLabJack(LJ_dtUE9,LJ_ctUSB,'1',1); 
Error_Message(Error) % Check for and display any Errors

% Set FIO0 as the data channel for the SHT probe
Error = ljud_AddRequest(ljHandle,LJ_ioSHT_DATA_CHANNEL,0,0,0,0);
Error_Message(Error)

% Set FIO1 as the clock channel for the SHT probe
Error = ljud_AddRequest(ljHandle,LJ_ioSHT_CLOCK_CHANNEL,1,0,0,0);
Error_Message(Error)

% Set FIO2 to Digital High to Provide 3.3 Volts to Power Probe
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_DIGITAL_BIT,2,1,0,0);
Error_Message(Error)

% Set FIO3 to Digital Low to disable Probe
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_DIGITAL_BIT,3,0,0,0);
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

% Set FIO3 to Digital High to Enable Probe
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_DIGITAL_BIT,3,1,0,0);
Error_Message(Error)

% Execute above request
Error = ljud_GoOne(ljHandle);
Error_Message(Error)

pause (1) %Pause program for 1 second

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

% Set FIO3 to Digital Low to disable Probe
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_DIGITAL_BIT,3,0,0,0);
Error_Message(Error)

% Execute above requests
Error = ljud_GoOne(ljHandle);
Error_Message(Error)