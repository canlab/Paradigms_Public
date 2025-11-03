% Call the ljud_eAddGoGet function from the MATLAB command window or any other
% mfile. To call the function use the following notation:
%
% [Error] = ljud_eAddGoGet(Parameters)
%
% Error should be returned as a zero. 
% See Section 3.4 of the LabJackUD_Driver_For_Windows.pdf for more
% information on the eAddGoGet function and the required paramters.

function [ljError] = ljud_eAddGoGet(Handle, NumRequests, aIOTypes, aChannels, aValues, ax1s, aRequestErrors, GoError, aResultErrors)
[ljError] = calllib('labjackud','eAddGoGet',Handle,NumRequests,aIOTypes,aChannels,aValues,ax1s,aRequestErrors,GoError,aResultErrors);
