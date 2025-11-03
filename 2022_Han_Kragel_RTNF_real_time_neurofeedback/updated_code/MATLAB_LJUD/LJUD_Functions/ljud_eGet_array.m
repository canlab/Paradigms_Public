% Call the ljud_eGet_array function from the MATLAB command window or any other
% mfile. This function was created to handle retrieving arrays of data
% which is especially useful for getting stream data.
%
% To call the function use the following notation:
%
% [Error Value ReturnArray] = ljud_eGet_array(Parameters)
%
% Error should be returned as a zero, and Value will be the data requested.
% ReturnArray will be a single column array of doubles.
% See Section 3.3 of the LabJackUD_Driver_For_Windows.pdf for more
% information on the eGet function and the required paramters.

function [ljError, ljValue, return_array] = ljud_eGet_array(ljHandle, IOType, Channel, ljValue, array);
Stream = libpointer('doublePtr',array);
[ljError, ljValue] = calllib('labjackud_doublePtr','eGet',ljHandle,IOType,Channel,ljValue,Stream);

% Extract the array of voltages from the 'value' property of the pointer
% (Stream), and then do the conversion to doubles.
return_array = get(Stream,'value');
return_array = double(return_array);
