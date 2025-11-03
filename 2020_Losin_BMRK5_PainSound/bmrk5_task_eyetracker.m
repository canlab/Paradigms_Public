% bmrk5 -- Losin & Ruzic 2013

% NOTES
% Shut off biopac for now, but got error that it couldn't initialize port

% TESTING
% make sure that stim-stim period is sufficient for thermode to be ready
%   for next trigger
% make sure that poststim period is sufficient for rating to return to
%   baseline
% check logging behavior
% is biopac triggering?

%% prepare MATLAB environment
clear; close all;

% path
addpath(genpath('support_files'));

% random number generator reset
rand('state',sum(100*clock)); %#ok


%% GLOBAL PARAMETERS
N_DUMMY_SCANS = 20;    % dummy scans past the first two hardcoded by seimens
TR = .46;
USE_DEVICE = 1;
USE_BIOPAC = 1;
BIOPAC_PULSE_WIDTH = 1;
USE_EYELINK = 0;

TRACKBALL_MULTIPLIER = 1; % this increases/decreases trackball sensitivity

SAMPLERATE = .1; % used in continuous ratings
KBSAMPRATE = .01; % this determines rate of keyboard sampling 
                  % (.005 seems too short, .01 seems adequate)
                  
BX_STARTING_PAUSE = 3;   % when running outside the scanner this determines how long the initial pause/fixation is

BGCOLOR = 128; %[128 128 128];
FGCOLOR = 255;

NRUNS = 4;

DURATION.cue = 1;
DURATION.rating = 7;
DURATION.ratingcue = .75;
DURATION.ratingfeedback = 0.5;
DURATION.trialwithratings = 47;
DURATION.trialwithoutratings = 28;

currexp = fullfile('support_files','current_experiment.mat');

RATINGTITLES = {'INTENSITY' 'UNPLEASANTNESS'};


%% GET INFO
desiredrun = input('Run (0: new, [1-4]: redo, blank: next run): ');
if desiredrun == 0
    fprintf('STARTING NEW SUBJECT\n')
    resp = upper(input('OK? (y/[n]) ','s')); if ~strcmp(resp,'Y'), fprintf('EXITING\n'); return; end
    
    if exist(currexp,'file'), delete(currexp); end
    
    % get info
    info.run = 1;
    %info.subnum = input('Subject Number: ');
    info.subjectid = input('Subject ID: ');
    %info.occasionid = input('Occasion ID: ');
    reply = upper(input('In scanner? (y/n) ','s'));
    if strcmp(reply,'N')
        USE_EYELINK = 0;
        info.scanner = 0;
    else
        info.scanner = 1;
    end
elseif isempty(desiredrun)
    load(currexp);
    info.run = info.run+1;
    %fprintf('    SUBJECT: %d\n',info.subnum);
    fprintf(' Subject ID: %d\n',info.subjectid);
    %Ffprintf('Occasion ID: %d\n',info.occasionid);
    fprintf('CURRENT RUN: %d\n',info.run);
    if info.run > NRUNS
        error('current run number (%d) exceeds total number of runs (%d)',info.run,NRUNS);
    end
    
    resp = upper(input('OK? (y/[n]) ','s')); if ~strcmp(resp,'Y'), fprintf('EXITING\n'); return; end
elseif any(1:4==desiredrun)
    load(currexp);
    info.run = desiredrun;
    %fprintf('    SUBJECT: %d\n',info.subnum);
    fprintf(' Subject ID: %d\n',info.subjectid);
    %fprintf('Occasion ID: %d\n',info.occasionid);
    fprintf('REDOING RUN: %d\n',info.run);
    resp = upper(input('OK? (y/[n]) ','s')); if ~strcmp(resp,'Y'), fprintf('EXITING\n'); return; end
else
    fprintf('INVALID INPUT: %d\n',info.run);
    return
end
clear desiredrun


% determine output filename
s = num2str(sprintf('%03d',info.subjectid));
r = num2str(sprintf('%02d',info.run));

subdir = fullfile('support_files','experiment_logs',['sub' s]);
if ~exist(subdir,'dir'), eval(['mkdir ' subdir]); end

logfile = fullfile(subdir,['bmrk5_log_sub' s '_run' r]);
envlogfile = fullfile(subdir,['bmrk5_env_sub' s '_run' r]);

clear r s

if exist(currexp,'file')
    save(currexp);
