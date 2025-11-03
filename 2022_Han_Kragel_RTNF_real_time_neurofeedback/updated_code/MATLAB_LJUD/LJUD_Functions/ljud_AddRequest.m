% Call the ljud_AddRequest function from the MATLAB command window or any other
% mfile. To call the function use the following notation:
%
% [Error] = ljud_AddRequest(Parameters)
%
% Error should be returned as a zero. AddRequest adds an item to the list
% of requests to be performed on the next call to Go() or GoOne().
% See Section 3.4 of the LabJackUD_Driver_For_Windows.pdf for more
% information on the AddRequest function and the required paramters.

function [ljError] = ljud_AddRequest(ljHandle, IOType, Channel, ljValue, x1, ljUserData)
[ljError] = calllib('labjackud','AddRequest',ljHandle,IOType,Channel,ljValue,x1,ljUserData);
