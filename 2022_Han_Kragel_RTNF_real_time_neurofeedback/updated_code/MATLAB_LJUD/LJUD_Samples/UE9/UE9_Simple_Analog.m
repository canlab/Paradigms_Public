% -------------------------------------------------
% Simple Analog In
% This file calls the eGet function and returns the
% analog voltage from AIN0 on the UE9. It also checks for 
% errors for each request. If an Error is detected the error
% code is displayed rather than the AIN0 voltage value.
% Error = 0 means no errors.
% -------------------------------------------------

clc %clear the MATLAB command window
clear global %Clears MATLAB global variables

ljud_LoadDriver; % Loads LabJack UD Function Library
ljud_Constants; % Loads LabJack UD constant file
[Error ljHandle] = ljud_OpenLabJack(LJ_dtUE9,LJ_ctUSB,'1',1); % Returns ljHandle for open LabJack
Error_Message(Error) % Check for and display any Errors

% Set Device Resolution to 17. Greater than 16 equals max resolution
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_CONFIG,LJ_chAIN_RESOLUTION,17,0,0);
Error_Message(Error)

% Set Device Voltage Range to Unipolar 0-5 volts.
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_AIN_RANGE,0,LJ_rgUNI5V,0,0);
Error_Message(Error)

% Call AddRequest/GoOne/GetResult function to get AIN0 voltage value.
Error = ljud_AddRequest(ljHandle,LJ_ioGET_AIN,0,0,0,0);
Error_Message(Error)

% Execute above request
Error = ljud_GoOne(ljHandle);
Error_Message(Error)

% Get all results to check for errors
Error = ljud_GetFirstResult(ljHandle,0,0,0,0,0);
Error_Message (Error)

% Run while loop until Error 1006 is returned to ensure that the device has
% fully configured its channels before continuing.
while (Error ~= 1006) % 1006 Equates to LJE_NO_MORE_DATA_AVAILABLE
    Error = ljud_GetNextResult(ljHandle,0,0,0,0,0);
    if ((Error ~= 0) && (Error ~= 1006))
        Error_Message (Error)
        break
    end
end 

% Get AIN0's value
[Error AIN0] = ljud_GetResult(ljHandle,LJ_ioGET_AIN,0,0);
Error_Message(Error)
% Note that the three above statements could have been completed in one
% eGet statement with the following notation.
% [Error AIN0] = eGet(ljHandle,LJ_ioGET_AIN,0,0,0)

AIN0 % Display AIN0
