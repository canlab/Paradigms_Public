% Call the TCVoltsToTemp function from the MATLAB command window or any other
% mfile. To call the function use the following notation:
%
% [Error] = ljud_TCVoltsToTemp(Parameters)
%
% Error should be returned as a zero. 
% See Section 3.4 of the LabJackUD_Driver_For_Windows.pdf for more
% information on the TCVoltsToTemp function and the required paramters.

function [ljError] = ljud_TCVoltsToTemp(TCType, TCVolts, CJTempK,pTCTempK)
[ljError] = calllib('labjackud','TCVoltsToTemp',TCType, TCVolts, CJTempK,pTCTempK)