else
    %% TRIAL TYPES
    cuenumbers = [1 2 3]; %randperm(3);
    
    tt{1}.name = 'heat';
    tt{1}.t = [...
        1 1 84
        1 2 85
        1 3 86
        2 1 87
        2 2 88
        2 3 89];
    dv = [8 11]; tt{1}.duration = dv(tt{1}.t(:,1));
    tv = [47 48 49]; tt{1}.temp = tv(tt{1}.t(:,2));
    tt{1}.code = tt{1}.t(:,3);
    tt{1}.cuenum = cuenumbers(1);
    
    tt{2}.name = 'offset analgesia';
    tt{2}.t = [...
        1 90
        2 91
        3 92];
    tt{2}.temp = [47; 48; 49];
    tt{2}.duration = ones(1,size(tt{2}.t,1)) * 11;
    tt{2}.code = tt{2}.t(:,2);
    tt{2}.cuenum = cuenumbers(1);
    
    tt{3}.name = 'soundpain';
    tt{3}.t = [...
        1
        2
        3];
    tt{3}.intensity = [1; 2; 3];
    tt{3}.duration = ones(1,size(tt{3}.t,1)) * 11;
    % find files
    iname = {'L' 'M' 'H'};
    for i = 1:numel(tt{3}.intensity)
        tt{3}.file{i} = fullfile('support_files','sounds',sprintf('soundpain_%s',iname{tt{3}.intensity(i)}));  %#ok
    end
    tt{3}.cuenum = cuenumbers(2);
    
    % iads_neg_{L,M,H}_{sick,cry,disaster,attack}
    tt{4}.name = 'iads';
    tt{4}.t = [...
        2 1
        2 2
        2 3];
    vname = {'pos' 'neg'}; tt{4}.valence = vname(tt{4}.t(:,1))';
    aname = {'L' 'M' 'H'}; tt{4}.arousal = aname(tt{4}.t(:,2))';
    tt{4}.duration = ones(1,size(tt{4}.t,1)) * 11;
    tname = {'1' '2' '3' '4'};
    rorder = randperm(NRUNS);
    % find files
    for i = 1:numel(tt{4}.valence)
        basename = fullfile('support_files','sounds',sprintf('iads_%s_%s',tt{4}.valence{i},tt{4}.arousal{i}));
        for r = 1:NRUNS
            tt{4}.file{i,r} = sprintf('%s_%s',basename,tname{rorder(r)}); %#ok
        end
    end
    tt{4}.cuenum = cuenumbers(3);
    clear dv tv iname vname aname tname rorder basename i r
    
    %% TRIAL ORDER
    
    %     % for now just a random set
    %     for r = 1:4
    %         run(r).trials = []; %#ok
    %         for i=1:numel(tt)
    %             run(r).trials = [run(r).trials; [repmat(i,size(tt{i}.t,1),1) (1:size(tt{i}.t,1))']]; %#ok
    %             run(r).trials = sortrows([rand(size(run(r).trials,1),1) run(r).trials]); %#ok
    %             run(r).trials = run(r).trials(:,[2 3]); %#ok
    %         end
    %     end
    %
    %     clear r i
    
    for r = 1:NRUNS
        % random positions for offset analgesia, iads, and soundpain trials
        % divided into three parts
        trials = reshape(Shuffle(repmat([2 3 4]',1,3)),9,1);
        % random positions for the heat trials, divided into two parts
        halfway = 3 + randi(2);
        trials = [Shuffle([trials(1:halfway); ones(3,1)]); Shuffle([trials(halfway+1:end); ones(3,1)])];
        % add a column for type of trial within modality
        trials = [trials trials.*0]; %#ok
        % distribute heat trial types
        trials(trials(:,1)==1,2) = reshape(Shuffle(Shuffle([1 4; 2 5; 3 6]')'),6,1);
        % distribute offset analgesia, iads, and soundpain trial types
        for i = 2:4
            trials(trials(:,1)==i,2) = randperm(3);
        end
        
        run(r).trials = trials; %#ok
    end
    clear trials r i
    
    %% RATINGS
    nratings = [3 3 3 3]; %Shuffle([6 6 6 6]);
    x=[]; for i=1:4, x = [x; ones(nratings(i),1)*i]; end %#ok
    x = Shuffle(x);
    
    ttlist=[]; for t=1:3, n = size(tt{t}.t,1); ttlist = [ttlist; ones(n,1)*t (1:n)']; end %#ok
    % add column for run numbers
    ttlist = [ttlist x];
    % add column for rating type (1=intensity first, 2 = unpleasantness first)
    ttlist = [ttlist Shuffle(repmat([1 2],1,6))'];
    % add column for delay3 durations
    ttlist = [ttlist Shuffle(repmat([2 3 4]',4,1))];
    % add iads (all)
    rrate = Shuffle(repmat([1 2],1,6));
    n=1;
    for i=1:NRUNS
        rdelay = Shuffle([2 3 4]);
        m=1;
        for j = find(run(i).trials(:,1) == 4)'
            ttlist = [ttlist; [run(i).trials(j,:) i rrate(n) rdelay(m)]]; %#ok
            n=n+1; m=m+1;
        end
    end
    clear rrate n m x i j
    
    
    for r=1:NRUNS, run(r).ratings = zeros(size(run(r).trials,1),1); end %#ok
    for i = 1:size(ttlist,1)
        r = ttlist(i,3);
        t = run(r).trials(:,1) == ttlist(i,1) & run(r).trials(:,2) == ttlist(i,2);
        run(r).ratings(t,:) = ttlist(i,4); %#ok
        run(r).duration.postratingfix1(t) = ttlist(i,5); %#ok
    end
    clear r i t
    
    %% DELAY1 DURATIONS
    % delay 1
    % proportions: 8 4 2 1
    % durations: 1 2.5 4 5.5
    DURATION.delay1 = [...
        ones(8,1) * 1;...
        ones(4,1) * 2.5;...
        ones(2,1) * 4;...
        ones(1,1) * 5.5];
    for r=1:NRUNS
        run(r).duration.prestim = Shuffle(DURATION.delay1); %#ok
    end
    clear r
    
    %% ADD a hot first trial
    rorder = mod(randperm(4),2)+1;
    for r = 1:4
        run(r).trials = [1 6; run(r).trials]; %#ok
        run(r).duration.prestim = [1 ;run(r).duration.prestim]; %#ok
        run(r).ratings = [rorder(r); run(r).ratings]; %#ok
        run(r).duration.postratingfix1 = [0 run(r).duration.postratingfix1]; %#ok
    end
    
    
    %% TIMING
    % cue (0.5)
    % delay1 (with rating) (1 2.5 4 5.5)
    % stim   (with rating) (8 11)
    % delay2 (with rating) (20-x)
    % IF RATING
    %  rating1             (5)
    %  delay3              (8 10 12)
    %  rating2             (5)
    %  delay4              (45-x)
    
    j=0;
    j=j+1; o.cue=j;
    j=j+1; o.prestim=j;
    j=j+1; o.stim=j;
    j=j+1; o.rating(1)=j;
    j=j+1; o.postratingfix(1)=j;
    j=j+1; o.rating(2)=j;
    j=j+1; o.postratingfix(2)=j;
    
    for r = 1:4
        run(r).onsets = nan(size(run(r).trials,1),j); %#ok
        if info.scanner
            t = N_DUMMY_SCANS*TR;
        else
            t = BX_STARTING_PAUSE;
        end
        
        for trial = 1:size(run(r).trials,1)
            % cue
            run(r).onsets(trial,o.cue) = t; %#ok
            t = t + DURATION.cue;
            
            % delay1
            run(r).onsets(trial,o.prestim) = t; %#ok
            t = t + run(r).duration.prestim(trial);
            
            % stim
            run(r).onsets(trial,o.stim) = t; %#ok
            t = t + tt{run(r).trials(trial,1)}.duration(run(r).trials(trial,2));
            % post stim period
            t = t + DURATION.trialwithoutratings - (t-run(r).onsets(trial,o.cue));
            
            if run(r).ratings(trial)
                % rating1
                run(r).onsets(trial,o.rating(1)) = t; %#ok
                t = t + DURATION.rating;
                
                % delay3
                run(r).onsets(trial,o.postratingfix(1)) = t; %#ok
                t = t + run(r).duration.postratingfix1(trial);
                
                % rating2
                run(r).onsets(trial,o.rating(2)) = t; %#ok
                t = t + DURATION.rating;
                
                % delay 4
                run(r).onsets(trial,o.postratingfix(2)) = t; %#ok
                t = t + DURATION.trialwithratings - (t-run(r).onsets(trial,o.cue));
            end
        end
        run(r).onset.endscreen = t; %#ok
    end
    clear r trial t
    
    save(currexp);
end


%% SET FOR CURRENT RUN
trials = run(info.run).trials;
onsets = run(info.run).onsets;
ratings = run(info.run).ratings;
onset = run(info.run).onset;


%% CREATE TIMING MATRIX
j=0;
j=j+1; t.cue=j;
j=j+1; t.stim=j;
j=j+1; t.ratingcue(1)=j;
j=j+1; t.ratingstart(1)=j;
j=j+1; t.rating(1)=j;
j=j+1; t.ratingcue(2)=j;
j=j+1; t.ratingstart(2)=j;
j=j+1; t.rating(2)=j;

timings = nan(size(onsets,1),j);


%% INITIALIZE RATINGS
cratings = cell(size(onsets,1),1);
oratings{1} = nan(size(onsets,1),1);
oratings{2} = oratings{1};


%% PREPARE FOR INPUT
% Enable unified mode of KbName, so KbName accepts identical key names on
% all operating systems:
KbName('UnifyKeyNames');

% % define keys
% key.index = KbName('1!');
% key.middle = KbName('2@');
% key.ring = KbName('3#');
% key.pinkie = KbName('4$');
key.space = KbName('SPACE');
key.ttl = KbName('5%');
key.s = KbName('s');
% if info.scanner
%     mousebutton = 3;
% else
%     mousebutton = 1;
% end
mousebuttons = [1 3];

%% PREPARE DEVICES
if USE_DEVICE
    [ignore hn] = system('hostname'); hn=deblank(hn);
    addpath(genpath('\Program Files\MATLAB\R2012b\Toolbox\io32'));
    
    % set up thermode
    global THERMODE_PORT; %#ok
    if strcmp(hn,'INC-DELL-001')
        config_io;
        THERMODE_PORT = hex2dec('D050'); % this was copied from an E-prime program that worked on
        trigger_heat = str2func('TriggerHeat2');
    else
        THERMODE_PORT = digitalio('parallel','LPT1');
        addline(THERMODE_PORT,0:7,'out');
        trigger_heat = str2func('TriggerHeat');
    end
    
    % initialize biopac port
    if USE_BIOPAC
        global BIOPAC_PORT; %#ok
        if strcmp(hn,'INC-DELL-001')
            BIOPAC_PORT = hex2dec('E050');
            trigger_biopac = str2func('TriggerBiopac2');
        else
            BIOPAC_PORT = digitalio('parallel','LPT2');
            addline(BIOPAC_PORT,0:7,'out');
            trigger_biopac = str2func('TriggerBiopac');
        end
    end
    
    InitializePsychSound
end


%% PREPARE DISPLAY
% will break with error message if Screen() can't run
AssertOpenGL;

%%% prepare the screen
[window rect] = Screen('OpenWindow',0);
% paint black
Screen('FillRect',window,BGCOLOR);
HideCursor;

%%%START EYELINK STUFF
if USE_EYELINK
    
    commandwindow;
    
    dummymode=0;
    
    try
        % STEP 1
        % Added a dialog box to set your own EDF file name before opening
        % experiment graphics. Make sure the entered EDF file name is 1 to 8
        % characters in length and only numbers or letters are allowed.
        prompt = {'Enter tracker EDF file name (1 to 8 letters or numbers)'};
        dlg_title = 'Create EDF file';
        num_lines= 1;
        edfFile = sprintf('%d_%d.EDF',info.subjectid,info.run);
        fprintf('EDFFile: %s\n', edfFile );
        
        % STEP 2
        % Open a graphics window on the main screen
        % using the PsychToolbox's Screen function.
         fprintf('sceen will start\n');
         screenNumber=max(Screen('Screens'));
         fprintf('screen started\n');
%         [window, wRect]=Screen('OpenWindow', screenNumber, 0,[],32,2);
%         Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%         
        
        % STEP 3
        % Provide Eyelink with details about the graphics environment
        % and perform some initializations. The information is returned
        % in a structure that also contains useful defaults
        % and control codes (e.g. tracker state bit and Eyelink key values).
        el=EyelinkInitDefaults(window);
        
        
        
        % STEP 4
        % Initialization of the connection with the Eyelink Gazetracker.
        % exit program if this fails.
        
        if ~EyelinkInit(dummymode)
            fprintf('Eyelink Init aborted.\n');
            % cleanup;
            % function cleanup
            Eyelink('Shutdown');
            Screen('CloseAll');
            commandwindow;
            return;
        end
        
        % the following code is used to check the version of the eye tracker
        % and version of the host software
        sw_version = 0;
        [v vs]=Eyelink('GetTrackerVersion');
        fprintf('Running experiment on a ''%s''tracker.\n', vs );
        fprintf('tracker version v=%d\n', v);
        
        
        
        % open file to record data to
        i = Eyelink('Openfile', edfFile);
        if i~=0
            fprintf('Cannot create EDF file ''%s'' ', edffilename);
            % cleanup;
            % function cleanup
            Eyelink('Shutdown');
            Screen('CloseAll');
            commandwindow;
            return;
        end
        
        
        
        Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox demo-experiment''');
        [width, height]=Screen('WindowSize', screenNumber);
        
        
        % STEP 5
        % SET UP TRACKER CONFIGURATION
        % Setting the proper recording resolution, proper calibration type,
        % as well as the data file content;
        Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
        Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);
        % set calibration type.
        Eyelink('command', 'calibration_type = HV9');
        % set parser (conservative saccade thresholds)
        
        
        
        % set EDF file contents using the file_sample_data and
        % file-event_filter commands
        % set link data thtough link_sample_data and link_event_filter
        Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
        Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
        
        % check the software version
        % add "HTARGET" to record possible target data for EyeLink Remote
        if sw_version >=4
            Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,HTARGET,GAZERES,STATUS,INPUT');
            Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
        else
            Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
            Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
        end
        
        
        % allow to use the big button on the eyelink gamepad to accept the
        % calibration/drift correction target
        Eyelink('command', 'button_function 5 "accept_target_fixation"');
        
        % make sure we're still connected.
        if Eyelink('IsConnected')~=1 && dummymode == 0
            fprintf('not connected, clean up\n');
            % cleanup;
            % function cleanup
            Eyelink('Shutdown');
            Screen('CloseAll');
            commandwindow;
            return;
        end
        
        
        % STEP 6
        % Calibrate the eye tracker
        % setup the proper calibration foreground and background colors
        el.backgroundcolour = [128 128 128];
        el.calibrationtargetcolour = [0 0 0];
        
        % parameters are in frequency, volume, and duration
        % set the second value in each line to 0 to turn off the sound
        el.cal_target_beep=[600 0.5 0.05];
        el.drift_correction_target_beep=[600 0.5 0.05];
        el.calibration_failed_beep=[400 0.5 0.25];
        el.calibration_success_beep=[800 0.5 0.25];
        el.drift_correction_failed_beep=[400 0.5 0.25];
        el.drift_correction_success_beep=[800 0.5 0.25];
        
        %Setting target size as recommended by Marcu at Eyelink
        el.calibrationtargetsize = 1.8;
        el.calibrationtargetwidth = 0.2;
        
        % you must call this function to apply the changes from above
        EyelinkUpdateDefaults(el);
        
        % Hide the mouse cursor;
        Screen('HideCursorHelper', window);
        EyelinkDoTrackerSetup(el);
    catch exc
        %this "catch" section executes in case of an error in the "try" section
        %above.  Importantly, it closes the onscreen window if its open.
        % cleanup;
        % function cleanup
        getReport(exc,'extended')
        disp('EYELINK CAUGHT')
        Eyelink('Shutdown');
        Screen('CloseAll');
        commandwindow;
    end
    %%%EYELINK STUFF DONE
end

%%% configure screen
dspl.screenWidth = rect(3);
dspl.screenHeight = rect(4);
dspl.xcenter = dspl.screenWidth/2;
dspl.ycenter = dspl.screenHeight/2;

%%% create FIXATION screen
dspl.fixation.w = Screen('OpenOffscreenWindow',0);
% paint black
Screen('FillRect',dspl.fixation.w,BGCOLOR);
% add text
Screen('TextSize',dspl.fixation.w,60);
DrawFormattedText(dspl.fixation.w,'+','center','center',255);

%%% create INSTRUCTIONS screens
instr_files = dir(fullfile('support_files','images','Instructions*.bmp'));
for i = 1:numel(instr_files)
    halfheight = ceil((0.75*dspl.screenHeight)/2);
    halfwidth = ceil(halfheight/.75);
    dspl.instruct(i).rect = [[dspl.xcenter dspl.ycenter]-[halfwidth halfheight] [dspl.xcenter dspl.ycenter]+[halfwidth halfheight]];
    dspl.instruct(i).w = Screen('OpenOffscreenWindow',0);
    % paint black
    Screen('FillRect',dspl.instruct(i).w,BGCOLOR);
    % add instructions image
    dspl.instruct(i).imagefile = instr_files(i).name;
    image = imread(dspl.instruct(i).imagefile);
    texture = Screen('MakeTexture',window,image);
    Screen('DrawTexture',dspl.instruct(i).w,texture,[],dspl.instruct(i).rect);
end


% create SCALE screen for continuous rating
dspl.cscale.width = 964;
dspl.cscale.height = 252;
dspl.cscale.w = Screen('OpenOffscreenWindow',0);
% paint black
Screen('FillRect',dspl.cscale.w,BGCOLOR);
% add scale image
dspl.cscale.imagefile = which('bartoshuk_scale_clear_experience_larger.bmp');
image = imread(dspl.cscale.imagefile);
dspl.cscale.texture = Screen('MakeTexture',window,image);
% placement
dspl.cscale.rect = [...
    [dspl.xcenter dspl.ycenter]-[0.5*dspl.cscale.width 0.5*dspl.cscale.height] ...
    [dspl.xcenter dspl.ycenter]+[0.5*dspl.cscale.width 0.5*dspl.cscale.height]];
% shiftdown = ceil(dspl.screenHeight*0);
% dspl.cscale.rect = dspl.cscale.rect + [0 shiftdown 0 shiftdown];
Screen('DrawTexture',dspl.cscale.w,dspl.cscale.texture,[],dspl.cscale.rect);
% add title
Screen('TextSize',dspl.cscale.w,40);
DrawFormattedText(dspl.cscale.w,...
    'RATE WHAT YOU FEEL NOW',...
    'center',dspl.ycenter-270,255);

% create SCALE screen for overall intensity rating
dspl.oscale(1).width = 964;
dspl.oscale(1).height = 252;
dspl.oscale(1).w = Screen('OpenOffscreenWindow',0);
% paint black
Screen('FillRect',dspl.oscale(1).w,BGCOLOR);
% add scale image
dspl.oscale(1).imagefile = which('bartoshuk_scale_clear_experience_larger.bmp');
image = imread(dspl.oscale(1).imagefile);
dspl.oscale(1).texture = Screen('MakeTexture',window,image);
% placement
dspl.oscale(1).rect = [...
    [dspl.xcenter dspl.ycenter]-[0.5*dspl.oscale(1).width 0.5*dspl.oscale(1).height] ...
    [dspl.xcenter dspl.ycenter]+[0.5*dspl.oscale(1).width 0.5*dspl.oscale(1).height]];
% shiftdown = ceil(dspl.screenHeight*0);
% dspl.oscale(1).rect = dspl.oscale(1).rect + [0 shiftdown 0 shiftdown];
Screen('DrawTexture',dspl.oscale(1).w,dspl.oscale(1).texture,[],dspl.oscale(1).rect);
% add title
Screen('TextSize',dspl.oscale(1).w,40);
DrawFormattedText(dspl.oscale(1).w,...
    'OVERALL INTENSITY RATING',...
    'center',dspl.ycenter-270,255);

% create SCALE screen for overall unpleasantness rating
dspl.oscale(2).width = 964;
dspl.oscale(2).height = 252;
dspl.oscale(2).w = Screen('OpenOffscreenWindow',0);
% paint black
Screen('FillRect',dspl.oscale(2).w,BGCOLOR);
% add scale image
dspl.oscale(2).imagefile = which('bartoshuk_scale_clear_unpleasantness_larger.bmp');
image = imread(dspl.oscale(2).imagefile);
dspl.oscale(2).texture = Screen('MakeTexture',window,image);
% placement
dspl.oscale(2).rect = [...
    [dspl.xcenter dspl.ycenter]-[0.5*dspl.oscale(2).width 0.5*dspl.oscale(2).height] ...
    [dspl.xcenter dspl.ycenter]+[0.5*dspl.oscale(2).width 0.5*dspl.oscale(2).height]];
% shiftdown = ceil(dspl.screenHeight*0);
% dspl.oscale(2).rect = dspl.oscale(2).rect + [0 shiftdown 0 shiftdown];
Screen('DrawTexture',dspl.oscale(2).w,dspl.oscale(2).texture,[],dspl.oscale(2).rect);
% add title
Screen('TextSize',dspl.oscale(2).w,40);
DrawFormattedText(dspl.oscale(2).w,...
    'OVERALL UNPLEASANTNESS RATING',...
    'center',dspl.ycenter-270,255);

% determine cursor parameters for all scales
cursor.xmin = dspl.cscale.rect(1) + 123;
cursor.width = 709;
cursor.xmax = cursor.xmin + cursor.width;
cursor.size = 8;
cursor.center = cursor.xmin + ceil(cursor.width/2);
cursor.y = dspl.cscale.rect(4) - 41;
cursor.labels = cursor.xmin + [10 42 120 249 379];


% create POST-RUN Q SCALE screens
prqimgs = {'on_task_experiential.bmp' ...
    'on_task_narrative.bmp' ...
    'on_notask_experiential.bmp' ...
    'on_notask_narrative.bmp' ...
    'off_task_experiential.bmp' ...
    'off_task_narrative.bmp' ...
    'off_notask_experiential.bmp' ...
    'off_notask_narrative.bmp' ...
    'positivity.bmp' ...
    'negativity.bmp' ...
    'anxiety.bmp' ...
    'engaged.bmp' ...
    'sleepy.bmp'};
for i=1:numel(prqimgs)
    dspl.prqscale(i).w = Screen('OpenOffscreenWindow',0);
    % paint black
    Screen('FillRect',dspl.prqscale(i).w,BGCOLOR);
    % add scale image (prqimgs with no _'s will get run_state_larger)
    if any(regexp(prqimgs{i},'_'))
        dspl.prqscale(i).scaleimagefile = which('bartoshuk_scale_between_run_larger.bmp');
    else
        dspl.prqscale(i).scaleimagefile = which('bartoshuk_scale_between_run_state_larger.bmp');
    end
    image = imread(dspl.prqscale(i).scaleimagefile);
    dspl.prqscale(i).texture = Screen('MakeTexture',window,image);
    % add text
    dspl.prqscale(i).questimagefile = which(prqimgs{i});
    image = imread(dspl.prqscale(i).questimagefile);
    dspl.prqscale(i).qtexture = Screen('MakeTexture',window,image);
    % placement
    dspl.prqscale(i).rect = [...
        [dspl.xcenter dspl.ycenter]-[0.5*size(image,2) 0.5*size(image,1)] ...
        [dspl.xcenter dspl.ycenter]+[0.5*size(image,2) 0.5*size(image,1)]];
    Screen('DrawTexture',dspl.prqscale(i).w,dspl.prqscale(i).texture,[],dspl.prqscale(i).rect);
    Screen('DrawTexture',dspl.prqscale(i).w,dspl.prqscale(i).qtexture,[],dspl.prqscale(i).rect - [0 200 0 200]);
end
% determine cursor parameters
prqcursor.xmin = dspl.prqscale(1).rect(1) + 123;
prqcursor.width = 709;
prqcursor.xmax = prqcursor.xmin + prqcursor.width;
prqcursor.size = 8;
prqcursor.center = prqcursor.xmin + ceil(prqcursor.width/2);
prqcursor.y = dspl.prqscale(1).rect(4) - 41;

% initialize rating
prqlog.header = {'order' 'rating' 'starttime' 'responsetime'};
prqlog.questions = regexprep(prqimgs,'.bmp','')';
prqlog.data = nan(numel(dspl.prqscale),4);


cueshape = {'circle' 'triangle' 'square'};
for cs = 1:numel(cueshape)
    dspl.cuescreen(cs).w = Screen('OpenOffscreenWindow',0);
    % paint black
    Screen('FillRect',dspl.cuescreen(cs).w,BGCOLOR);
    dspl.cuescreen(cs).imagefile = fullfile('support_files','images',[cueshape{cs} '_cue.bmp']);
    image = imread(dspl.cuescreen(cs).imagefile);
    dspl.cuescreen(cs).rect = [[dspl.xcenter dspl.ycenter]-[.5*size(image,2) .5*size(image,1)] [dspl.xcenter dspl.ycenter]+[.5*size(image,2) .5*size(image,1)]];
    dspl.cuescreen(cs).texture = Screen('MakeTexture',window,image);
    Screen('DrawTexture',dspl.cuescreen(cs).w,dspl.cuescreen(cs).texture,[],dspl.cuescreen(cs).rect);
end

%%% create no device screen
dspl.nodevice.w = Screen('OpenOffscreenWindow',0);
% paint black
Screen('FillRect',dspl.nodevice.w,BGCOLOR);
Screen('TextSize',dspl.nodevice.w,72);
DrawFormattedText(dspl.nodevice.w,'DEVICE NOT SET UP','center','center',255);

% clean up
clear image cs cueshape texture


%% CURSOR STARTS
% create array of random starting cursor positions
% for s = 1:sum(ratings~=0)
%     for rt = 1:2
%         ok = false;
%         while ~ok
%             if mod(s,2)
%                 starts(s,rt) = round(rand(1)*0.4*cursor.width); %#ok
%             else
%                 starts(s,rt) = round(rand(1)*-0.4*cursor.width); %#ok
%             end
%             ok = true;
%
%             for i = 1:numel(cursor.labels)
%                 if abs((cursor.center+starts(s,rt))-(cursor.xmin+cursor.labels(i))) <= 10
%                     ok = false;
%                 end
%             end
%         end
%     end
% end
% starts = Shuffle(starts);
% cursor.start(find(ratings)',:) = starts;
% cursor.start(cursor.start==0) = NaN;
% clear starts s ok i

% prqcursor.start = Shuffle(round(rand(numel(prqimgs),1).*((mod(1:numel(prqimgs),2)-.5)'*2) * 0.5 * prqcursor.width));

%sca

%return

%%
%%
%%
%% PRESENT EXPERIMENT

% initialize
Screen('TextSize',window,72);
DrawFormattedText(window,'.','center','center',FGCOLOR);
timing.initialized = Screen('Flip',window);

% wait for experimenter to press "s" before listening for TTL pulse
keycode(key.s) = 0;
while keycode(key.s) == 0
    [presstime keycode delta] = KbWait;
end
timing.spress = presstime;


% put up instruction screens
if info.run==1 && isfield(dspl,'instruct')
    for i = 1:numel(dspl.instruct)
        Screen('CopyWindow',dspl.instruct(i).w,window);
        timing.instructstart(i) = Screen('Flip',window);
        % wait for experimenter to press spacebar
        keycode(key.space) = 0;
        while keycode(key.space) == 0
%            [presstime keycode delta] = KbWait;
            [ign1, presstime, keycode] = KbCheck;
            WaitSecs(KBSAMPRATE);
        end
        timing.instructfinish(i) = presstime;
    end
end

if USE_EYELINK
    % STEP 7.3
    % start recording eye position (preceded by a short pause so that
    % the tracker can finish the mode transition)
    % The paramerters for the 'StartRecording' call controls the
    % file_samples, file_events, link_samples, link_events availability
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.05);
    %         Eyelink('StartRecording', 1, 1, 1, 1);
    Eyelink('StartRecording');
    % record a few samples before we actually start displaying
    % otherwise you may lose a few msec of data
    WaitSecs(0.1);
end
 

% ready screen
Screen('TextSize',window,72);
DrawFormattedText(window,'Ready','center','center',FGCOLOR);
timing.readyscreen = Screen('Flip',window);
if info.scanner
    % wait for TTL pulse to trigger beginning
    keycode(key.ttl) = 0;
    WaitSecs(.25);
    while keycode(key.ttl) == 0
        [presstime keycode delta] = KbWait;
    end
else
    % wait for experimenter to press spacebar
    WaitSecs(.2);
    keycode(key.space) = 0;
    while keycode(key.space) == 0
        [presstime keycode delta] = KbWait;
    end
end
if USE_EYELINK, Eyelink('Message', 'ttl_received'); end
timing.ttl = presstime;




% put up fixation
Screen('CopyWindow',dspl.fixation.w,window);
timing.startfix = Screen('Flip',window);

% adjust onsets and timings based on start time (ttl pulse)
onsets = onsets+timing.ttl;
onset.endscreen = onset.endscreen + timing.ttl;
timings = timings-timing.ttl;

% trial loop
for trial = 1:size(onsets,1)
    
    %Put an eyelink message in to mark trial number in eyelink file
    if USE_EYELINK, Eyelink('Message', 'TRIAL_%02d_MODALITY_%d_TRIALTYPE_%d', trial, trials(trial,:)); end %Mark trial number in eyetracker
   
    %%% CUE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Screen('CopyWindow',dspl.cuescreen(tt{trials(trial,1)}.cuenum).w,window);
    WaitSecs('UntilTime',onsets(trial,o.cue));
    timings(trial,t.cue) = Screen('Flip',window);
    if USE_EYELINK, Eyelink('Message', 'cue_start'); end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % prep stim
    if USE_DEVICE
        if trials(trial,1) > 2
            if trials(trial,1) == 3
                wavfile = tt{3}.file{trials(trial,2)};
            elseif trials(trial,1) == 4
                wavfile = tt{4}.file{trials(trial,2),info.run};
            end
            [y freq] = wavread(wavfile);
            wavedata = y';
            nrchannels = size(wavedata,1);
            pahandle = PsychPortAudio('Open',[],[],0,freq,nrchannels);
            PsychPortAudio('FillBuffer',pahandle,wavedata);
        end
    else
        Screen('CopyWindow',dspl.nodevice.w,window);
        switch trials(trial,1)
            case 1
                msg = sprintf('HEAT temp: %d  dur: %d',tt{1}.temp(trials(trial,2)),tt{1}.DURATION(trials(trial,2)));
            case 2
                msg = sprintf('OFFSET temp: %d',tt{2}.temp(trials(trial,2)));
            case 3
                msg = sprintf('SOUNDPAIN int: %d',tt{3}.intensity(trials(trial,2)));
            case 4
                msg = sprintf('IADS %s',tt{4}.file{trials(trial,2),info.run});
        end
    end
    
    
    %%% DELAY1 + STIM + DELAY2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ratings(trial),
        if trial==size(onsets,1)
            nextonset = onset.endscreen;
        else
            nextonset = onsets(trial+1,o.rating(1));
        end
    else
        nextonset = onsets(trial,o.cue);
    end
    clear ctime crate
    cursor.x = cursor.xmin;
    sample = 1;
    WaitSecs('UntilTime',onsets(trial,o.prestim))
    SetMouse(dspl.xcenter,dspl.ycenter);
    nextsample = GetSecs;
    stimmed = false;
    if USE_EYELINK, Eyelink('Message', 'crating_start'); end
    while GetSecs < onsets(trial,o.cue) + DURATION.trialwithoutratings
        loopstart = GetSecs;
        
        % sample at SAMPLERATE
        if loopstart >= nextsample
            ctime(sample) = loopstart; %#ok
            crate(sample) = cursor.x; %#ok
            nextsample = nextsample+SAMPLERATE;
            sample = sample+1;
        end
        
        % stim at stim time
        if ~stimmed && loopstart >= onsets(trial,o.stim)
            stimmed = true;
            if USE_EYELINK, Eyelink('Message', 'stim_start'); end
            if USE_DEVICE
                if USE_BIOPAC
                    feval(trigger_biopac,BIOPAC_PULSE_WIDTH);
                end
                if trials(trial,1) >= 3
                    timings(trial,t.stim) = GetSecs;
                    PsychPortAudio('Start',pahandle,1,0,1);
                else
                    %                     timings(trial,t.stim) = TriggerHeat(tt{trials(trial,1)}.code(trials(trial,2)));
                    timings(trial,t.stim) = feval(trigger_heat,tt{trials(trial,1)}.code(trials(trial,2)));
                end
            else
                Screen('TextSize',window,72);
                DrawFormattedText(window,msg,'center',dspl.ycenter+200,FGCOLOR);
                timings(trial,t.stim) = Screen('Flip',window);
                WaitSecs(3);
            end
        end

        % measure mouse movement
        [x y] = GetMouse;
        % reset mouse position
        SetMouse(dspl.xcenter,dspl.ycenter);
        
        % calculate displacement
        cursor.x = (cursor.x + x-dspl.xcenter) * TRACKBALL_MULTIPLIER;
        % check bounds
        if cursor.x > cursor.xmax
            cursor.x = cursor.xmax;
        elseif cursor.x < cursor.xmin
            cursor.x = cursor.xmin;
        end
        
        % produce screen
        Screen('CopyWindow',dspl.cscale.w,window);
        % add rating indicator ball
        Screen('FillOval',window,[0 0 0],[[cursor.x cursor.y]-cursor.size [cursor.x cursor.y]+cursor.size]);
        Screen('Flip',window);
    end
    if USE_EYELINK, Eyelink('Message', 'crating_stop'); end
    % adjust rating value according to screen/scale dimensions
    cratings{trial} = [ctime' (100*((crate-cursor.xmin)/cursor.width))'];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % clean up
    if USE_DEVICE
        if trials(trial,1) >= 3
            PsychPortAudio('Stop',pahandle);
            PsychPortAudio('Close',pahandle);
        end
    end
    
    %%% OVERALL RATINGS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ratings(trial)
        for r = [1 2]
            ratingtype = abs((3*(r-1))-ratings(trial));
            % rating cue screen
            Screen('TextSize',window,40);
            DrawFormattedText(window,...
                sprintf('OVERALL %s RATING',RATINGTITLES{ratingtype}),...
                'center',dspl.ycenter-270,FGCOLOR);
            WaitSecs('UntilTime',onsets(trial,o.rating(r)));
            timings(trial,t.ratingcue(r)) = Screen('Flip',window);
            % initialize rating
            cursor.x = cursor.xmin; %cursor.center - cursor.start(trial,ratingtype);
            timings(trial,t.ratingstart(r)) = WaitSecs('UntilTime',onsets(trial,o.rating(r)) + DURATION.ratingcue);
            SetMouse(dspl.xcenter,dspl.ycenter);
            % do animated sliding rating
            if USE_EYELINK, Eyelink('Message', '%s_rating_start', RATINGTITLES{ratingtype}); end
            while 1
                % measure mouse movement
                [x y click] = GetMouse;
                % upon right click, record time, freeze for remainder of rating period
                if any(click(mousebuttons))
                    % record time of click
                    timings(trial,t.rating(r)) = GetSecs;
                    
                    % draw scale
                    Screen('CopyWindow',dspl.oscale(ratingtype).w,window);
                    % draw line to top of rating wedge
                    Screen('DrawLine',window,[0 0 0],...
                        cursor.x,cursor.y-(ceil(.107*(cursor.x-cursor.xmin)))-5,...
                        cursor.x,cursor.y+10,3);
                    Screen('Flip',window);
                    
                    % freeze screen
                    break
                end
                
                % if run out of time
                if GetSecs >= onsets(trial,o.postratingfix(r)) - DURATION.ratingfeedback
                    % draw scale
                    Screen('CopyWindow',dspl.oscale(ratingtype).w,window);
                    Screen('Flip',window);
                    
                    % freeze screen
                    break
                end
                
                % reset mouse position
                SetMouse(dspl.xcenter,dspl.ycenter);
                
                % calculate displacement
                cursor.x = (cursor.x + x-dspl.xcenter) * TRACKBALL_MULTIPLIER;
                % check bounds
                if cursor.x > cursor.xmax
                    cursor.x = cursor.xmax;
                elseif cursor.x < cursor.xmin
                    cursor.x = cursor.xmin;
                end
                
                % draw scale
                Screen('CopyWindow',dspl.oscale(ratingtype).w,window);
                % add cursor
                Screen('FillOval',window,[0 0 0],...
                    [[cursor.x cursor.y]-cursor.size [cursor.x cursor.y]+cursor.size]);
                Screen('Flip',window);
            end
            oratings{ratingtype}(trial) = 100*((cursor.x-cursor.xmin)/cursor.width); %#ok
            
            
            % fixation
            Screen('CopyWindow',dspl.fixation.w,window);
            WaitSecs('UntilTime',onsets(trial,o.postratingfix(r)));
            Screen('Flip',window);
        end
        if USE_EYELINK, Eyelink('Message', '%s_rating_stop', RATINGTITLES{ratingtype}); end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if USE_EYELINK, Eyelink('Message', 'trial_stop'); end %% End trial for eyelink
end
if USE_EYELINK, Eyelink('Message', 'run_stop'); end



% END SCREEN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('TextSize',window,72);
DrawFormattedText(window,'END','center','center',FGCOLOR);
timing.endscreen = Screen('Flip',window);
WaitSecs(3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



if USE_EYELINK
    % STEP 8
    % End of Experiment; close the file first
    % close graphics window, close data file and shut down tracker    
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.5);
    Eyelink('CloseFile');
    
    % download data file
    try
        fprintf('Receiving data file ''%s''\n', edfFile );
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
        end
    catch
        fprintf('Problem receiving data file ''%s''\n', edfFile );
    end
    
    % STEP 9
    % cleanup;
    % function cleanup
    Eyelink('Shutdown');
end


Screen('Flip',window);
WaitSecs(.75);

if ismember(info.run,[2 4])
    % POST-RUN QUESTIONS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % intro screen
    Screen('TextSize',window,50);
    DrawFormattedText(window,'POST RUN QUESTIONS','center','center',FGCOLOR);
    timing.endscreen = Screen('Flip',window);
    WaitSecs(3);
    
    % loop through questions
    prq = 1:numel(dspl.prqscale); %randperm(numel(dspl.prqscale));
    for i = 1:numel(prq)
        prqlog.data(prq(i),1) = i;
        
        % blank
        Screen('Flip',window);
        WaitSecs(.75);
        
        % question rating
        Screen('CopyWindow',dspl.prqscale(prq(i)).w,window);
        prqlog.data(prq(i),3) = Screen('Flip',window);
        prqcursor.x = prqcursor.xmin; %prqcursor.center - prqcursor.start(i);
        SetMouse(dspl.xcenter,dspl.ycenter);
        while 1
            % measure mouse movement
            [x y click] = GetMouse;
            % upon right click, record time, freeze for remainder of rating period
            if any(click(mousebuttons))
                % record time of click
                prqlog.data(prq(i),4) = GetSecs;
                
                % draw scale
                Screen('CopyWindow',dspl.prqscale(prq(i)).w,window);
                % draw line to top of rating wedge
                Screen('DrawLine',window,[255 255 255],...
                    prqcursor.x,prqcursor.y,...
                    prqcursor.x,prqcursor.y-70,3);
                Screen('Flip',window);
                WaitSecs(.75);
                
                % freeze screen
                break
            end
            
            % reset mouse position
            SetMouse(dspl.xcenter,dspl.ycenter);
            
            % calculate displacement
            prqcursor.x = (prqcursor.x + x-dspl.xcenter) * TRACKBALL_MULTIPLIER;
            % check bounds
            if prqcursor.x > prqcursor.xmax
                prqcursor.x = prqcursor.xmax;
            elseif prqcursor.x < prqcursor.xmin
                prqcursor.x = prqcursor.xmin;
            end
            
            % draw scale
            Screen('CopyWindow',dspl.prqscale(prq(i)).w,window);
            % add cursor
            Screen('FillOval',window,[0 0 0],...
                [[prqcursor.x prqcursor.y]-prqcursor.size [prqcursor.x prqcursor.y]+prqcursor.size]);
            Screen('Flip',window);
        end
        prqlog.data(prq(i),2) = 100*((prqcursor.x-prqcursor.xmin)/prqcursor.width);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % outro screen
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Screen('TextSize',window,72);
    DrawFormattedText(window,'END','center','center',FGCOLOR);
    timing.prqendscreen = Screen('Flip',window);
    WaitSecs(3);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end




%% SAVE DATA
save(envlogfile,...
    'USE_DEVICE',...
    'SAMPLERATE','NRUNS',...
    'info',...
    'key',...
    'dspl','cursor','RATINGTITLES',...
    'run',...
    'DURATION',...
    'ratings',...
    'ttlist','tt',...
    'timings','timing','t',...
    'onsets','onset','o',...
    'oratings','cratings');

% save log
prqlog.data = prqlog;
% cursorstarts = (100*((cursor.center-cursor.start-cursor.xmin)/cursor.width))';
% save(logfile,'info','timings','t','timing','tt','oratings','cratings','trials','ratings','cursorstarts','prqlog');
save(logfile,'info','timings','t','timing','tt','oratings','cratings','trials','ratings','prqlog');


%% FINISH UP
Screen('CloseAll');
commandwindow



% Restore keyboard output to Matlab:
% % ListenChar(0);
