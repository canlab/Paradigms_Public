function trigger_biopac = biopac_setting()
    [~, hn] = system('hostname'); hn=deblank(hn);

    if ~(strcmp(hn,'INC-DELL-002') || strcmp(hn, 'CINC173'))
        warning('biopac configuration has not be tested on this computer.');
    end

    trigger_biopac = str2func('TriggerBiopac');
end