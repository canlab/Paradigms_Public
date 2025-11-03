% Call the ljud_eGet function from the MATLAB command window or any other
% mfile. To call the function use the following notation:
%
% [Error Value] = ljud_eGet(Parameters)
%
% Error should be returned as a zero, and Value will be the data requested.
% See Section 3.3 of the LabJackUD_Driver_For_Windows.pdf for more
% information on the eGet function and the required paramters.

function [ljError, ljValue] = ljud_eGet(ljHandle, IOType, Channel, ljValue, x1);
[ljError, ljValue] = calllib('labjackud','eGet',ljHandle,IOType,Channel,ljValue,x1);
