% Call the eTCConfig function from the MATLAB command window or any other
% mfile. To call the function use the following notation:
%
% [Error] = ljud_eTCConfig(Parameters)
%
% Error should be returned as a zero. 
% See Section 3.4 of the LabJackUD_Driver_For_Windows.pdf for more
% information on the eTCConfig function and the required paramters.

function [ljError] = ljud_eTCConfig(Handle, aEnableTimers, aEnableCounters, TCPinOffset, TimerClockBaseIndex, TimerClockDivisor, aTimerModes, aTimerValues, Reserved1, Reserved2)
[ljError] = calllib('labjackud','eTCConfig',Handle, aEnableTimers, aEnableCounters, TCPinOffset, TimerClockBaseIndex, TimerClockDivisor, aTimerModes, aTimerValues, Reserved1, Reserved2)
