% Call the eDAC function from the MATLAB command window or any other
% mfile. To call the function use the following notation:
%
% [Error] = ljud_eDAC(Parameters)
%
% Error should be returned as a zero. 
% See Section 3.4 of the LabJackUD_Driver_For_Windows.pdf for more
% information on the eDAC function and the required paramters.

function [ljError] = ljud_eDAC(Handle, Channel, Voltage, Binary, Reserved1, Reserved2)
[ljError] = calllib('labjackud','eDAC',Handle, Channel, Voltage, Binary, Reserved1, Reserved2)
