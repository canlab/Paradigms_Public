% Call the ljud_GetFirstResult function from the MATLAB command window or any other
% mfile. To call the function use the following notation:
%
% [Error IOType Channel ljValue x1 ljUserData] = ljud_GetFirstResult(Parameters)
%
% Error should be returned as a zero, IOType will be a pointer to the
% IOType of this item in the list, Channel will be a pointer to the channel
% number of this item in the list, ljValue will be the data requested, x1
% will be a pointer to the x1 parameter of this item in the list,
% ljUserData will be a pointer to data that is simply passed along with the
% request and returned unmodified.
% See Section 3.8 of the LabJackUD_Driver_For_Windows.pdf for more
% information on the GetFirstResult function and the required paramters. Calling either
% Go function creates a list of results that matches the list of requests. Use
% GetFirstResult function to step through the list of results in order


function [ljError IOType Channel ljValue x1 ljUserData] = ljud_GetFirstResult(ljHandle, IOType, Channel, ljValue, x1, ljUserData)
[ljError IOType Channel ljValue x1 ljUserData] = calllib('labjackud','GetFirstResult',ljHandle, IOType, Channel, ljValue, x1, ljUserData);
