function [t, TTLsig] = TriggerThermode(temperature)
% USAGE: t = TriggerThermode(temperature)

global THERMODE_PORT

%initialize object
ioObj = io32;
err = io32(ioObj);
if err
    error('io32 aint workin')
end

% === This needs revision for the ATS codes in thermode =========
TTLsig = floor(temperature + double(128*(mod(temperature,1)>0))); 
% ===============================================================

io32(ioObj, THERMODE_PORT, TTLsig); %send ttl to thermode
t = GetSecs;
WaitSecs(0.1);
io32(ioObj, THERMODE_PORT, 0) %reset thermode ttl

end