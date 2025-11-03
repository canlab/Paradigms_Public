% Call the ljud_GetResult function from the MATLAB command window or any other
% mfile. To call the function use the following notation:
%
% [Error Value] = ljud_GetResult(Parameters)
%
% Error should be returned as a zero, Value will be the requested data.
% See Section 3.7 of the LabJackUD_Driver_For_Windows.pdf for more
% information on the GetResult function and the required paramters. Use
% GetResult function to read the result and errorcode for a particular IO
% Type and Channel. 


function [ljError ljValue] = ljud_GetResult(ljHandle, IOType, Channel, ljValue)
[ljError ljValue] = calllib('labjackud','GetResult',ljHandle,IOType,Channel,ljValue);
