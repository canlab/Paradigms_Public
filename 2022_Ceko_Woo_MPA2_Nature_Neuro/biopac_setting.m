function trigger_biopac = biopac_setting(io32dir)

[~, hn] = system('hostname'); hn=deblank(hn);
addpath(genpath(io32dir));

global BIOPAC_PORT; 

if strcmp(hn,'INC-DELL-002')
    BIOPAC_PORT = hex2dec('E010');
    trigger_biopac = str2func('TriggerBiopac3');
else
    BIOPAC_PORT = digitalio('parallel','LPT2');
    addline(BIOPAC_PORT,0:7,'out');
    trigger_biopac = str2func('TriggerBiopac');
end

end