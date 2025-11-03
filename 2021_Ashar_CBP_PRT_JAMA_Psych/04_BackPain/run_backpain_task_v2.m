function data = run_backpain_task(subject,day,pressures)

if nargin<1, subject=9999; end
if nargin<2, day=7; end

if nargin < 3 || length(pressures) ~= 4
    pressures = [0.08 0.12 0.16 0.20];
end
    
rng('shuffle','twister');

subjectnum = subject;
subject = mod(subject,300);
if subject == 0
    subject = 300;
end

debug     = 0;   % settings.ptb Debugging

global b;
participant         = [];

try
    % init experiment/settings.ptb
    ptbInit;
    
    % Instructions
    ShowInstructions;
    CyclePressure;
    
    % announce new block
    KbQueueStart;
    StartNewMRIBlock(1);
    
    % run trials
    for t=1:participant.experiment.ntrials
        RunTrial(t)
        % save data thus far
        save(fullfile(participant.settings.path.tmp,sprintf('sub-%04d_ses-%02d_task-chronic_events_tmp.mat',subjectnum,day)),'participant');
    end
          
    DrawFormattedText(participant.settings.window, 'Data collection finished. Please wait for clean-up.','center',participant.settings.ptb.mid(2)+tvoff);
    Screen('Flip', participant.settings.window);
    
    KbQueueStop;
    
        
    %painglm = fitglm([participant.data.vasrate' power(participant.data.vasrate,2)'],participant.data.stimvalue');
    %bdmval = feval(painglm,[5 25]);
    
    %fprintf('\nBDM Auction value for pain rating of 5 is: %f\n', round(bdmval,2));
    % return data
    data = participant;
    
    % finish up
    save(fullfile(participant.settings.path.data,sprintf('sub-%04d_ses-%02d_task-chronic_events.mat',subjectnum,day)),'participant');
    cleanup;  %  will also stop the bladder and close the log file
    

catch RUN
    cleanup;
    data = RUN;
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
        load('trials/backpain_trials_main','r');
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
        participant.experiment.trials_per_block  = participant.experiment.ntrials/participant.experiment.nblocks;
           
        participant.experiment.nlevel        = r.dat.nstimlevel;
        participant.experiment.levels        = [1 2 3 4];
        
        if nargin < 3
            participant.experiment.stimset       = [0.08 0.12 0.16 0.20]; % adapt, pressure in kg
        else
            participant.experiment.stimset = pressures;
        end
        
        % subject randomized info
        tsel = 1:participant.experiment.ntrials;
        participant.experiment.stimlevel     = r.dat.stim(subject,tsel);
        
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
        participant.settings.ptb.fontsize              = 28;
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
        participant.settings.mri.fmrion        = 1; % strcmp(participant.experiment.hostname,'INC-DELL-002'); % adapt
        participant.settings.mri.tr            = 0.46; % TR in secs, adapt
        participant.data.mri.vol_t     = repmat({[]},1,participant.experiment.nblocks);
        
        KbQueueCreate([],keylist);
        
        if participant.settings.mri.fmrion 
            participant.settings.mri.ndummies      = 15;
        else
            participant.settings.mri.ndummies      = 0;
        end
        participant.data.mri.experimentStart = NaN(1,1);
        participant.data.mri.firstMRITriggerPulse = NaN(1,1);
        
        % device control and thermode and pressure devices
        % pressure
        participant.settings.conf.udp_t = udp('localhost',61558); % open udp channels. Wani had 61557, Ken's email said 61558
        participant.settings.conf.udp_r = udp('localhost',61559,'localport', 61559); % Wani 61558/61556, Ken 61559
        fopen(participant.settings.conf.udp_t);
        fopen(participant.settings.conf.udp_r);
        fwrite(participant.settings.conf.udp_t, '0.00, o'); % open the remote channel

        % biopac
        if 0 % participant.settings.mri.fmrion
            config_io;
            participant.settings.conf.b_port = hex2dec('E010');
            participant.settings.conf.b_sigstim = [4]; % adapt
            participant.settings.conf.b_sigrate = [128]; % adapt
        end
        
        % durations
        participant.settings.timings.vas     = r.t.rate(subject,:);
        participant.settings.timings.stim    = r.t.stim(subject,:);
        participant.settings.timings.tot     = r.t.tot(subject,:);
        
        participant.experiment.vasStartPosition       = repmat([15 85],1,ceil(participant.experiment.ntrials/2));
        participant.experiment.vasStartPosition       = participant.experiment.vasStartPosition(randperm(numel(participant.experiment.vasStartPosition)));

        
        % data vars
        
        participant.data.stimlevel = NaN(1,participant.experiment.ntrials);
        participant.data.stimvalue = NaN(1,participant.experiment.ntrials);
        participant.data.vasrate   = NaN(1,participant.experiment.ntrials);
        
        participant.data.eventTimes = [];
        for i = 1:participant.experiment.ntrials
            participant.data.eventTimes(i).trialStartTime = 0.0;
            participant.data.eventTimes(i).stimOnset = 0.0;
            participant.data.eventTimes(i).vasOnset = 0.0;
            participant.data.eventTimes(i).vasEnd = 0.0;
            participant.data.eventTimes(i).vasRT = 0.0;
            participant.data.eventTimes(i).trialEndTime = 0.0;
        end
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
        l2 = 75;
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
        DrawFormattedText(participant.settings.ptb.vas_sprite(1),'not',xl-29,yb+l1);
        DrawFormattedText(participant.settings.ptb.vas_sprite(1),'at all',xl-26,yb+l2);
        DrawFormattedText(participant.settings.ptb.vas_sprite(1),'worst',xr-30,yb+l1);
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
        settings.window      = round(H*4/3);
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
        WaitKeyPress(participant.settings.keyBindings.space);
        Screen('Flip',participant.settings.window);
    end

    function CyclePressure
        DrawFormattedText(participant.settings.window,'Please allow your head to settle into\n\na comfortable, stable position\n\nwith very little movement\n\nbetween inflations and deflations.','center',participant.settings.ptb.mid(2) - 100);
        Screen('Flip',participant.settings.window);
        
        for i=1:3
            fwrite(participant.settings.conf.udp_t, '0.08, t');
            WaitSecs(15.0);
            fwrite(participant.settings.conf.udp_t, '0.20, t');
            WaitSecs(15.0)
        end
        
    end

    % New block screen
    function StartNewMRIBlock(z)
        if z==1
            dstr = sprintf('Please wait.');
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
            participant.data.mri.firstMRITriggerPulse(z) = WaitKeyPress(participant.settings.keyBindings.mri); % get first MR volume
        else 
            KbQueueFlush;
            participant.data.mri.firstMRITriggerPulse(z) = WaitKeyPress(participant.settings.keyBindings.space); % manual start
        end
        Screen('Flip',participant.settings.window); % start of each block
        participant.data.mri.experimentStart(z) = WaitSecs(participant.settings.mri.tr * participant.settings.mri.ndummies); % wait 15 TR's for actual start
    end

    % run single trial
    function RunTrial(x)
        
        participant.data.stimlevel(x) = participant.experiment.stimlevel(x);
        participant.data.stimdur(x)   = participant.settings.timings.stim(x);
        participant.data.stimvalue(x) = participant.experiment.stimset(participant.experiment.stimlevel(x));
        participant.data.eventTimes(x).trialStartTime = GetSecs;

        % show fixation
        Screen('FillOval', participant.settings.window, participant.settings.conf.black, participant.settings.ptb.fix, participant.settings.ptb.fix_r+20);
        participant.data.eventTimes(x).stimOnset = Screen('Flip',participant.settings.window); % fixation on
        
        %pressure increase
        sendUDP(x);
        if participant.settings.mri.fmrion
            %outp(participant.settings.conf.b_port,participant.settings.conf.b_sigstim); WaitSecs(0.05);outp(participant.settings.conf.b_port,0); % biopac trigger
        end
                    
        % get pain rating while balloon is inflated
        participant.data.eventTimes(x).vasOnset = WaitSecs('UntilTime', participant.data.eventTimes(x).trialStartTime+participant.settings.timings.stim(x)-participant.settings.ptb.slack);
        GetVASRatings(x,participant.data.eventTimes(x).vasOnset+participant.settings.timings.vas(x));
        
        Screen('FillOval', participant.settings.window, participant.settings.conf.black, participant.settings.ptb.fix, participant.settings.ptb.fix_r+20);
        participant.data.eventTimes(x).vasEnd = Screen('Flip',participant.settings.window);
        
        % wait for stimulus end
        participant.data.eventTimes(x).trialEndTime = WaitSecs('UntilTime', participant.data.eventTimes(x).trialStartTime+participant.settings.timings.stim(x) + participant.settings.timings.vas(x) - participant.settings.ptb.slack);
        participant.data.eventTimes(x).vasRT(x)  = participant.data.eventTimes(x).vasEnd - participant.data.eventTimes(x).vasOnset - 0.016;
        %WaitSecs(0.1); %Trying to resolve bladder control issues.
    end

    % send trigger to pressure device
    function sendUDP(xx)
        stim = sprintf('%.2f, t', participant.data.stimvalue(xx));
        fwrite(participant.settings.conf.udp_t, stim);
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
            %outp(participant.settings.conf.b_port,participant.settings.conf.b_sigrate); WaitSecs(0.05);outp(participant.settings.conf.b_port,0); % biopac trigger
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
            participant.data.vasrate(tt) = (cursorpos(1) - participant.settings.vas.cposmaxl(1))/participant.settings.vas.cstep;
            % re-draw
            Screen('DrawTexture', participant.settings.window,  participant.settings.ptb.vas_sprite(1));
            DrawFormattedText(participant.settings.window, participant.settings.ptb.qstr{1},'center',participant.settings.ptb.mid(2)+tvoff);
            Screen('FillRect',participant.settings.window, cursorcol, cursorpos + [-4 0 4 0]);
            Screen('Flip', participant.settings.window);
        end
    end

    % cleanup, close ptb
    function cleanup
        try
            fwrite(participant.settings.conf.udp_t, '0.00, s');
            fwrite(participant.settings.conf.udp_t, '0.00, r');
            fclose(participant.settings.conf.udp_t);
            fclose(participant.settings.conf.udp_r);
        catch
             warning('could not close UDP ports');  
        end
        ListenChar(0); KbQueueRelease;
        ShowCursor;
        DrawFormattedText(participant.settings.window, 'Task complete. Please wait.','center',participant.settings.ptb.mid(2));
        Screen('Flip', participant.settings.window);
        WaitKeyPress(participant.settings.keyBindings.space);
        Screen('CloseAll');
        clear Screen;
    end

end