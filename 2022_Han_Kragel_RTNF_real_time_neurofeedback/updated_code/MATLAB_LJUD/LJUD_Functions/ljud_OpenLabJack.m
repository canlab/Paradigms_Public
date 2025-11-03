% Call ljud_OpenLabJack from the command window or any mfile. It returns
% the specified address and handle of your LabJack. See section 3.2 of the
% LabJackUD Driver for Windows for more information about OpenLabJack().

function [Error ljHandle] = ljud_OpenLabJack(DeviceType,ConnectionType,Address,FirstFound)
[Error address ljHandle] = calllib('labjackud','OpenLabJack',DeviceType,ConnectionType,Address,FirstFound,0);
if Error
    ljHandle=0
end
