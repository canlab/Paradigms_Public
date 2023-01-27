function videos_data_table = run_alignvideos(running_mode)
% videos task
%
% code by Rotem Botvinik-Nezer
% based on codes by Heejung Jung and Luke Slipski (11.27.2020)
% 
% Last updated December 2020
%
% This function runs the videos task, including the videos + ratings.
% if Biopac is used to measure physiological data, sensors
% should be connected before the task starts.
% there's a screen at the beginning reminding the experimenter what to do
% with the biopac and cameras.
% It then waits for the experimenter to indicate everything is ready,
% before starting the trials
% At the end of the task, the experimenter needs to save the Biopac data
% into a file and rename it approprietly (see SOP and biopac_signal code).
%
% Input:
% running_mode: should be 'debugging' for debugging mode (debugging screen,
% cursor is shown, less trials per block). Otherwise, leave empty.
%
% Output:
% videos_data_table: the output table (also saved to file)
%
% Functions needed to run properly:
% WaitKeyPress.m
% initialize_ptb_params.m
% biopac_signal.m
% get_params_from_experimenter.m
% cleanup.m
%
% Directories and files required to run properly:
% (sub folders in the main experiment folder)
% 'data/' for the output
% 'instructions/' with the pics of the instructions (start task, end task)
% 'audio_files/' with the audio files
% 'scale/video_rating_pronpts' with .png pics of the prompts to be used for rating
% 'files' with the movies_by_ses.csv file (with file names, sessions and
% durations
% 'videos/ses-XX'- videos subdir with sub directories for each session, in
% which the video files are saved (filenames must match the filenames in
% the movies_by_ses.csv file

%% use debugging mode?
if nargin > 0 && strcmp(running_mode, 'debugging')
    debugging_mode = 1;
else
    debugging_mode = 0;
end

%% ------------------------------------------------------------------------
%                           Parameters
% _________________________________________________________________________

%% --------------------------- Basic parameters ---------------------------
experiment_name = 'NOF';
task_name = 'videos';
task_name_audio_file = 'videos';
main_dir = fileparts(pwd); % main dir is one dir up
output_dir = fullfile(main_dir, 'data');
videos_dir = fullfile(main_dir, 'videos');

%% --------------------- Parameters from experimenter ---------------------
[data_filename, session_num, use_biopac, subject_num, ~, ~, session_str] = get_params_from_experimenter(experiment_name,task_name,output_dir);

%% -------------------------- Biopac Parameters ---------------------------
% biopac channel settings for relevant events
% the biopac_code_dict for the entire experiment can be found in an excel
% file under main_dir/code
biopac_signal_out = struct;
biopac_signal_out.baseline = 0;
biopac_signal_out.task_id = 100;
biopac_signal_out.task_start = 7;
biopac_signal_out.task_end = 8;
biopac_signal_out.block_middle = 11;
biopac_signal_out.trial_start = 12;
biopac_signal_out.trial_end = 13;
biopac_signal_out.video_start = 101;
biopac_signal_out.video_end = 102;
biopac_signal_out.rating_start = 103;
biopac_signal_out.rating_end = 104;

%% ------------------------------ time stamp ------------------------------
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];

%% ------------------------ Psychtoolbox parameters -----------------------
p = initialize_ptb_params(debugging_mode);
if ~debugging_mode
    HideCursor;
end

%% ------------------------ Videos-related parameters ---------------------
% empty options for video Screen
shader = [];
pixelFormat = [];
maxThreads = [];

escape = 0;

% Use blocking wait for new frames by default:
blocking = 1;

% Default preload setting:
preloadsecs = [];
% Playbackrate defaults to 1:
rate=1;

videos_params_filename = fullfile(main_dir, 'files', 'movies_by_ses.csv');
design_file = readtable(videos_params_filename);
param_T = design_file(design_file.session == session_num, :); % keep only videos from current session
num_videos = size(param_T,1);

% Pre-load videos
DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n0%% complete'),'center','center',p.ptb.white);
Screen('Flip',p.ptb.window);
for v = 1:num_videos
    video_file = fullfile(videos_dir,session_str, param_T.video_filename{v});
    [movie{v}, dur{v}, fps{v}, imgw{v}, imgh{v}] = Screen('OpenMovie', p.ptb.window, video_file, [], preloadsecs, [], pixelFormat, maxThreads);
    DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n%d%% complete', ceil(100*v/num_videos)),'center','center',p.ptb.white);
    Screen('Flip',p.ptb.window);
end

% Make scale prompts images into textures
prompt_images = dir(fullfile(main_dir, 'scale', 'video_rating_prompts', '*.png'));
prompt_tex = cell(length(prompt_images),1);
for prompt_ind = 1:length(prompt_images)
    %         cue_image = fullfile(main_dir, 'stimuli', 'cues', '*.png');
    prompt_filename = fullfile(prompt_images(prompt_ind).folder, prompt_images(prompt_ind).name);
    prompt_tex{prompt_ind} = Screen('MakeTexture', p.ptb.window, imread(prompt_filename));
end

%% ----------------------- Make output data table -------------------------
var_names = {'subject_num', 'session_num', 'task_onset', 'trial', 'trial_onset'...
    'start_sound_onset','middle_sound_onset','end_sound_onset',...
    'video_filename', 'video_onset', 'video_end',...
    'rating01_displayonset', 'rating01_displaystop','rating01_rating', 'rating01_onset', 'rating01_RT',...
    'rating02_displayonset', 'rating02_displaystop', 'rating02_rating', 'rating02_onset', 'rating02_RT',...
    'rating03_displayonset', 'rating03_displaystop', 'rating03_rating', 'rating03_onset', 'rating03_RT',...
    'rating04_displayonset', 'rating04_displaystop', 'rating04_rating', 'rating04_onset', 'rating04_RT',...
    'rating05_displayonset', 'rating05_displaystop', 'rating05_rating', 'rating05_onset', 'rating05_RT',...
    'rating06_displayonset', 'rating06_displaystop', 'rating06_rating', 'rating06_onset', 'rating06_RT',...
    'rating07_displayonset', 'rating07_displaystop', 'rating07_rating', 'rating07_onset', 'rating07_RT',...
    'trial_offset','task_end','use_biopac'};

var_types = {'double', 'double', 'double', 'double', 'double'...
    'double','double','double',...
    'string', 'double', 'double',...
    'double', 'double', 'double', 'double', 'double',...
    'double', 'double', 'double', 'double', 'double',...
    'double', 'double', 'double', 'double', 'double',...
    'double', 'double', 'double', 'double', 'double',...
    'double', 'double', 'double', 'double', 'double',...
    'double', 'double', 'double', 'double', 'double',...
    'double', 'double', 'double', 'double', 'double',...
    'double', 'double', 'logical'};
videos_data_table = table('Size',[num_videos, size(var_names, 2)],'VariableTypes',var_types,'VariableNames',var_names);
videos_data_table.subject_num(:) = subject_num;
videos_data_table.session_num(:) = session_num;
videos_data_table.trial(:) = 1:num_videos;
videos_data_table.video_filename(:) = param_T.video_filename;
videos_data_table.use_biopac(:) = use_biopac;

%% ------------------------- Load audio files -----------------------------
[gopro_start, Fs_gopro_start] = audioread(fullfile(main_dir, 'audio_files', 'GoPro_start_recording.m4a'));
[gopro_stop, Fs_gopro_stop] = audioread(fullfile(main_dir, 'audio_files', 'GoPro_stop_recording.m4a'));
[gopro_hilight, Fs_gopro_hilight] = audioread(fullfile(main_dir, 'audio_files', 'GoPro_hilight.m4a'));
[audio_session, Fs_audio_session] = audioread(fullfile(main_dir, 'audio_files', 'session.m4a'));
[audio_task, Fs_audio_task] = audioread(fullfile(main_dir, 'audio_files', 'task.m4a'));
[audio_which_task, Fs_audio_which_task] = audioread(fullfile(main_dir, 'audio_files', [task_name_audio_file '.m4a']));

% load recordings of all numbers
audio_numbers = cell(10,1);
Fs_numbers = zeros(10,1);
for ind = 1:10
   [audio_numbers{ind}, Fs_numbers(ind)] = audioread(fullfile(main_dir, 'audio_files', [num2str(ind) '.m4a']));
end

%% --------------------------- Load instructions --------------------------
instruct_filepath = fullfile(main_dir, 'instructions');
instruct_task_start = fullfile(instruct_filepath, 'videos_task_start.png');
instruct_task_end = fullfile(instruct_filepath, 'task_end.png');

%% ------------------------------------------------------------------------
%                              Start task
% _________________________________________________________________________

% set the signal in the digital channels via parallel port
if use_biopac
    biopac_signal(biopac_signal_out.task_id);
end

%% wait for the experimenter to indicate everything is ready (Biopac, cameras)
Screen('TextSize', p.ptb.window, 36);
msg_for_exp = 'Experimenter, please make sure that:\n\n(1) The Biopac sensors are placed and turned on\n(2) Acknowledge is recording data\n(3) The GoPro is open and charged\n(4) The thermal camera is recording and charged\n\nPress ''s'' when ready to start';
DrawFormattedText(p.ptb.window, msg_for_exp, 'center', 'center',p.ptb.white);
Screen('Flip',p.ptb.window);
WaitKeyPress(p.keys.start);

%% -------- Block start routine (instructions, response, sound) -------
start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_task_start));
Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
Screen('Flip',p.ptb.window);

