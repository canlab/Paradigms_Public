% Calling ljud_ErrorToString outputs a string describing the given error code
% passed or an empty string if not found. 
% See section 3.12 of the LabJackUD_Driver_For_Windows.pdf
% for more information on this function.
%
% [Error_String] = ljud_ErrorToString(ErrorCode) Use this notation to
% retrieve error description.

function [ErrorString] = ljud_ErrorToString(ljError)
String = '';
[ErrorString] = calllib('labjackud','ErrorToString',ljError,String);
