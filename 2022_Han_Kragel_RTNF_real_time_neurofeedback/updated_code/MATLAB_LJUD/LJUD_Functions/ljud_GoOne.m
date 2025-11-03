% Call the ljud_GoOne function from the MATLAB command window or any other
% mfile. To call the function use the following notation:
%
% [Error] = ljud_GoOne(Parameters)
%
% Error should be returned as a zero.
% See Section 3.6 of the LabJackUD_Driver_For_Windows.pdf for more
% information on the GoOne function and the required paramters. Calling the
% GoOne function causes all requests on one particular LabJack to be
% performed.

function [ljError] = ljud_GoOne(ljHandle)
[ljError] = calllib('labjackud','GoOne',ljHandle);
