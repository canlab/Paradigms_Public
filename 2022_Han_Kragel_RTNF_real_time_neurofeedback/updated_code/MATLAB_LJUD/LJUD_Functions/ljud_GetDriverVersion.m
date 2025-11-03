% Calling ljud_GetDriverVersion returns the version number of this Windows
% LabJack Driver. See section 3.13 of the LabJackUD_Driver_For_Windows.pdf
% for more information on this function.
%
% [Version] = ljud_GetDriverVersion() Use this notation to call driver
% version.


function [Version] = ljud_GetDriverVersion(ljHandle)
[Version] = calllib('labjackud','GetDriverVersion');

