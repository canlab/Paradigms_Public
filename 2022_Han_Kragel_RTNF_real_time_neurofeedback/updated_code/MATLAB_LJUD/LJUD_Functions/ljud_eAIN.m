% Call the eAIN function from the MATLAB command window or any other
% mfile. To call the function use the following notation:
%
% [Error] = ljud_eAIN(Parameters)
%
% Error should be returned as a zero. 
% See Section 3.4 of the LabJackUD_Driver_For_Windows.pdf for more
% information on the eAIN function and the required paramters.

function [ljError] = ljud_eAIN(Handle, ChannelP, ChannelN, Voltage, Range, Resolution, Settling, Binary,  Reserved1, Reserved2)
[ljError] = calllib('labjackud','eAIN',Handle, ChannelP, ChannelN, Voltage, Range, Resolution, Settling, Binary,  Reserved1, Reserved2)
