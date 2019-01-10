function data = run_autp_task(subject,day)

if nargin<1, subject=200; end
if nargin<2, day=7; end
rng('shuffle','twister');

debug     = 0;   % settings.ptb Debugging

global b;
participant = [];

try
    % init experiment/settings.ptb
    ptbInit;
    
    % Instructions
    ShowInstructions;
    
    % announce new block
    KbQueueStart;
    StartNewMRIBlock(1);
    
    % run trials
    for trials=1:participant.experiment.ntrials
        RunTrial(trials)
        save(fullfile(participant.settings.path.tmp,sprintf('sub%03d_day%d_thumbpaintask_tmp.mat',subject, day)),'participant');
    end
    DrawFormattedText(participant.settings.window, 'Data collection finished. Please wait for clean-up.','center',participant.settings.ptb.mid(2)+tvoff);
    Screen('Flip', participant.settings.window);
    
    %ReadMRIVols('block');
    fprintf('mean RT: %4.2f s\n\n',nanmean(participant.data.vasRT));
    KbQueueStop;
    
    % return data
    data = participant;
    
    % finish up
    save(fullfile(participant.settings.path.data,sprintf('sub%03d_day%d_thumbpaintask.mat',subject, day)),'participant');
    cleanup;

    
catch ME
    ME
    ME.stack(:)
    ShowCursor; cleanup;
    psychrethrow(psychlasterror);
end


