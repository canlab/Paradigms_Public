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
[Error ljHandle] = ljud_OpenLabJack(LJ_dtUE9,LJ_ctUSB,'1',1); % Returns ljHandle for open LabJack
Error_Message(Error)

% 750 kHz Clock
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_CONFIG,LJ_chTIMER_CLOCK_BASE,0,0,0);
Error_Message(Error)

% Frequency = 750 kHz / (256 * 3) = 977 Hz
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_CONFIG,LJ_chTIMER_CLOCK_DIVISOR,3,0,0);
Error_Message(Error)

% Enable 1 Timer
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_CONFIG,LJ_chNUMBER_TIMERS_ENABLED,1,0,0);
Error_Message(Error)


% Timer Mode 1: 8-bit PWM
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_TIMER_MODE,0,1,0,0);
Error_Message(Error)


% Duty Cycle = ((256 - 32768/256)/256)*100% = 50%
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_TIMER_VALUE,0,32768,0,0);
Error_Message(Error)

% Enable Counter0
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_COUNTER_ENABLE,0,1,0,0); 
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
[Error Counter] = ljud_eGet(ljHandle,LJ_ioGET_COUNTER,0,0,0); 
Error_Message(Error)

Counter % Display Counter value

% Disable Timers
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_CONFIG,LJ_chNUMBER_TIMERS_ENABLED,0,0,0);
Error_Message(Error)

%Disable Counters
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_COUNTER_ENABLE,0,0,0,0);
Error_Message(Error)

% Execute above requests
Error = ljud_GoOne(ljHandle);
Error_Message(Error)
