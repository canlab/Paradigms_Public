% Call the eDO function from the MATLAB command window or any other
% mfile. To call the function use the following notation:
%
% [Error] = ljud_eDO(Parameters)
%
% Error should be returned as a zero. 
% See Section 3.4 of the LabJackUD_Driver_For_Windows.pdf for more
% information on the eDO function and the required paramters.

function [ljError] = ljud_eDO(Handle, Channel, State)
[ljError] = calllib('labjackud','eDO',Handle,  Channel, State)
