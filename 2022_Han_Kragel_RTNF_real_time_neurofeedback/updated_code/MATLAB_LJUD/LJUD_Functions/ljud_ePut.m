% Call the ljud_ePut function from the MATLAB command window or any other
% mfile. To call the function use the following notation:
%
% [Error] = ljud_ePut(Parameters)
%
% Error should be returned as a zero. ePut is designed for outputs or
% setting configuration parameters and will not return anything except the
% error code.
% See Section 3.3 of the LabJackUD_Driver_For_Windows.pdf for more
% information on the ePut function and the required paramters.

function [ljError] = ljud_ePut(ljHandle, IOType, Channel, ljValue, x1)
[ljError] = calllib('labjackud','ePut',ljHandle,IOType,Channel,ljValue,x1);