% Wait for participant's confirmation to Begin
WaitKeyPress(p.keys.start);
Screen('Flip',p.ptb.window);
task_onset = GetSecs;
videos_data_table.task_onset(:) = 0; % task_onset is used as the anchor for all other timings

if use_biopac
    biopac_signal(biopac_signal_out.task_start);
end
WaitSecs(2);

% start gopro recording with voice command ("GoPro start recording")
sound(gopro_start, Fs_gopro_start);
WaitSecs(5);
% Play a sound for post-hoc syncronization with the facial and thermal recordings ("GoPro hilight")
sound(gopro_hilight, Fs_gopro_hilight);
start_sound_onset = GetSecs;
videos_data_table.start_sound_onset(1) = start_sound_onset - task_onset;
WaitSecs(2);

% play the session, task and block
% session
sound(audio_session, Fs_audio_session);
WaitSecs(1.5);
% session number
sound(audio_numbers{session_num}, Fs_numbers(session_num));
WaitSecs(1);
% task
sound(audio_task, Fs_audio_task);
WaitSecs(1.5);
% which task
sound(audio_which_task, Fs_audio_which_task);
WaitSecs(3);

%% ---------------------------- Trials loop ---------------------------
for trial_num = 1:num_videos
    if debugging_mode
       if trial_num > 1
           break;
       end
    end
    % sound if middle trial
    if trial_num == ceil(num_videos / 2)
        videos_data_table.middle_sound_onset(trial_num) = GetSecs - task_onset;
        sound(gopro_hilight, Fs_gopro_hilight);
        if use_biopac
            biopac_signal(biopac_signal_out.block_middle);
        end
        WaitSecs(2);
    end
    
    % record trial onset
    trial_onset = GetSecs;
    videos_data_table.trial_onset(trial_num) = trial_onset - task_onset;
    if use_biopac
        biopac_signal(biopac_signal_out.trial_start);
    end
    
    %% start video ________________________________________________________
    totalframes = floor(fps{trial_num} * dur{trial_num});
    fprintf('Movie: %s  : %f seconds duration, %f fps, w x h = %i x %i...\n', videos_data_table.video_filename{trial_num}, dur{trial_num}, fps{trial_num}, imgw{trial_num}, imgh{trial_num});
    frame_ind=0;
    Screen('PlayMovie', movie{trial_num}, rate, 1, 1.0);
    videos_data_table.video_onset(trial_num) = GetSecs - task_onset;
    if use_biopac
        biopac_signal(biopac_signal_out.video_start);
    end
    
    while frame_ind<totalframes-1
        
        escape=0;
        [keyIsDown,~,keyCode]=KbCheck;
        if (keyIsDown==1 && keyCode(p.keys.esc))
            % Set the abort-demo flag.
            escape=2;
            % break;
        end
        
        % Only perform video image fetch/drawing if playback is active
        % and the movie actually has a video track (imgw and imgh > 0):
        
        if ((abs(rate)>0) && (imgw{trial_num}>0) && (imgh{trial_num}>0))
            % Return next frame in movie, in sync with current playback
            % time and sound.
            % tex is either the positive texture handle or zero if no
            % new frame is ready yet in non-blocking mode (blocking == 0).
            % It is -1 if something went wrong and playback needs to be stopped:
            tex = Screen('GetMovieImage', p.ptb.window, movie{trial_num}, blocking);
            
            % Valid texture returned?
            if tex < 0
                % No, and there won't be any in the future, due to some
                % error. Abort playback loop:
                %  break;
            end
            
            if tex == 0
                % No new frame in polling wait (blocking == 0). Just sleep
                % a bit and then retry.
                WaitSecs('YieldSecs', 0.005);
                continue;
            end
            
            Screen('DrawTexture', p.ptb.window, tex, [], [], [], [], [], [], shader); % Draw the new texture immediately to screen:
            Screen('Flip', p.ptb.window); % Update display:
            Screen('Close', tex);% Release texture:
            frame_ind=frame_ind+1; % Framecounter:
            
        end % end if statement for grabbing next frame
    end % end while statement for playing until no more frames exist
    
    videos_data_table.video_end(trial_num) = GetSecs - task_onset;
    
    if use_biopac
        biopac_signal(biopac_signal_out.video_end);
    end
    
    Screen('Flip', p.ptb.window);
    KbReleaseWait;
    
    Screen('PlayMovie', movie{trial_num}, 0); % Done. Stop playback:
    Screen('CloseMovie', movie{trial_num});  % Close movie object:
    
    % Release texture:
    %         Screen('Close', tex);
    
    % if escape is pressed during video, exit
    if escape==2
        %break
    end
    
    %% affective ratings __________________________________________________
    % this part is based on the 'rating_scale.m' from spacetop's videos
    % task, which is based on ani Woo's explain_scale.m in www.github.com/canlab/PAINGEN
    % Configure Screen for rating scale
    theWindow = p.ptb.window;
    window_rect = [0 0 p.ptb.screenXpixels p.ptb.screenYpixels];
    screen_width = window_rect(3); %width of screen
    screen_height = window_rect(4); %height of screen
    white = 255;
    red = [255 0 0];
    % orange = [255 164 0];
    
    % rating scale left and right bounds 1/4 and 3/4
    left_bound = screen_width/4 ;
    right_bound = (3*screen_width)/4;
    
    % Height of the scale (10% of the width)
    scale_H = (right_bound-left_bound).*0.1;
    
    % Vetrtical location of the scale on screen (1=bottom, 0=top,
    % 0.5=middle etc.)
    v_scale_loc = 0.7;
    
    % rating scale upper and lower bounds
    lower_bound = v_scale_loc * screen_height;
    upper_bound = lower_bound + scale_H;
    
    %%% configure screen
    dspl.screenWidth = p.ptb.rect(3);
    dspl.screenHeight = p.ptb.rect(4);
    dspl.xcenter = dspl.screenWidth/2;
    dspl.ycenter = dspl.screenHeight/2;
    
    prompt_count = size(prompt_tex,1);
    
    % start rating loop
    try
        for rating_ind = 1:prompt_count
            
            % set bar color
            barcolor = white;
            
            % display rating image for correct prompt
            %dspl.cscale.width = 964;
            dspl.cscale.width = 1920;
            %dspl.cscale.height = 480;
            dspl.cscale.height = 1080;
            dspl.cscale.w = Screen('OpenOffscreenWindow',p.ptb.screenNumber);
            % paint black
            Screen('FillRect',dspl.cscale.w,0)
            % placement
            dspl.cscale.rect = [...
                [dspl.xcenter dspl.ycenter]-[0.5*dspl.cscale.width 0.5*dspl.cscale.height] ...
                [dspl.xcenter dspl.ycenter]+[0.5*dspl.cscale.width 0.5*dspl.cscale.height]];
            %Screen('DrawTexture',dspl.cscale.w,dspl.cscale.texture,[],dspl.cscale.rect);
            Screen('DrawTexture',dspl.cscale.w, prompt_tex{rating_ind},[],dspl.cscale.rect);
            
            SetMouse(left_bound,screen_height * v_scale_loc); % set mouse at the left
            
            rating_time_start = GetSecs; %get start time in ms
            videos_data_table{trial_num, ['rating0' num2str(rating_ind) '_displayonset']} = rating_time_start - task_onset;
            if use_biopac
                biopac_signal(biopac_signal_out.rating_start);
            end
            button_pressed = false;
            while ~button_pressed
                Screen('CopyWindow',dspl.cscale.w, theWindow);
                [x,y,button] = GetMouse(theWindow);
                % keep cursor within x bounderies
                if x < left_bound
                    x = left_bound;
                elseif x > right_bound
                    x = right_bound;
                end
                %                 % keep cursor within y bounderis
                %                 if y < upper_bound
                %                     y = upper_bound;
                %                 elseif y > lower_bound
                %                     y = lower_bound;
                %                 end
                SetMouse(x,y);
                
                % set up scale
                xy = [left_bound upper_bound; right_bound upper_bound; right_bound lower_bound];
                Screen(theWindow, 'FillPoly', 255, xy);
                % update bar coordinates as mouse moves
                xy = [left_bound lower_bound; left_bound upper_bound ; x upper_bound; x lower_bound];
                Screen('FillPoly', theWindow, barcolor, xy, 1);
                % redraw rating bar with update
                Screen('Flip', theWindow);
                % if clicked, go to next step in rating loop
                if button(1)
                    videos_data_table{trial_num, ['rating0' num2str(rating_ind) '_onset']} = GetSecs - task_onset;
                    videos_data_table{trial_num, ['rating0' num2str(rating_ind) '_RT']} = GetSecs - rating_time_start;
                    % record x as the rating for this trial
                    videos_data_table{trial_num, ['rating0' num2str(rating_ind) '_rating']} = ((x-left_bound)/(right_bound-left_bound))*100;
                    
                    button_pressed = true;
                    % use bar coordinates with final x value from mouse movement
                    xy = [left_bound lower_bound; left_bound upper_bound ; x upper_bound; x lower_bound];
                    % make bar RED
                    Screen('FillPoly', theWindow, red, xy, 1);
                end
            end
            % freeze the screen 1 second with red line
            
            % set up scale
            xy = [left_bound upper_bound; right_bound upper_bound; right_bound lower_bound];
            Screen(theWindow, 'FillPoly', 255, xy);
            %         Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
            %         Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
            %         Screen(theWindow,'DrawText','Strongest',rb-50,anchor_y,255);
            %         Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
            % use bar coordinates with final x value from mouse movement
            xy = [left_bound lower_bound; left_bound upper_bound; x upper_bound; x lower_bound];
            % make bar RED
            Screen('FillPoly', theWindow, red, xy, 1);        % record x as the rating for this trial
            %ratings(1) = x;        % draw bar and wait 1 second
            Screen('Flip', theWindow);
            WaitSecs(0.5);
            % Release texture:
            %Screen('Close', dspl.cscale.texture);
            %Screen('Close', cue_tex{i});
            if use_biopac
                biopac_signal(biopac_signal_out.rating_end);
            end
            videos_data_table{trial_num, ['rating0' num2str(rating_ind) '_displaystop']} = GetSecs - task_onset;
        end
        Screen('Flip', theWindow);
        
    catch em
        display(em.message);
        Screen('CloseAll');
    end
    %% trial offset
    trial_offset = GetSecs;
    if use_biopac
        biopac_signal(biopac_signal_out.trial_end);
    end
    videos_data_table.trial_offset(trial_num) = trial_offset - task_onset;
    
    %% save trial info
    writetable(videos_data_table, data_filename);
end % end trial loop

%% end task
task_end = GetSecs;
videos_data_table.task_end(:) = task_end - task_onset;

if use_biopac
    biopac_signal(biopac_signal_out.task_end);
end

% Play a sound for post-hoc syncronization with the facial and thermal recordings ("GoPro hilight")
sound(gopro_hilight, Fs_gopro_hilight);
end_sound_onset = GetSecs;
videos_data_table.end_sound_onset(end) = end_sound_onset - task_onset;
WaitSecs(2);
% stop gopro recording with voice command ("GoPro stop recording")
sound(gopro_stop, Fs_gopro_stop);

% save final table (also as a .mat file, along with the 'p' struct)
writetable(videos_data_table, data_filename);
save([data_filename(1:end-4) '_' timestamp], 'videos_data_table', 'p');

%% show end of task msg
start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_task_end));
Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
Screen('Flip',p.ptb.window);

%% wait for experimenter to end the task
WaitKeyPress(p.keys.end);
Screen('Flip',p.ptb.window);

%% end part
cleanup;

end
