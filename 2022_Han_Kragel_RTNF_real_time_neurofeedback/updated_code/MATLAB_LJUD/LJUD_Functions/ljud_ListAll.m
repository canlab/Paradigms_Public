% Call the ljud_AddRequest function from the MATLAB command window or any other
% mfile. To call the function use the following notation:
%
% [Error] = ljud_ListAll(Parameters)
%
% Error should be returned as a zero. 
% See Section 3.4 of the LabJackUD_Driver_For_Windows.pdf for more
% information on the ListAll function and the required paramters.

function [ljError] = ljud_ListAll(DeviceType,ConnectionType,pNumFound,pSerialNumbers,pIDs,pAddresses)
[ljError] = calllib('labjackud','ListAll',DeviceType,ConnectionType,pNumFound,pSerialNumbers,pIDs,pAddresses);
