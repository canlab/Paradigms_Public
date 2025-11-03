% Call the eTCValues function from the MATLAB command window or any other
% mfile. To call the function use the following notation:
%
% [Error] = ljud_eTCValues(Parameters)
%
% Error should be returned as a zero. 
% See Section 3.4 of the LabJackUD_Driver_For_Windows.pdf for more
% information on the eTCValues function and the required paramters.

function [ljError] = ljud_eTCConfig(Handle, aReadTimers, aUpdateResetTimers, aReadCounters, aResetCounters, aTimerValues, aCounterValues, Reserved1, Reserved2)
[ljError] = calllib('labjackud','eTCValues',Handle, aReadTimers, aUpdateResetTimers, aReadCounters, aResetCounters, aTimerValues, aCounterValues, Reserved1, Reserved2)
