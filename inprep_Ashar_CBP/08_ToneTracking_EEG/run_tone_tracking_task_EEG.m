function data = run_tone_tracking_task_EEG(subject,day)

if nargin<1, subject=9999; end
if nargin<2, day=7; end
    
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
    
    SetUpTone;
    
    % Instructions
    ShowInstructions;
    
    % announce new block
    KbQueueStart;
    StartNewMRIBlock(1);
    
    % start the sound
    sound(participant.data.tone, participant.data.tone_samplingfreq);

    % get continuous ratings 
    GetContinuousVASRatings(GetSecs + (37*20 + 3)); %show VAS for full length, with a little extra buffer
          
    DrawFormattedText(participant.settings.window, 'Data collection finished. Please wait for clean-up.','center',participant.settings.ptb.mid(2)+tvoff);
    Screen('Flip', participant.settings.window);
    clear sound
    
    KbQueueStop;
   
    % return data
    data = participant;
    
    % finish up
    save(fullfile(participant.settings.path.data,sprintf('sub-%04d_ses-%02d_task-tonetracking_events_EEG.mat',subjectnum,day)),'participant');
    cleanup;  %  will also stop the bladder and close the log file
    
catch RUN
    % save data thus far
    RUN
    save(fullfile(participant.settings.path.tmp,sprintf('sub-%04d_ses-%02d_task-tonetracking_events_tmp_EEG.mat',subjectnum,day)),'participant');
    cleanup;
    data = RUN;
end