% subfunctions
    function ptbInit
        AssertOpenGL;
        commandwindow;
        if debug
            ListenChar(0);
            PsychDebugWindowConfiguration;
        end
        % basic infos
        load('trials/autp_trials_main.mat','r');
        participant.subject           = subject;
        participant.date              = datestr(now);
        if ismac
            [~, hostname] = system('scutil --get ComputerName');
        else
            [~, hostname]       = system('hostname');
        end
        participant.experiment.hostname      = deblank(hostname);
                
        participant.experiment.nblocks           = 1;
        participant.experiment.ntrials           = r.dat.ntrials;
        participant.experiment.trialsPerBlock  = participant.experiment.ntrials/participant.experiment.nblocks;
           
        participant.experiment.stimuliLevels = r.dat.nstimlevel;
        participant.experiment.stimuliValues       = [0004 0007]; % adapt, pressure in kg
        
        % subject randomized info
        tsel = 1:participant.experiment.ntrials;
        participant.experiment.stimuliTypes      = r.dat.stimtype(subject,tsel);
        participant.experiment.stimlevel     = r.dat.stim(subject,tsel);
        participant.experiment.cuelevel      = r.dat.cue(subject,tsel);
        participant.experiment.cueMean          = r.dat.cueM(subject,tsel);
        participant.experiment.cueVals       = squeeze(r.cues(subject,tsel,:));
        participant.experiment.cueValsVAS    = participant.experiment.cueVals * 100;
        
        participant.experiment.vasStartPosition       = repmat([15 85],1,ceil(participant.experiment.ntrials/2));
        participant.experiment.vasStartPosition       = participant.experiment.vasStartPosition(randperm(numel(participant.experiment.vasStartPosition)));
        
        
        % paths
        participant.settings.path.root         = pwd;
        participant.settings.path.data         = fullfile(participant.settings.path.root,'data');
        participant.settings.path.tmp          = fullfile(participant.settings.path.root,'data','tmp');
        if ~isdir(participant.settings.path.data), mkdir(participant.settings.path.data); end
        if ~isdir(participant.settings.path.tmp), mkdir(participant.settings.path.tmp); end


        % Common strings
        participant.settings.ptb.qstr = {'How painful?'};
        participant.settings.ptb.sstr = {'pain'};
        
        % screen settings
        participant.settings.conf.oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
        participant.settings.ptb.screenID = max(Screen('Screens'));
        GetSecs; WaitSecs(0.01);
        
        % get window colors
        participant.settings.conf.white = WhiteIndex(participant.settings.ptb.screenID); % pixel value for white
        participant.settings.conf.black = BlackIndex(participant.settings.ptb.screenID); % pixel value for black
        participant.settings.conf.gray  = (participant.settings.conf.white+participant.settings.conf.black)/2;
        participant.settings.conf.cursorcol = {[],[0 0 0],[0 0 0]};
        participant.settings.ptb.bg     = participant.settings.conf.gray;
        
        % open screen
        [participant.settings.window, participant.settings.ptb.rect]  = Screen(participant.settings.ptb.screenID, 'OpenWindow',participant.settings.ptb.bg);
        
        % screen properties
        Screen('BlendFunction', participant.settings.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        participant.settings.ptb.slack                 = Screen('GetFlipInterval',participant.settings.window)./2;
        [participant.settings.ptb.width, participant.settings.ptb.height] = Screen('WindowSize', participant.settings.ptb.screenID);
        participant.settings.ptb.mid                   = [ participant.settings.ptb.width./2 participant.settings.ptb.height./2];
        participant.settings.ptb.fix_r                 = 8;
        participant.settings.ptb.fix                   = [participant.settings.ptb.mid-participant.settings.ptb.fix_r participant.settings.ptb.mid+participant.settings.ptb.fix_r];
        participant.settings.fix                       = participant.settings.ptb.fix;
        participant.settings.ptb.fontsize              = 26;
        participant.settings.ptb.fontcolor             = participant.settings.conf.black;
        participant.settings.ptb.fontstyle             = 0;
        participant.settings.ptb.fontname              = 'Arial';
   
        % set text style
        Screen('Preference', 'DefaultFontName','Arial');
        Screen('TextSize',  participant.settings.window, participant.settings.ptb.fontsize);
        Screen('Preference', 'DefaultFontStyle',participant.settings.ptb.fontstyle);
        
        % prepare sprites
        createSprites;
        Screen('Flip',participant.settings.window);
        
        % key bindings
        KbName('UnifyKeyNames');
        participant.settings.keyBindings.confirm      = KbName('Return');
        participant.settings.keyBindings.right        = KbName('RightArrow');
        participant.settings.keyBindings.left         = KbName('LeftArrow');
        participant.settings.keyBindings.space        = KbName('SPACE');
        participant.settings.keyBindings.esc          = KbName('ESCAPE');
        participant.settings.keyBindings.mri          = KbName('5%'); 
        keylist             = zeros(256,1);
        keylist(participant.settings.keyBindings.mri) = 1;
        
        % mouse / trackball setup
        [mice,  ~] = GetMouseIndices('masterPointer');
        participant.settings.ptb.mouse        = mice(1); % adapt
        SetMouse(participant.settings.ptb.mid(1), participant.settings.ptb.mid(2),participant.settings.window,participant.settings.ptb.mouse); % set mouse to center
        KbCheck(-1); % check all settings.keyBindings released;
        if ~debug, HideCursor(participant.settings.ptb.screenID); end 
        
        % MRI settings
        participant.settings.mri.fmrion        = strcmp(participant.experiment.hostname,'INC-DELL-002'); % adapt
        participant.settings.mri.tr            = 0.41; % TR in secs, adapt
        participant.settings.mri.ndummies      = 15;
        participant.data.mri.vol_t     = repmat({[]},1,participant.experiment.nblocks);
        KbQueueCreate([],keylist);
        
        % pressure control
        participant.settings.conf.udp_t = udp('localhost',61557); % open udp channels
        participant.settings.conf.udp_r = udp('localhost',61556,'localport', 61556);
        fopen(participant.settings.conf.udp_t);
        fopen(participant.settings.conf.udp_r);
        fwrite(participant.settings.conf.udp_t, '0005,0010,o'); % open the remote channel
        
        % biopac settings
        config_io;
        participant.settings.conf.b_port = hex2dec('E010');
        participant.settings.conf.b_sigcue  = [4]; % adapt
        participant.settings.conf.b_sigstim = [128]; % adapt
        participant.settings.conf.b_sigrate = [132]; % adapt
        
        % durations
        participant.settings.timings.cueDuration     = r.t.cue(subject,:);
        participant.settings.timings.vasDuration     = r.t.rate(subject,:);
        participant.settings.timings.stimDuration    = r.t.stim(subject,:);
        participant.settings.timings.jitter1      = r.t.d1(subject,:);
        participant.settings.timings.jitter2      = r.t.d2(subject,:);
        participant.settings.timings.itiDuration     = r.t.iti(subject,:);
        participant.settings.timings.totalDuration     = r.t.tot(subject,:);
        
        % data vars
        participant.data.eventTimes         = NaN(6,participant.experiment.ntrials);
        participant.data.stimuliLevels = NaN(1,participant.experiment.ntrials);
        participant.data.stimuliValues = NaN(1,participant.experiment.ntrials);
        participant.data.vasCueValues= NaN(size(r.cues,3),participant.experiment.ntrials);        
        participant.data.painRating   = NaN(1,participant.experiment.ntrials);
        
        participant.players = audioSetup;
    end

    % make offscreen sprites
    function createSprites

        % VAS config
        hl = 600;
        xl = participant.settings.ptb.mid(1) - hl/2;
        xr = participant.settings.ptb.mid(1) + hl/2;
        y  = participant.settings.ptb.mid(2) + 0;
        yb = y - 15;
        yt = y + 15;
        l1 = 47;
        l2 = 70;
        pw = 2;
        participant.settings.vas.hl       = hl;
        participant.settings.vas.cpos     = [xl,yb,xl,yt];
        participant.settings.vas.cposmaxr = [xr yb xr yt];
        participant.settings.vas.cposmaxl = [xl yb xl yt];
        participant.settings.vas.yb       = yb;
        participant.settings.vas.yt       = yt;
        participant.settings.vas.maxy     = [yb yt];
        participant.settings.vas.pw       = pw;
        participant.settings.vas.cstep    = participant.settings.vas.hl / 100;
             
        % VAS Pain
        participant.settings.ptb.vas_sprite(1) = Screen('OpenOffScreenWindow', participant.settings.ptb.screenID,participant.settings.ptb.bg);
        Screen('TextFont', participant.settings.ptb.vas_sprite(1), participant.settings.ptb.fontname);
        Screen('TextColor', participant.settings.ptb.vas_sprite(1), participant.settings.ptb.fontcolor);
        Screen('TextSize', participant.settings.ptb.vas_sprite(1), participant.settings.ptb.fontsize-4);
        Screen('DrawLine', participant.settings.ptb.vas_sprite(1), [0 0 0], xl,y,xr,y,pw);
        Screen('DrawLine', participant.settings.ptb.vas_sprite(1), [0 0 0], xl,yb+5,xl,yt-5,pw);
        Screen('DrawLine', participant.settings.ptb.vas_sprite(1), [0 0 0], xr,yb+5,xr,yt-5,pw);
        DrawFormattedText(participant.settings.ptb.vas_sprite(1),'no pain',xl-29,yb+l1);
        DrawFormattedText(participant.settings.ptb.vas_sprite(1),'at all',xl-26,yb+l2);
        DrawFormattedText(participant.settings.ptb.vas_sprite(1),'worst pain',xr-30,yb+l1);
        DrawFormattedText(participant.settings.ptb.vas_sprite(1),'imaginable',xr-29,yb+l2);       
    end

    % wait for keyboard input
    function KeyTime = WaitKeyPress(kID)
        while KbCheck(-1); end  % Wait until all settings.keyBindings are released.
        
        while 1
            % Check the state of the keyboard.
            [ keyIsDown, KeyTime, keyCode ] = KbCheck(-1);
            % If the user is pressing a key, then display its code number and name.
            if keyIsDown
                
                if keyCode(participant.settings.keyBindings.esc)
                    cleanup;
                elseif keyCode(kID)
                    if kID==participant.settings.keyBindings.mri, participant.data.mri.start(b) = KeyTime; end
                    break;
                end
            end
        end
    end

    % display instruction slides
    function ShowInstructions
        idir = fullfile('lib','instructions');
        ifiles = dir(fullfile(idir,'Slide*.png'));
        H      = round(participant.settings.ptb.height*0.9);
        settings.window = round(H*4/3);
        irect  = [(participant.settings.ptb.width-settings.window)/2 (participant.settings.ptb.height-H)/2 (participant.settings.ptb.width+settings.window)/2 (participant.settings.ptb.height+H)/2];
        for sp = 1:size(ifiles,1)
            img  = imread(fullfile(idir,ifiles(sp).name));
            itex = Screen('MakeTexture', participant.settings.window, img);
            Screen('DrawTexture', participant.settings.window, itex, [], irect);
            Screen('Flip',participant.settings.window);
            WaitSecs(1);
            ok = 1
            while ok == 1
                [mX, ~, buttons] = GetMouse(participant.settings.window);
                ok = ~any(buttons);
            end
        end
        Screen('Flip',participant.settings.window);
    end

    % New block screen
    function StartNewMRIBlock(z)
        if z==1
            dstr = sprintf('The first block will start soon.');
        else
            dstr = sprintf('Please wait for the experimenter.\n\nWe will start the next block soon.');
        end
        Screen('TextFont', participant.settings.window, participant.settings.ptb.fontname);
        DrawFormattedText(participant.settings.window,dstr,'center',participant.settings.ptb.mid(2) - 50);
        Screen('Flip',participant.settings.window);
        if participant.settings.mri.fmrion
            WaitKeyPress(participant.settings.keyBindings.space);
            DrawFormattedText(participant.settings.window,'Waiting for scanner','center',participant.settings.ptb.mid(2) - 50);
            Screen('Flip',participant.settings.window);
            KbQueueFlush(-1,3);
            participant.data.t_block0(z) = WaitKeyPress(participant.settings.keyBindings.mri); % get first MR volume
        else 
            KbQueueFlush;
            participant.data.t_block0(z) = WaitKeyPress(participant.settings.keyBindings.space); % manual start
        end
        Screen('Flip',participant.settings.window); % start of each block
        participant.data.t_block_expstart(z) = WaitSecs(participant.settings.mri.tr * participant.settings.mri.ndummies); % wait 15 TR's for actual start
    end

    % run single trial
    function RunTrial(x)
        participant.data.trialStartTime(x) = GetSecs;
        participant.data.stimuliTypes(x) = participant.experiment.stimuliTypes(x);
        participant.data.stimuliLevels(x) = participant.experiment.stimlevel(x);
        participant.data.stimdur(x)   = participant.settings.timings.stimDuration(x);
        participant.data.cuelevel(x)  = participant.experiment.cuelevel(x);
        participant.data.stimuliValues(x) = participant.experiment.stimuliValues(participant.experiment.stimlevel(x));
        participant.data.vasCueValues(:,x) = participant.experiment.cueValsVAS(x,:);
        
        % compute cue line positions
        xy = repmat((participant.settings.vas.cstep * (participant.experiment.cueValsVAS(x,:) - 50)),2,1);
        xy = xy(:)' + participant.settings.ptb.mid(1);
        xy = [xy; repmat(participant.settings.vas.maxy+[-10 10],1,size(participant.experiment.cueValsVAS,2))];
        
        
        % draw cues
        Screen('DrawTexture', participant.settings.window, participant.settings.ptb.vas_sprite(1));
        Screen('DrawLines',participant.settings.window, xy , participant.settings.vas.pw+1, participant.settings.conf.black);
        % show cues
        
        participant.data.eventTimes.(1,x) = Screen('Flip',participant.settings.window); % cue on
        if participant.settings.mri.fmrion
            outp(participant.settings.conf.b_port,participant.settings.conf.b_sigcue); WaitSecs(0.05);outp(participant.settings.conf.b_port,0); % biopac trigger
        end
        
        % delay 1
        Screen('FillOval', participant.settings.window, participant.settings.conf.black, participant.settings.ptb.fix, participant.settings.ptb.fix_r+20);
        participant.data.settings.eventTimes(2,x) = Screen('Flip',participant.settings.window, participant.data.trialStartTime(x) + participant.settings.timings.cueDuration(x) - participant.settings.ptb.slack); % cue off, d1 on
        
        % pressure pain
        
        if participant.settings.mri.fmrion
            outp(participant.settings.conf.b_port,participant.settings.conf.b_sigstim); WaitSecs(0.05);outp(participant.settings.conf.b_port,0); % biopac trigger
        end 
        if strcmp(participant.experiment.stimuliTypes(x), 'TP')
            sendUDP(x);
        else
            playblocking(participant.players{participant.experiment.stimlevel(x)});
        end
        participant.data.settings.eventTimes(3,x) = GetSecs - 0.1;
            
        Screen('FillOval', participant.settings.window, participant.settings.conf.black, participant.settings.ptb.fix, participant.settings.ptb.fix_r+20);
        participant.data.eventTimes(4,x) = Screen('Flip', participant.settings.window, participant.data.trialStartTime(x)+participant.settings.timings.cueDuration(x)+participant.settings.timings.jitter1(x)+participant.settings.timings.stimDuration(x) - participant.settings.ptb.slack); % record stim end
        
        % outcome rating
        participant.data.eventTimes(5,x) = Screen('Flip',participant.settings.window, participant.data.trialStartTime(x)+participant.settings.timings.cueDuration(x)+participant.settings.timings.jitter1(x)+participant.settings.timings.stimDuration(x)+participant.settings.timings.jitter2(x)-participant.settings.ptb.slack); % end of d3
        GetVASRatings(x,participant.data.eventTimes(5,x)+participant.settings.timings.vasDuration(x));
        
        % ITI
        participant.data.eventTimes(6,x) = Screen('Flip',participant.settings.window);
        participant.data.vasRT(x)  = participant.data.eventTimes(6,x) - participant.data.eventTimes(5,x);
        fprintf(1,'Trial %02d, VAS: %3d, RT: %4.2f\n',x,round(participant.data.painRating(x)),participant.data.vasRT(x));
        WaitSecs('UntilTime', participant.data.trialStartTime(x)+participant.settings.timings.totalDuration(x) - participant.settings.ptb.slack);
    end

    % send trigger to pressure device
    function sendUDP(xx)
        dur = sprintf('%04d', participant.data.stimdur(xx));
        stim = sprintf('%04d', participant.data.stimuliValues(xx));
        eval(['fwrite(participant.settings.conf.udp_t, ''' stim ',' dur ',t'');']);
    end

    % get VAS ratings
    function GetVASRatings(tt,tmax)      
        tvoff     = -90;
        xinit     = participant.experiment.vasStartPosition(tt)*participant.settings.vas.cstep;
        cursorpos = participant.settings.vas.cposmaxl + [xinit 0 xinit 0];
        cursorcol = [0 0 0]; % [200 0 0]; % red
        mX        = cursorpos(1); mY = cursorpos(2);
        SetMouse(mX, mY); % set mouse to cursorpos
        Screen('DrawTexture', participant.settings.window, participant.settings.ptb.vas_sprite(1));
        Screen('TextSize', participant.settings.window, participant.settings.ptb.fontsize-4);
        DrawFormattedText(participant.settings.window,participant.settings.ptb.qstr{1},'center',participant.settings.ptb.mid(2)+tvoff);
        Screen('FillRect',participant.settings.window, cursorcol, cursorpos + [-3 0 3 0]);
        Screen('Flip', participant.settings.window);
        
        if participant.settings.mri.fmrion
            outp(participant.settings.conf.b_port,participant.settings.conf.b_sigrate); WaitSecs(0.05);outp(participant.settings.conf.b_port,0); % biopac trigger
        end
        
        ok = 1;
        while ok && (GetSecs < tmax)
            % check keyboard
            [ keyIsDown, ~, keyCode ] = KbCheck(-1);
            if keyIsDown && keyCode(participant.settings.keyBindings.esc)
                cleanup;
            end
            % get mouse position
            [mX, ~, buttons] = GetMouse(participant.settings.window);
            ok = ~any(buttons);
            if participant.settings.mri.fmrion
                cursorpos([1 3]) = cursorpos([1 3]) + (mX-cursorpos([1 3]))*2;
                SetMouse(cursorpos(1), mY);
            else
                cursorpos([1 3]) = mX;
            end
            % watch end of scale
            if cursorpos(1) < participant.settings.vas.cposmaxl(1), 
                cursorpos([1 3]) = participant.settings.vas.cposmaxl(1);
            elseif cursorpos(1) > participant.settings.vas.cposmaxr(1), 
                cursorpos([1 3]) = participant.settings.vas.cposmaxr(1);
            end
            SetMouse(round(cursorpos(1)), mY);
            participant.data.painRating(tt) = (cursorpos(1) - participant.settings.vas.cposmaxl(1))/participant.settings.vas.cstep;
            % re-draw
            Screen('DrawTexture', participant.settings.window,  participant.settings.ptb.vas_sprite(1));
            DrawFormattedText(participant.settings.window, participant.settings.ptb.qstr{1},'center',participant.settings.ptb.mid(2)+tvoff);
            Screen('FillRect',participant.settings.window, cursorcol, cursorpos + [-4 0 4 0]);
            Screen('Flip', participant.settings.window);
        end
    end

    % Read MRI trigger [sent as keyboard input]
    function ReadMRIVols(mode)
        % read all volumes
        i = 0;
        [event, nremaining] = KbEventGet;
        while nremaining>0
            i = i+1;
            if event.Pressed==1
                participant.data.mri.vol_t{i} = [participant.data.mri.vol_t{i}; event.Time event.Keycode];
            end
            [event, nremaining] = KbEventGet;
        end
        % if end of block wait for last volume
        if strcmp(mode,'block')
            WaitSecs(participant.settings.mri.tr*2);
            [event, nremaining] = KbEventGet;
            i = 0;
            while nremaining>0
                i = i+1;
                if event.Pressed==1
                    participant.data.mri.vol_t{i} = [participant.data.mri.vol_t{i}; event.Time event.Keycode];
                end
                WaitSecs(participant.settings.mri.tr*2);
                [event, nremaining] = KbEventGet;
            end
        end
    end

    function players = audioSetup
        
    fnames = {'audio/knife_on_bottle_LV2.wav','audio/knife_on_bottle_LV4.wav'};

        for i = 1:length(fnames)
            try
                y = audioread(fnames{i});
            catch
                y = wavread(fnames{i});
            end
        players{i} = audioplayer(y, 44100);
        end

    end
    
    % cleanup, close settings.ptb
    function cleanup
        try
            fclose(participant.settings.conf.udp_t);
            fclose(participant.settings.conf.udp_r);
        catch
             warning('could not close UDP ports');  
        end
        ListenChar(0); KbQueueRelease;
        ShowCursor;
        DrawFormattedText(participant.settings.window, 'Clean-up complete. Please wait.','center',participant.settings.ptb.mid(2)+tvoff);
        Screen('Flip', participant.settings.window);
        WaitKeyPress(participant.settings.keyBindings.space);
        Screen('CloseAll');
        clear Screen;
        disp('This is lasterr -----')
        disp(lasterr);
    end

end