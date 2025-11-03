% ------------------------------------------------------
% Timer Counter Example: PWM Output and Counter Input
% This example has been written to create a 3.9 kHz PWM output
% over FIO0 with a 50% duty cycle. It also enables Counter0 over FIO1.
% Jumper a wire from FIO0 to FIO1 and run the program from
% the command window. Counter should return roughly 7812 counts
% for a U3 version 1.21.  Counter should return roughly 3906 counts
% for a U3 version 1.20.
% ------------------------------------------------------

clc %clear the MATLAB command window
clear global % Clears MATLAB global variables

ljud_LoadDriver; % Loads LabJack UD Function Library
ljud_Constants; % Loads LabJack UD constant file
[Error ljHandle] = ljud_OpenLabJack(LJ_dtU3,LJ_ctUSB,'1',1); % Returns ljHandle for open LabJack
Error_Message(Error)

%Start by using the pin_configuration_reset IOType so that all
%pin assignments are in the factory default condition.
Error = ljud_ePut (ljHandle, LJ_ioPIN_CONFIGURATION_RESET, 0, 0, 0);
Error_Message(Error) % Checks for errors and displays them if they occur

%Set the pin offset for the timers and counters on the U3
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_CONFIG,LJ_chTIMER_COUNTER_PIN_OFFSET,4,0,0);
Error_Message(Error)

% Configure the U3's timer clock to 48 MHz 
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_CONFIG,LJ_chTIMER_CLOCK_CONFIG,LJ_tc48MHZ_DIV,0,0);
Error_Message(Error)
%Call this command for a U3 Hardware version 1.20
%Error = ljud_AddRequest(ljHandle,LJ_ioPUT_CONFIG,LJ_chTIMER_CLOCK_CONFIG,LJ_tc24MHZ_DIV,0,0);


% Configure the U3's timer clock to be divided by 24
% Resulting timer clock is 1 MHz.
% Frequency =  2 MHz / (256 * 24) = 7.812 kHz
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_CONFIG,LJ_chTIMER_CLOCK_DIVISOR,24,0,0); 
Error_Message(Error)

Error = ljud_AddRequest(ljHandle,LJ_ioPUT_CONFIG,LJ_chNUMBER_TIMERS_ENABLED,1,0,0); % Enable 1 timer.
Error_Message(Error)

Error = ljud_AddRequest(ljHandle,LJ_ioPUT_TIMER_MODE,0,LJ_tmPWM8,0,0); % Timer set to 8-bit PWM.
Error_Message(Error)

Error = ljud_AddRequest(ljHandle,LJ_ioPUT_TIMER_VALUE,0,32768,0,0); % Timer Duty Cycle = 50%.
Error_Message(Error)

Error = ljud_AddRequest(ljHandle,LJ_ioPUT_COUNTER_ENABLE,1,1,0,0); % Enable Counter1.
Error_Message(Error)

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

pause (1) % Pause for 1 second


[Error Counter1] = ljud_eGet(ljHandle,LJ_ioGET_COUNTER,1,0,0); % Get Counter1 Reading
Counter1

%Disable Timer      
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_CONFIG,LJ_chNUMBER_TIMERS_ENABLED,0,0,0);
Error_Message(Error)

%Disable Counter
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_COUNTER_ENABLE,0,0,0,0);
Error_Message(Error)

Error = ljud_GoOne(ljHandle);
Error_Message(Error)