% subfunctions
    function SetUpTone

        %% load in their previous pain ratings and timestamps
        prevfile = fullfile('..', '07_BackPain_EEG', 'data', sprintf('sub-%04d_ses-%02d_task-chronic_events_EEG.mat',subjectnum,day));
        if ~exist(prevfile, 'file')
            warning('Cannot find data from the EEG task to match the tone to: %s does not exist', prevfile);
            error('Cannot find data from the EEG task to match the tone to: %s does not exist', prevfile);
        end
        prev = load(prevfile,'participant');
        
        ratings = prev.participant.data.vasrate;
        ratings = reshape(ratings', size(ratings,1)*size(ratings,2), 1);
        ratings = ratings(~isnan(ratings));

        timestamps = prev.participant.data.vas_timestamp;
        timestamps = reshape(timestamps', size(timestamps,1)*size(timestamps,2), 1);
        timestamps = timestamps(~isnan(timestamps));
        timestamps = timestamps - timestamps(1); % start at 0
        
        %% create an even tone.  (to stop the sound, do `clear sound`)
        amp=.01;
        fs=1000;  % sampling frequency
        duration=timestamps(end); % 37sec * 20 trials = about 740sec. get last recorded timestamp to get exact.
        freq=320; % nice tone for this fs
        values=0:1/fs:duration;
        tone=amp*sin(2*pi* freq*values);

        %% interpolate the ratings to the sampling frequency of the tone
        ratings_interp = interp1(timestamps, ratings, 0:1/fs:duration ); 

        % modulate tone volume by pain rating in previous task
        tone_mod = tone .* ratings_interp/100;
        
        % save. manually "compress" so doesn't take a ton of disk space
        % compression -> sample every ~350 data points
        % participant.data.compression_factor = 350; % this is approx matched to the frequency with which we have rating data (slightly higher freq), will come to about 60Hz
        participant.data.tone = tone_mod; %interp1(1:length(tone_mod), tone_mod, 1:participant.data.compression_factor:length(tone_mod));
        participant.data.tone_samplingfreq = fs;
        participant.data.tone_duration = duration;
        participant.data.tone_amplitude = ratings_interp; %interp1(1:length(ratings_interp), ratings_interp, 1:participant.data.compression_factor:length(ratings_interp));
        
        % helpful for double checking code above:
        %   i=30; [ratings(1:i) timestamps(1:i)]
        %   figure; plot(tone_mod), xlim([0 900000])
    end

    function ptbInit
        AssertOpenGL;
        commandwindow;
        if debug
            ListenChar(0);
            PsychDebugWindowConfiguration;
        end
        % basic infos
        load('../04_BackPain/trials/backpain_trials_main','r');
        participant.subject           = subject;
        participant.date              = datestr(now);
        if ismac
            [~, hostname] = system('scutil --get ComputerName');
        else
            [~, hostname]       = system('hostname');
        end
        participant.experiment.hostname      = deblank(hostname);
                
        participant.experiment.nblocks           = 1;
        participant.experiment.ntrials           = 1;
        participant.experiment.trials_per_block  = 1;
           
        participant.experiment.nlevel        = NaN;
        participant.experiment.levels        = NaN;
        
        
        % subject randomized info
        tsel = 1:participant.experiment.ntrials;
        
        % paths
        participant.settings.path.root         = pwd;
        participant.settings.path.data         = fullfile(participant.settings.path.root,'data');
        participant.settings.path.tmp          = fullfile(participant.settings.path.root,'data','tmp');
        if ~isdir(participant.settings.path.data), mkdir(participant.settings.path.data); end
        if ~isdir(participant.settings.path.tmp), mkdir(participant.settings.path.tmp); end


        % Common strings
        participant.settings.ptb.qstr = {'How loud? Please rate continuously'};
        participant.settings.ptb.sstr = {'loudness'};
        
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
        participant.settings.mri.fmrion        = 0; % strcmp(participant.experiment.hostname,'INC-DELL-002'); % adapt
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
        
        participant.experiment.vasStartPosition       = 15; 
        participant.experiment.vasStartPosition       = participant.experiment.vasStartPosition(randperm(numel(participant.experiment.vasStartPosition)));

        
        % data vars
        
        
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
        DrawFormattedText(participant.settings.ptb.vas_sprite(1),'extremely',xr-30,yb+l1);
        %DrawFormattedText(participant.settings.ptb.vas_sprite(1),'imaginable',xr-29,yb+l2);
        
       
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
            ok = 1;
            while ok == 1
                [mX, ~, buttons] = GetMouse(participant.settings.window);
                ok = ~any(buttons);
            end
            
            if sp == 3  % play a 5 sec sound before starting, during instructions
                
                %% create an even tone for 5 sec  (to stop the sound, do `clear sound`)
                amp=.01;
                fs= 20500;  % sampling frequency
                duration= 5; % 37sec * 20 trials = about 740sec. get last recorded timestamp to get exact.
                freq=320; % nice tone for this fs
                values=0:1/fs:duration;
                tone=amp*sin(2*pi* freq*values);                
                
                %% create 5 sec sinusoid covering full range
                triangle = sin( linspace(0, pi, length(tone))); %linearly sample space from 0 to pi
                
                % modulate tone volume by triangle shape
                tone_mod = tone .* triangle;
                sound(tone_mod, fs);
                pause(duration);
                
            end
        end
        %WaitKeyPress(participant.settings.keyBindings.space);
        Screen('Flip',participant.settings.window);
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

    % get continuous VAS ratings
    function GetContinuousVASRatings(tmax)      
        tvoff     = -90;
        xinit     = participant.experiment.vasStartPosition(1)*participant.settings.vas.cstep;
        cursorpos = participant.settings.vas.cposmaxl + [xinit 0 xinit 0];
        cursorcol = [0 0 0]; % [200 0 0]; % red
        mX        = cursorpos(1); mY = cursorpos(2);
       % SetMouse(mX, mY); % set mouse to cursorpos
        Screen('DrawTexture', participant.settings.window, participant.settings.ptb.vas_sprite(1));
        Screen('TextSize', participant.settings.window, participant.settings.ptb.fontsize-4);
        DrawFormattedText(participant.settings.window,participant.settings.ptb.qstr{1},'center',participant.settings.ptb.mid(2)+tvoff);
        Screen('FillRect',participant.settings.window, cursorcol, cursorpos + [-3 0 3 0]);
        Screen('Flip', participant.settings.window);
        
        i = 1;
        tstamp = GetSecs;
        while tstamp < tmax
                        
            % check keyboard for escape char
            [ keyIsDown, ~, keyCode ] = KbCheck(-1);
            if keyIsDown && keyCode(participant.settings.keyBindings.esc)
                cleanup;
            end
            
            % get mouse position
            [mX, ~, buttons] = GetMouse(participant.settings.window);
            
            %if participant.settings.mri.fmrion
            %    cursorpos([1 3]) = cursorpos([1 3]) + (mX-cursorpos([1 3]))*2;
            %    SetMouse(cursorpos(1), mY);
            %else
                cursorpos([1 3]) = mX;
            %end
            
            % watch end of scale
            if cursorpos(1) < participant.settings.vas.cposmaxl(1), 
                cursorpos([1 3]) = participant.settings.vas.cposmaxl(1);
            elseif cursorpos(1) > participant.settings.vas.cposmaxr(1), 
                cursorpos([1 3]) = participant.settings.vas.cposmaxr(1);
            end
            SetMouse(round(cursorpos(1)), mY);
            participant.data.vasrate(i,1) = (cursorpos(1) - participant.settings.vas.cposmaxl(1))/participant.settings.vas.cstep;
            participant.data.vas_timestamp(i,1) = tstamp;
            
            % re-draw (necessary?)
            Screen('DrawTexture', participant.settings.window,  participant.settings.ptb.vas_sprite(1));
            DrawFormattedText(participant.settings.window, participant.settings.ptb.qstr{1},'center',participant.settings.ptb.mid(2)+tvoff);
            Screen('FillRect',participant.settings.window, cursorcol, cursorpos + [-4 0 4 0]);
            Screen('Flip', participant.settings.window);
            
            % save data along the way, every 2000 loop iterations
            if mod(i,2000)==0
                save(fullfile(participant.settings.path.tmp,sprintf('sub-%04d_ses-%02d_task-tonetracking_events_tmp_EEG.mat',subjectnum,day)),'participant');
            end
            
            tstamp = GetSecs;
            i = i+1;
            
        end
    end

 % give the user a few secs to get oriented with the scale
    function InitContinuousVASRatings(tmax)      
        tvoff     = -90;
        xinit     = participant.experiment.vasStartPosition(1)*participant.settings.vas.cstep;
        cursorpos = participant.settings.vas.cposmaxl + [xinit 0 xinit 0];
        cursorcol = [0 0 0]; % [200 0 0]; % red
        mX        = cursorpos(1); mY = cursorpos(2);
       % SetMouse(mX, mY); % set mouse to cursorpos
        Screen('DrawTexture', participant.settings.window, participant.settings.ptb.vas_sprite(1));
        Screen('TextSize', participant.settings.window, participant.settings.ptb.fontsize-4);
        DrawFormattedText(participant.settings.window,participant.settings.ptb.qstr{1},'center',participant.settings.ptb.mid(2)+tvoff);
        Screen('FillRect',participant.settings.window, cursorcol, cursorpos + [-3 0 3 0]);
        Screen('Flip', participant.settings.window);
        
        tstamp = GetSecs;
        while tstamp < tmax
                        
            % check keyboard for escape char
            [ keyIsDown, ~, keyCode ] = KbCheck(-1);
            if keyIsDown && keyCode(participant.settings.keyBindings.esc)
                cleanup;
            end
            
            % get mouse position
            [mX, ~, buttons] = GetMouse(participant.settings.window);
            
            %if participant.settings.mri.fmrion
            %    cursorpos([1 3]) = cursorpos([1 3]) + (mX-cursorpos([1 3]))*2;
            %    SetMouse(cursorpos(1), mY);
            %else
                cursorpos([1 3]) = mX;
            %end
            
            % watch end of scale
            if cursorpos(1) < participant.settings.vas.cposmaxl(1), 
                cursorpos([1 3]) = participant.settings.vas.cposmaxl(1);
            elseif cursorpos(1) > participant.settings.vas.cposmaxr(1), 
                cursorpos([1 3]) = participant.settings.vas.cposmaxr(1);
            end
            SetMouse(round(cursorpos(1)), mY);
            
            % re-draw (necessary?)
            Screen('DrawTexture', participant.settings.window,  participant.settings.ptb.vas_sprite(1));
            DrawFormattedText(participant.settings.window, participant.settings.ptb.qstr{1},'center',participant.settings.ptb.mid(2)+tvoff);
            Screen('FillRect',participant.settings.window, cursorcol, cursorpos + [-4 0 4 0]);
            Screen('Flip', participant.settings.window);
            
            tstamp = GetSecs;
          
            
        end
    end


    % cleanup, close ptb
    function cleanup
        clear sound
            
        ListenChar(0); KbQueueRelease;
        ShowCursor;
        DrawFormattedText(participant.settings.window, 'Task complete. Please wait.','center',participant.settings.ptb.mid(2));
        Screen('Flip', participant.settings.window);
        WaitKeyPress(participant.settings.keyBindings.space);
        Screen('CloseAll');
        clear Screen;
    end

end