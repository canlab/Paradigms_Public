% Call the eDI function from the MATLAB command window or any other
% mfile. To call the function use the following notation:
%
% [Error] = ljud_eDI(Parameters)
%
% Error should be returned as a zero. 
% See Section 3.4 of the LabJackUD_Driver_For_Windows.pdf for more
% information on the eDI function and the required paramters.

function [ljError] = ljud_eDI(Handle, Channel, State)
[ljError] = calllib('labjackud','eDI',Handle,  Channel, State)
