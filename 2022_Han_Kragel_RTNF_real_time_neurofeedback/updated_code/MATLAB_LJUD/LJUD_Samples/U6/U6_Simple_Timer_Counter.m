% ------------------------------------------------------
% Timer Counter Example: PWM Output and Counter Input
% This example has been written to create a 977 Hz PWM output
% over FIO0 with a 50% duty cycle. It also enables Counter0 over FIO1.
% Jumper a wire from FIO0 to FIO1 and run the program from
% the command window. Counter should return at roughly 977.
% ------------------------------------------------------

clc %clear the MATLAB command window
clear global %Clears MATLAB global variables

ljud_LoadDriver; % Loads LabJack UD Function Library
ljud_Constants; % Loads LabJack UD constant file
Counter = 0;
[Error ljHandle] = ljud_OpenLabJack(LJ_dtU6,LJ_ctUSB,'1',1); % Returns ljHandle for open LabJack
Error_Message(Error)

% Reset Labjack
Error = ljud_ePut(ljHandle, LJ_ioPIN_CONFIGURATION_RESET, 0, 0, 0);
Error_Message(Error)

% Set the timer/counter pin offset to 0, which will put the first
% timer/counter on FIO0
Error = ljud_AddRequest(ljHandle, LJ_ioPUT_CONFIG, LJ_chTIMER_COUNTER_PIN_OFFSET, 0, 0, 0);
Error_Message(Error)

% 48 MHz Clock
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_CONFIG,LJ_chTIMER_CLOCK_BASE,LJ_tc48MHZ_DIV,0,0);
Error_Message(Error)

% Frequency = 1 MHz
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_CONFIG,LJ_chTIMER_CLOCK_DIVISOR,48,0,0);
Error_Message(Error)

% Enable 1 Timer
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_CONFIG,LJ_chNUMBER_TIMERS_ENABLED,1,0,0);
Error_Message(Error)

% Timer Mode 1: 8-bit PWM
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_TIMER_MODE,0,LJ_tmPWM8,0,0);
Error_Message(Error)

% Duty Cycle = ((256 - 32768/256)/256)*100% = 50%
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_TIMER_VALUE,0,32768,0,0);
Error_Message(Error)

% Enable Counter1
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_COUNTER_ENABLE,1,1,0,0); 
Error_Message(Error)

% Execute above requests
Error = ljud_GoOne(ljHandle);
Error_Message(Error)

% Get all results just to check for errors
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

pause (1) % Pause program for 1 second

% Get Counter Reading
[Error Counter] = ljud_eGet(ljHandle,LJ_ioGET_COUNTER,1,Counter,0); 
Error_Message(Error)

Counter % Display Counter value
