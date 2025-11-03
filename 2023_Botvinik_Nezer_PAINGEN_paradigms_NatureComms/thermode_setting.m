function trigger_thermode = thermode_setting(io32dir)

[~, hn] = system('hostname'); hn=deblank(hn);
%addpath(genpath(io32dir));
%config_io;

global THERMODE_PORT; 

if strcmp(hn,'INC-DELL-002') || strcmp(hn, 'CINC173')
    THERMODE_PORT = hex2dec('D010');
    trigger_thermode = str2func('TriggerThermode');
else
    % should be behavioral room -- need to implement
%     THERMODE_PORT = digitalio('parallel','LPT1');
%     addline(THERMODE_PORT,0:7,'out');
%     trigger_heat = str2func('TriggerHeat');
end

end