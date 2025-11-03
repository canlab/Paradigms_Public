% Call the ljud_Go function from the MATLAB command window or any other
% mfile. To call the function use the following notation:
%
% [Error] = ljud_Go
%
% Error should be returned as a zero.
% See Section 3.5 of the LabJackUD_Driver_For_Windows.pdf for more
% information on the Go function and the required paramters. Calling the
% Go function causes all requests on all open LabJacks to be
% performed. 

function [ljError] = ljud_Go()
[ljError] = calllib('labjackud','Go');
