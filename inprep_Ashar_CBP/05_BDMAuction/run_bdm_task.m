function data = run_bdm_task(subject,day)

if nargin<1, subject=999; end
if nargin<2, day=7; end
rng('shuffle','twister');

debug     = 0;   % ptb Debugging
participant         = [];

try
    % init experiment/ptb
    ptbInit;
    
    % announce new block
    KbQueueStart;
    StartNewMRIBlock(1);
    
    % run trials
    for trial=1:participant.experiment.ntrials
        RunTrial(trial)
        save(fullfile(participant.settings.path.tmp,sprintf('sub-%04d_ses-%02d_task-bdm_events_tmp.mat',subject,day)),'participant');
    end
    KbQueueStop; 
    
    % do the BDM auction
    RunTrialAuction;

    % return data
    data = participant;
    
    % finish up
    save(fullfile(participant.settings.path.data,sprintf('sub-%04d_ses-%02d_task-bdm_events.mat',subject,day)),'participant');
    cleanup;
    
catch
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
        participant.subject           = subject;
        participant.date              = datestr(now);
        if ismac
            [~, hostname] = system('scutil --get ComputerName');
        else
            [~, hostname]       = system('hostname');
        end
        participant.experiment.hostname      = deblank(hostname);
                
        participant.experiment.nblocks           = 1;
        participant.experiment.ntrials           = 30;
        participant.experiment.trialsPerBlock  = participant.experiment.ntrials/participant.experiment.nblocks;
        participant.experiment.trialLengthValues = repmat([1:1:10],1,participant.experiment.ntrials/10);
        participant.experiment.trialLengthValues = participant.experiment.trialLengthValues(randperm(numel(participant.experiment.trialLengthValues)));

        % paths
        participant.settings.path.root         = pwd;
        participant.settings.path.data         = fullfile(participant.settings.path.root,'data');
        participant.settings.path.tmp          = fullfile(participant.settings.path.root,'data','tmp');
        if ~isdir(participant.settings.path.data), mkdir(participant.settings.path.data); end
        if ~isdir(participant.settings.path.tmp), mkdir(participant.settings.path.tmp); end
        
        % screen settings
        participant.settings.conf.oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
        participant.settings.ptb.screenID = max(Screen('Screens'));
        GetSecs; WaitSecs(0.01);
        
        % get settings.window colors
        participant.settings.conf.white = WhiteIndex(participant.settings.ptb.screenID); % pixel value for white
        participant.settings.conf.black = BlackIndex(participant.settings.ptb.screenID); % pixel value for black
        participant.settings.conf.gray  = (participant.settings.conf.white+participant.settings.conf.black)/2;
        participant.settings.conf.cursorcol = {[],[0 0 0],[0 0 0]};
        participant.settings.ptb.bg     = participant.settings.conf.gray;
        
        % open screen
        [participant.settings.window, participant.settings.ptb.rect]  = Screen(participant.settings.ptb.screenID, 'OpenWindow',participant.settings.ptb.bg);
        
        % VAS setup
        % randomize the starting position for auction VAS
        participant.experiment.vasInit       = repmat([15 85],1,ceil(participant.experiment.ntrials/2));
        participant.experiment.vasInit       = participant.experiment.vasInit(randperm(numel(participant.experiment.vasInit)));
        
        % screen properties
        Screen('BlendFunction', participant.settings.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        participant.settings.ptb.slack                 = Screen('GetFlipInterval',participant.settings.window)./2;
        [participant.settings.ptb.width, participant.settings.ptb.height] = Screen('WindowSize', participant.settings.ptb.screenID);
        participant.settings.ptb.mid                   = [ participant.settings.ptb.width./2 participant.settings.ptb.height./2];
        participant.settings.ptb.fix_r                 = 8;
        participant.settings.ptb.settings.fix          = [participant.settings.ptb.mid-participant.settings.ptb.fix_r participant.settings.ptb.mid+participant.settings.ptb.fix_r];
        participant.settings.fix                       = participant.settings.ptb.settings.fix;
        participant.settings.ptb.fontsize              = 36;
        participant.settings.ptb.fontcolor             = participant.settings.conf.black;
        participant.settings.ptb.fontstyle             = 0;
        participant.settings.ptb.fontname              = 'Arial';
   
        % set text style
        Screen('Preference', 'DefaultFontName','Arial');
        Screen('TextSize',  participant.settings.window, participant.settings.ptb.fontsize);
        Screen('Preference', 'DefaultFontStyle',participant.settings.ptb.fontstyle);
        
        createSprites;
        Screen('Flip',participant.settings.window);
        
        % key bindings
        KbName('UnifyKeyNames');
        participant.settings.keyBindings.confirm      = KbName('Return');
        participant.settings.keyBindings.start        = KbName('y');
        participant.settings.keyBindings.quit         = KbName('n');
        participant.settings.keyBindings.space        = KbName('SPACE');
        participant.settings.keyBindings.esc          = KbName('ESCAPE');
        participant.settings.keyBindings.mri          = KbName('5%'); 
        participant.settings.keyBindings.keylist      = zeros(256,1);
        participant.settings.keyBindings.keylist(participant.settings.keyBindings.mri) = 1;
        
        % mouse / trackball setup
        [mice,  ~] = GetMouseIndices('masterPointer');
        participant.settings.ptb.mouse        = mice(1); % adapt
        SetMouse(participant.settings.ptb.mid(1), participant.settings.ptb.mid(2),participant.settings.window,participant.settings.ptb.mouse); % set mouse to center
        KbCheck(-1); % check all settings.keyBindings released;
        if ~debug, HideCursor(participant.settings.ptb.screenID); end 
        KbQueueCreate([],participant.settings.keyBindings.keylist);

        % data vars
        participant.data.taskInitializeTime       = NaN;
        participant.data.eventTimes         = NaN(3,participant.experiment.ntrials);  
        participant.data.decision_time = NaN(1,participant.experiment.ntrials);
        participant.data.trialStartTime = zeros(1,participant.experiment.ntrials);
        participant.data.completedTrial= zeros(1,participant.experiment.ntrials);
        participant.data.trialDuration = NaN(1,participant.experiment.ntrials);
        
    end

    % wait for keyboard input
    function [KeyTime, keyCode] = WaitKeyPress(kID)
        while KbCheck(-1); end  % Wait until all settings.keyBindings are released.
        
        while 1
            % Check the state of the keyboard.
            [ keyIsDown, KeyTime, keyCode ] = KbCheck(-1);
            % If the user is pressing a key, then display its code number and name.
            if keyIsDown
                
                if keyCode(participant.settings.keyBindings.esc)
                    cleanup;
                elseif keyCode(kID)
                    break;
                end
            end
        end
    end

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
        % DrawFormattedText(participant.settings.ptb.vas_sprite(1),'no pain',xl-29,yb+l1);
        DrawFormattedText(participant.settings.ptb.vas_sprite(1),'$0',xl-26,yb+l2);
        % DrawFormattedText(participant.settings.ptb.vas_sprite(1),'worst pain',xr-30,yb+l1);
        DrawFormattedText(participant.settings.ptb.vas_sprite(1),'$10',xr-29,yb+l2);
        
       
    end

    function GetVASRatings(tt,tmax)      
        tvoff     = -90;
        xinit     = participant.experiment.vasInit(tt)*participant.settings.vas.cstep;
        cursorpos = participant.settings.vas.cposmaxl + [xinit 0 xinit 0];
        cursorcol = [0 0 0]; % [200 0 0]; % red
        mX        = cursorpos(1); mY = cursorpos(2);
        SetMouse(mX, mY); % set mouse to cursorpos
        Screen('DrawTexture', participant.settings.window, participant.settings.ptb.vas_sprite(1));
        Screen('TextSize', participant.settings.window, participant.settings.ptb.fontsize-4);
        DrawFormattedText(participant.settings.window,participant.settings.ptb.qstr{1},'center',participant.settings.ptb.mid(2)+tvoff);
        Screen('FillRect',participant.settings.window, cursorcol, cursorpos + [-3 0 3 0]);
        Screen('Flip', participant.settings.window);
        
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
            cursorpos([1 3]) = mX;
            % watch end of scale
            if cursorpos(1) < participant.settings.vas.cposmaxl(1), 
                cursorpos([1 3]) = participant.settings.vas.cposmaxl(1);
            elseif cursorpos(1) > participant.settings.vas.cposmaxr(1), 
                cursorpos([1 3]) = participant.settings.vas.cposmaxr(1);
            end
            SetMouse(round(cursorpos(1)), mY);
            participant.data.vasrate(tt) = round((cursorpos(1) - participant.settings.vas.cposmaxl(1))/participant.settings.vas.cstep/10);
            % re-draw
            Screen('DrawTexture', participant.settings.window,  participant.settings.ptb.vas_sprite(1));
            DrawFormattedText(participant.settings.window, participant.settings.ptb.qstr{1},'center',participant.settings.ptb.mid(2)+tvoff);
            DrawFormattedText(participant.settings.window,sprintf('Current Bid: $%d', round((cursorpos(1) - participant.settings.vas.cposmaxl(1))/participant.settings.vas.cstep/10)),'center',participant.settings.ptb.mid(2) + 100);
            Screen('FillRect',participant.settings.window, cursorcol, cursorpos + [-4 0 4 0]);
            Screen('Flip', participant.settings.window);
        end
    end

    % New block screen
    function StartNewMRIBlock(z)
        if z==1
            dstr = sprintf('Please start the task with SPACE');
        else
            dstr = sprintf('Please wait for the experimenter.\n\nWe will start the next block soon.');
        end
        Screen('TextFont', participant.settings.window, participant.settings.ptb.fontname);
        DrawFormattedText(participant.settings.window,dstr,'center',participant.settings.ptb.mid(2) - 50);
        Screen('Flip',participant.settings.window);
        KbQueueFlush;
        participant.data.taskInitializeTime(z) = WaitKeyPress(participant.settings.keyBindings.space); % manual start
        % participant.data.maxTrialTime(z) = participant.data.taskInitializeTime + participant.experiment.taskDuration;
    end

    % run single trial
    function RunTrial(x)
        participant.data.trialStartTime(x)       = GetSecs;
        
        % store common strings
        participant.settings.ptb.qstr = {sprintf('How much would you pay to avoid %d minutes of pain?', participant.experiment.trialLengthValues(x))};
        participant.settings.ptb.sstr = {'pain'};
        
        GetVASRatings(x,participant.data.trialStartTime(x)+600);
        participant.data.decisionTime(x) = GetSecs - participant.data.trialStartTime(x);
        
        % short break
        Screen('Flip',participant.settings.window);
        pause(1);   
    
    end


    % auction one trial
    function RunTrialAuction
        % draw the random price
        price = randi(10);
        % draw a random trial number
        trial_num = randi(30);
        trial_length = participant.experiment.trialLengthValues(trial_num);
        trial_bid = participant.data.vasrate(trial_num);
        
        % record auction info
        participant.data.selectedAuction = trial_num;
        participant.data.selectedSubjectBid = trial_bid;
        participant.data.selectedPainDuration = trial_length;
        participant.data.randomNumber = price;
        
        string1 = sprintf('The trial randomly selected was for %d minutes of pain (trial #%d).\nYour bid was $%d and the random number was %d.', trial_length, trial_num, trial_bid, price);
        
        if price > trial_bid
             string2 = sprintf('Your bid was lower than the determined price. You will experience the pain and earn $10.');
            participant.data.experiencedPain = 1;
            participant.data.earned = 10;
        else
            string2 = sprintf('Your bid was higher than the price. You will pay $ %d and avoid this pain.', price);
            participant.data.experiencedPain = 0;
            participant.data.earned = (10 - price);
        end
        
        % call experimenter back in
        string0 = 'Done with all trials. Please call the experimenter';
        DrawFormattedText(participant.settings.window,string0,'center',participant.settings.ptb.mid(2));
        Screen('Flip',participant.settings.window);
        WaitKeyPress(participant.settings.keyBindings.space);

        % show auction results
        DrawFormattedText(participant.settings.window,string1,'center',participant.settings.ptb.mid(2) - 100);
        DrawFormattedText(participant.settings.window,string2,'center',participant.settings.ptb.mid(2));
        Screen('Flip',participant.settings.window);
        WaitKeyPress(participant.settings.keyBindings.space);
        
        % print to command window;
        clc;
        fprintf(1,'\n%s\n\n%s\n',string1,string2);
    end

    % cleanup, close settings.ptb
    function cleanup
        ListenChar(0); KbQueueRelease;
        data = participant;
        ShowCursor;
        Screen('CloseAll');
        clear Screen;
    end

end