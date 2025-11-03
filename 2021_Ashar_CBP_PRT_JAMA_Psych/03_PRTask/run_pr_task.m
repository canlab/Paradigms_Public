function data = run_pr_task(subject,day)

if nargin<1, subject=999; end
if nargin<2, day=1; end
rng('shuffle','twister');

debug     = 0;   % ptb Debugging
participant         = [];

try
    % init experiment/ptb
    ptbInit(day);
    
    % announce new block
    KbQueueStart;
    StartNewMRIBlock(1);
    
    % run trials
    event = 0;
    while event <= participant.experiment.ntrials && participant.data.stoptask == 0
        event = event + 1;
        RunTrial(event)
        save(fullfile(participant.settings.path.tmp,sprintf('sub-%04d_ses-%02d_task-prt_events_tmp.mat',subject,day)),'participant');
    end
    KbQueueStop;
    
    % return data
    data = participant;
    
    % print results
    print_results;
    
    % finish up
    save(fullfile(participant.settings.path.data,sprintf('sub-%04d_ses-%02d_task-prt_events.mat',subject,day)),'participant');
    cleanup;
    
catch
    ShowCursor; cleanup;
    psychrethrow(psychlasterror);
end


% subfunctions
    function ptbInit(ses)
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
        participant.experiment.trialsPerBlock    = participant.experiment.ntrials/participant.experiment.nblocks;
        participant.experiment.startingKeyPresses= 30;
        participant.experiment.progressiveRatio  = 1.3;
        participant.experiment.rewardPerTrial    = 0.10; % see below for matching day1 rewards
        participant.experiment.keyPresses        = round([participant.experiment.startingKeyPresses participant.experiment.startingKeyPresses*cumprod(participant.experiment.progressiveRatio*ones(1,participant.experiment.ntrials-1))]);
        participant.experiment.taskDuration      = 15*60; % max decision duration in sec
        
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
        
        % screen properties
        Screen('BlendFunction', participant.settings.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        participant.settings.ptb.slack                 = Screen('GetFlipInterval',participant.settings.window)./2;
        [participant.settings.ptb.width, participant.settings.ptb.height] = Screen('WindowSize', participant.settings.ptb.screenID);
        participant.settings.ptb.mid                   = [ participant.settings.ptb.width./2 participant.settings.ptb.height./2];
        participant.settings.ptb.fix_r                 = 8;
        participant.settings.ptb.settings.fix          = [participant.settings.ptb.mid-participant.settings.ptb.fix_r participant.settings.ptb.mid+participant.settings.ptb.fix_r];
        participant.settings.fix                       = participant.settings.ptb.settings.fix;
        participant.settings.ptb.fontsize              = 26;
        participant.settings.ptb.fontcolor             = participant.settings.conf.black;
        participant.settings.ptb.fontstyle             = 0;
        participant.settings.ptb.fontname              = 'Arial';
   
        % set text style
        Screen('Preference', 'DefaultFontName','Arial');
        Screen('TextSize',  participant.settings.window, participant.settings.ptb.fontsize);
        Screen('Preference', 'DefaultFontStyle',participant.settings.ptb.fontstyle);
        
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
        participant.data.eventTimes               = NaN(3,participant.experiment.ntrials);  
        participant.data.decision_time            = NaN(1,participant.experiment.ntrials);
        participant.data.trialStartTime           = zeros(1,participant.experiment.ntrials);
        participant.data.completedTrial           = zeros(1,participant.experiment.ntrials);
        participant.data.timesPressed             = NaN(1,participant.experiment.ntrials);
        participant.data.trialDuration            = NaN(1,participant.experiment.ntrials);
        participant.data.breakPoint               = 0;
        participant.data.stoptask                 = 0;
        participant.data.subjectStoppedTask       = 0; % subject chooses to end task after a trial
        participant.data.taskAbortedDuringTrial   = 0; % task aborted while in a trial
        participant.data.trialChoice              = cell(1,participant.experiment.ntrials); % record subject choices
        
        
        %%% match day 1 rewards %%%
        % check if subject had 50c reward on day 1
        if ses>1
            
           fname = fullfile(participant.settings.path.data,sprintf('sub-%04d_ses-%02d_task-prt_events.mat',subject,1));
           if exist(fname, 'file')
                p = load(fname, 'participant');
                participant.experiment.rewardPerTrial = p.participant.experiment.rewardPerTrial;
           end
        end
        
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
        participant.data.maxTrialTime(z) = participant.data.taskInitializeTime + participant.experiment.taskDuration;
    end

    % run single trial
    function RunTrial(x)
        participant.data.taskStartTime(x)       = GetSecs;
        
        % show number of required kp
        Screen('TextSize', participant.settings.window, participant.settings.ptb.fontsize-4);
%         DrawFormattedText(participant.settings.window,sprintf('Number of key-presses: %d',participant.experiment.keyPresses(x)),'center',participant.settings.ptb.mid(2));
        DrawFormattedText(participant.settings.window,sprintf('You have earned already: $ %3.2f',participant.experiment.rewardPerTrial * (x-1)),'center',participant.settings.ptb.mid(2));
        DrawFormattedText(participant.settings.window,'Start: ''y''\nQuit: ''n''','center',participant.settings.ptb.mid(2)+50);
        participant.data.eventTimes(1,x) = Screen('Flip',participant.settings.window); % show fixation dot

        % accept or reject
        choice_open = 1;
        while choice_open
            [secs, kc] = KbWait([],2,participant.data.maxTrialTime);
            participant.data.decision_time(1,x) = GetSecs() - participant.data.eventTimes(1,x);
            
            % start the trial
            if kc(participant.settings.keyBindings.start)
                choice_open        = 0;
                participant.data.trialStartTime(x) = GetSecs();
                participant.data.trialChoice{x}  = 'start';
                
                % do presses
                CountKeyPresses(x);
                
                % brief pause;
                Screen('Flip',participant.settings.window);
                WaitSecs(1);
                Screen('Flip',participant.settings.window);
            
            % quit task
            elseif kc(participant.settings.keyBindings.quit)
                choice_open    = 0;
                participant.data.stoptask = 1;
                % record that subject chose to exit
                participant.data.subjectStoppedTask = 1;
                participant.data.trialChoice{x}  = 'stop';
                % show abort on screen
                DrawFormattedText(participant.settings.window,'Task ended.','center',participant.settings.ptb.mid(2));
                Screen('Flip',participant.settings.window);
                WaitSecs(2);
                %clc;
            end
        end 
    end

    function CountKeyPresses(tt)         
        k_max = participant.experiment.keyPresses(tt);
        n     = 0;
        % show count
        DrawFormattedText(participant.settings.window,sprintf('%5d',n),'center',participant.settings.ptb.mid(2));
        DrawFormattedText(participant.settings.window,sprintf('Earned: $ %3.2f',participant.experiment.rewardPerTrial * (tt-1)),'center',participant.settings.ptb.mid(2)+150);
        participant.data.eventTimes(2,tt) = Screen('Flip',participant.settings.window);
        % count presses
        while n<k_max && GetSecs<participant.data.maxTrialTime
            % collect characters
            [~, keyCode] = KbStrokeWait([], participant.data.maxTrialTime);
            % exit task during trial with ESC
            if keyCode(participant.settings.keyBindings.esc)
                participant.data.stoptask = 1;
                % record exit during trial
                participant.data.subjectStoppedTask = 1;
                participant.data.taskAbortedDuringTrial = 1;
                break;
            end
            % pressed space or enter - count button press
            if any(keyCode([participant.settings.keyBindings.confirm participant.settings.keyBindings.space]))
                n  = n + 1;
                participant.data.timesPressed(tt) = n;
                % update count
                % DrawFormattedText(participant.settings.window,sprintf('%5d / %5d',n,k_max),'center',participant.settings.ptb.mid(2));
                DrawFormattedText(participant.settings.window,sprintf('%5d',n),'center',participant.settings.ptb.mid(2));
                DrawFormattedText(participant.settings.window,sprintf('Earned: $ %3.2f',participant.experiment.rewardPerTrial * (tt-1)),'center',participant.settings.ptb.mid(2)+150);
                Screen('Flip',participant.settings.window);
            end
        end
        % save data
        participant.data.eventTimes(3,tt)   = GetSecs;
        participant.data.trialDuration(tt)  = participant.data.eventTimes(3,tt) - participant.data.eventTimes(2,tt);
        if n==k_max
            participant.data.completedTrial(tt) = 1;
            participant.data.breakPoint     = k_max;
            % show completion message
            DrawFormattedText(participant.settings.window,sprintf('You have completed all %d key presses\nand earned additional $ %3.2f.',participant.experiment.keyPresses(tt),participant.experiment.rewardPerTrial),'center',participant.settings.ptb.mid(2));
            Screen('Flip',participant.settings.window);
            WaitSecs(3);
        elseif GetSecs >= participant.data.maxTrialTime
            DrawFormattedText(participant.settings.window,'Task end.','center',participant.settings.ptb.mid(2));
            Screen('Flip',participant.settings.window);
            WaitSecs(2);
            participant.data.stoptask = 1;
        else
            DrawFormattedText(participant.settings.window,'Task aborted.','center',participant.settings.ptb.mid(2));
            Screen('Flip',participant.settings.window);
            WaitSecs(2);
            participant.data.stoptask = 1;
        end        
    end
    

    % print results for each subject
    function print_results
        participant.data.nTrialsCompleted = sum(participant.data.completedTrial);
        participant.data.moneyEarned = participant.data.nTrialsCompleted  * participant.experiment.rewardPerTrial;
        %clc;
        fprintf(1,'\n\nYou have completed %d trials and earned a total of %3.2f USD.\n\n',...
            participant.data.nTrialsCompleted, participant.data.moneyEarned);
    end

    % cleanup, close settings.ptb
    function cleanup
        ListenChar(0); KbQueueRelease;
        ShowCursor;
        Screen('CloseAll');
        clear Screen;
        disp(lasterr);
    end

end