function part1_data_table = run_NOF_part1_only_block2(running_mode)
% PART 1 - DOSE RESPONSE
%
% code by Rotem Botvinik-Nezer
% based on codes by Heejung Jung and Xiaochun Han
% Last updated January 2021
%
% This function runs the first part of the NOF experiment: dose response.
% with heat stimuli and pain and expectation ratings
%
% This code runs all blocks of the task.
% Before each block (including the first one), there is a screen with
% instructions to the experimenter with everything that needs to happen
% before starting the block (for example, the skin site to put the thermode
% on). It then waits for the experimenter to indicate everything is ready,
% before presenting the task instructions to the participant.
% Code ends after all blocks are completed (based on num_blocks)
% At the end of the task, the experimenter needs to save the Biopac data
% into a file and rename it approprietly (see SOP and biopac_signal code).
% Each block starts with one dummy trial for adaptation effects (no expectation rating).
% Each trial includes the following parts:
% Expectation ratings (only for sessions 1,3,5,7,9), "Get
% ready!", pre-stim fixation, heat stim, post-stim fixation, pain rating,
% isi fixation.
%
% Input:
% running_mode: should be 'debugging' for debugging mode (debugging screen,
% cursor is shown, less trials per block). Otherwise, leave empty.
%
% Output:
% part1_data_table: the output table (also saved to file)
%
% Functions needed to run properly:
% semi_circular_rating.m
% exp_sample.m
% WaitKeyPress.m
% initialize_ptb_params.m
% thermode_trigger.m and thermode_choose_program.m (and all their dependents)
% biopac_signal.m
% get_params_from_experimenter.m
% cleanup.m
%
% Directories and files required to run properly:
% (sub folders in the main experiment folder)
% 'data/' for the output
% 'instructions/' with the pics of the instructions (start block, end block)
% 'audio_files/' with the audio files
% 'scale/' with pics of the scales to be used for rating


%% set random seed
rng shuffle

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
task_name = 'doseresponse';
task_name_audio_file = 'DR';
main_dir = fileparts(pwd); % main dir is one dir up
output_dir = [main_dir filesep 'data'];

%% --------------------- Parameters from experimenter ---------------------
[data_filename, session_num, use_biopac, ~, subject_str, subj_main_output_dir, ~] = get_params_from_experimenter(experiment_name,task_name,output_dir);

%% ------------------- Load participant parameters file -------------------
filename = fullfile(subj_main_output_dir, [subject_str '_parameters.mat']);
load(filename, 'participant_parameters');

%% --------------------------- Fixed parameters ---------------------------
sites_order = participant_parameters.sites.dose_response(session_num,:);
if session_num == 1
    num_blocks = 1; % one block was already completd during the intro task (for familiarization and calibration)
    sites_order = sites_order(2:end); % in the first session, the first site is for the intro task
else
    num_blocks = 2;
end
exp_trials_per_block = 7; % not including the dummy trial
num_dummy_trials_per_block = 1;
dummy_temp = 47 + participant_parameters.calibration_factor;
total_trials_per_block = num_dummy_trials_per_block + exp_trials_per_block;
heat_peak_duration = 7; % heat stimulus duration (at peak) in seconds
ramp_up_rate = 10; % ramp up rate in degrees per second (TSA2 max is 13)
ramp_down_rate = 13; % ramp up rate in degrees per second (TSA2 max is 13)
rating_duration = 'self_paced'; % duration in seconds or the string 'self_paced'
heat_temps = (43:49) + participant_parameters.calibration_factor;

%% ------------------------------ time stamp ------------------------------
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];

%% --------------------------- timing parameters --------------------------
% define durations of "get ready"
get_ready_duration = 1;

% define duration of pre stimulus fixation
pre_stim_duration_mean = 4; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
pre_stim_duration_min = 1; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
pre_stim_duration_max = 7; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
pre_stim_duration_interval = 0.5;  % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
pre_stim_durations = zeros(total_trials_per_block,num_blocks);
for ind = 1:total_trials_per_block*num_blocks
    pre_stim_durations(ind) = exp_sample(pre_stim_duration_mean,pre_stim_duration_min,pre_stim_duration_max,pre_stim_duration_interval);
end

% define durations of post-heat fixation
post_stim_fixation_duration_mean = 7; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
post_stim_fixation_duration_min = 3; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
post_stim_fixation_duration_max = 11; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
post_stim_fixation_duration_interval = 0.5;  % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
post_stim_fixation_durations = zeros(total_trials_per_block,num_blocks);
for ind = 1:total_trials_per_block*num_blocks
    post_stim_fixation_durations(ind) = exp_sample(post_stim_fixation_duration_mean,post_stim_fixation_duration_min,post_stim_fixation_duration_max,post_stim_fixation_duration_interval);
end

% define durations of ISI fixation
ISI_fixation_duration_mean = 3; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
ISI_fixation_duration_min = 1; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
ISI_fixation_duration_max = 5; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
ISI_fixation_duration_interval = 0.5;  % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
ISI_fixation_durations = zeros(total_trials_per_block,num_blocks);
for ind = 1:total_trials_per_block*num_blocks
    ISI_fixation_durations(ind) = exp_sample(ISI_fixation_duration_mean,ISI_fixation_duration_min,ISI_fixation_duration_max,ISI_fixation_duration_interval);
end

%% --------------------------- Heat parameters ----------------------------
% set temps random order. Make sure there's no strike of 3 successive stimuli with temp >=47
randomized_heat_temps = zeros(total_trials_per_block,num_blocks);
for block_num = 1:num_blocks
    valid_temps = 0;
    while valid_temps == 0
        temps = heat_temps(randperm(length(heat_temps)));
        block_heat_temps = [repelem(dummy_temp, num_dummy_trials_per_block) temps];
        if ~all(block_heat_temps(1:3)>=47) || ~all(block_heat_temps(2:4)>=47) || ~all(block_heat_temps(3:5)>=47) || ~all(block_heat_temps(4:6)>=47) || ~all(block_heat_temps(5:7)>=47) || ~all(block_heat_temps(6:8)>=47)
            randomized_heat_temps(:,block_num) = block_heat_temps;
            valid_temps = 1;
        end
    end
end

%% -------------------------- Biopac Parameters ---------------------------
% biopac channel settings for relevant events
% the biopac_code_dict for the entire experiment can be found in an excel
% file under main_dir/code
biopac_signal_out = struct;
biopac_signal_out.baseline = 0;
biopac_signal_out.task_id = 2;
biopac_signal_out.task_start = 7;
biopac_signal_out.task_end = 8;
biopac_signal_out.block_start = 9;
biopac_signal_out.block_end = 10;
biopac_signal_out.block_middle = 11;
biopac_signal_out.trial_start = 12;
biopac_signal_out.trial_end = 13;
biopac_signal_out.expectation_rating = 21;
biopac_signal_out.confidence_rating = 22;
biopac_signal_out.get_ready = 23;
biopac_signal_out.prestim_fixation = 24;
biopac_signal_out.poststim_fixation_start = 37;
biopac_signal_out.pain_rating_start = 38;
biopac_signal_out.isi_fixation_start = 39;
biopac_signal_out.potential_temps = [40:50, 40.5:49.5]; % temps that are coded
biopac_signal_out.stimulus_temps_signals = [25:35,45:54]; % the associated codes

%% ------------------- initialize psychtoolbox parameters -----------------
p = initialize_ptb_params(debugging_mode);

if ~debugging_mode
    HideCursor;
end

%% ----------------------- Make output data table -------------------------
var_names = {'subject_id','session','task_onset','block',...
    'block_onset','site','trial','trial_onset',...
    'start_sound_onset','middle_sound_onset','end_sound_onset',...
    'pain_expect_onset','pain_expect_response_onset','pain_expect',...
    'get_ready_onset','get_ready_duration','pre_stim_fixation_onset','pre_stim_fixation_duration',...
    'heat_onset','heat_temp','heat_peak_duration','heat_ramp_up_rate','heat_ramp_down_rate',...
    'total_stim_duration','program_num','medocResponseStr_choose_program', 'medocResponseStr_trigger',...
    'post_stim_fixation_onset','post_stim_fixation_duration',...
    'pain_rating_onset','pain_rating_response_onset','pain_rating', ...
    'ISI_fixation_onset','trial_offset','use_biopac',...
    'pain_expect_trajectory','pain_rating_trajectory'};
var_types = {'string','double','double','double',...
    'double','double','double','double',...
    'double','double','double',...
    'double','double','double',...
    'double','double','double','double',...
    'double','double','double','double','double',...
    'double','double','string','string',...
    'double','double',...
    'double','double','double',...
    'double','double', 'logical',...
    'cell','cell'};
part1_data_table = table('Size',[total_trials_per_block*num_blocks,length(var_names)],'VariableTypes',var_types,'VariableNames',var_names);
part1_data_table.subject_id(:) = subject_str;
part1_data_table.session(:) = session_num;
part1_data_table.block(:) = repelem(1:num_blocks,total_trials_per_block);
part1_data_table.site(:) = repelem(sites_order,total_trials_per_block);
part1_data_table.trial(:) = repmat(1:total_trials_per_block,1,num_blocks);
part1_data_table.get_ready_duration(:) = get_ready_duration;
part1_data_table.pre_stim_fixation_duration(:) = pre_stim_durations(:);
part1_data_table.post_stim_fixation_duration(:) = post_stim_fixation_durations(:);
part1_data_table.heat_temp(:) = randomized_heat_temps(:);
part1_data_table.heat_peak_duration(:) = heat_peak_duration;
part1_data_table.heat_ramp_up_rate(:) = ramp_up_rate;
part1_data_table.heat_ramp_down_rate(:) = ramp_down_rate;
part1_data_table.use_biopac(:) = use_biopac;
writetable(part1_data_table, data_filename);

%% ------------------------- Load audio files -----------------------------
[gopro_start, Fs_gopro_start] = audioread(fullfile(main_dir, 'audio_files', 'GoPro_start_recording.m4a'));
[gopro_stop, Fs_gopro_stop] = audioread(fullfile(main_dir, 'audio_files', 'GoPro_stop_recording.m4a'));
[gopro_hilight, Fs_gopro_hilight] = audioread(fullfile(main_dir, 'audio_files', 'GoPro_hilight.m4a'));
[audio_session, Fs_audio_session] = audioread(fullfile(main_dir, 'audio_files', 'session.m4a'));
[audio_task, Fs_audio_task] = audioread(fullfile(main_dir, 'audio_files', 'task.m4a'));
[audio_block, Fs_audio_block] = audioread(fullfile(main_dir, 'audio_files', 'block.m4a'));
[audio_which_task, Fs_audio_which_task] = audioread(fullfile(main_dir, 'audio_files', [task_name_audio_file '.m4a']));

% load recordings of all numbers
audio_numbers = cell(10,1);
Fs_numbers = zeros(10,1);
for ind = 1:10
   [audio_numbers{ind}, Fs_numbers(ind)] = audioread(fullfile(main_dir, 'audio_files', [num2str(ind) '.m4a']));
end

%% --------------------------- Load instructions --------------------------
instruct_filepath = [main_dir filesep 'instructions'];
instruct_task_start = fullfile(instruct_filepath, 'dose_response_start.png');
instruct_between_blocks = fullfile(instruct_filepath, 'between_blocks.png');
instruct_task_end = fullfile(instruct_filepath, 'task_end.png');
%get_ready = fullfile(instruct_filepath, 'get_ready.png');

%% ------------------------------------------------------------------------------
%                             Run blocks & trials
%________________________________________________________________________________

% set the signal in the digital channels via parallel port
if use_biopac
    biopac_signal(biopac_signal_out.task_id);
end

% start block loop
for block_num = 2:num_blocks
    
    %% Show the site number, and wait for the experimenter to indicate everything is ready (thermode and sensors are placed, data is recorded on Acknowledge and Medoc's system is waiting for external trigger)
    Screen('TextSize', p.ptb.window, 36);
    site_msg = ['Experimenter, please place the thermode on site ' num2str(sites_order(block_num)) '.\n\nMake sure that:\n\n(1) The Biopac sensors are placed and turned on\n(2) Acknowledge is recording data\n(3) Medoc''s system is waiting for trigger\n(4) The GoPro is open and charged\n(5) The thermal camera is recording and charged\n\nPress ''s'' when ready to start.'];
    DrawFormattedText(p.ptb.window, site_msg, 'center', 'center',p.ptb.white);
    Screen('Flip',p.ptb.window);
    WaitKeyPress(p.keys.start);
    
    
    %% -------- Block start routine (instructions, response, sound) -------
    %Screen('TextSize',p.ptb.window,72);
    if block_num == 1
        start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_task_start));
    else
        start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_between_blocks));
    end
    Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
    Screen('Flip',p.ptb.window);
    
    % Wait for participant's confirmation to Begin
    WaitKeyPress(p.keys.start);
    if block_num == 2
        task_onset = GetSecs;
        part1_data_table.task_onset(:) = 0; % task_onset is used as the anchor for all other timings
        if use_biopac
            biopac_signal(biopac_signal_out.task_start);
        end
    end
    Screen('Flip',p.ptb.window);
    WaitSecs(2);
    
    % start gopro recording with voice command ("GoPro start recording")
    sound(gopro_start, Fs_gopro_start);
    WaitSecs(5);
    % Play a sound for post-hoc syncronization with the facial and thermal recordings ("GoPro hilight")
    sound(gopro_hilight, Fs_gopro_hilight);
    start_sound_onset = GetSecs;
    part1_data_table.start_sound_onset(1+total_trials_per_block*(block_num-1)) = start_sound_onset - task_onset;
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
    WaitSecs(1);
    % block
    sound(audio_block, Fs_audio_block);
    WaitSecs(1.5);
    % block number
    sound(audio_numbers{block_num}, Fs_numbers(block_num));
    
    % record block onset time
    block_onset = GetSecs;
    part1_data_table.block_onset(1+(total_trials_per_block*(block_num-1)):total_trials_per_block*(block_num)) = block_onset - task_onset;
    if use_biopac
        biopac_signal(biopac_signal_out.block_start);
    end
    
    %% ---------------------------- Trials loop ---------------------------
    % if debugging_mode, run just a few trials for each block
    if debugging_mode
        total_trials_per_block = 2;
    end
    for trial_num = 1:total_trials_per_block
        trial_table_ind = trial_num + total_trials_per_block*(block_num-1);
        % if it's the middle trial, play a sound for post-hoc syncronization
        % with the facial and thermal recordings
        if trial_num == ceil(total_trials_per_block / 2)
            part1_data_table.middle_sound_onset(trial_table_ind) = GetSecs - task_onset;
            sound(gopro_hilight, Fs_gopro_hilight);
            if use_biopac
                biopac_signal(biopac_signal_out.block_middle);
            end
            WaitSecs(2);
        end
        trial_onset = GetSecs;
        part1_data_table.trial_onset(trial_table_ind) = trial_onset - task_onset;
        if use_biopac
            biopac_signal(biopac_signal_out.trial_start);
        end
        
        %% choose a program for the thermode and start it (no trigger yet)
        [thermode_program, total_stim_duration, responseStr_choose_program] = thermode_choose_program(experiment_name, part1_data_table.heat_temp(trial_table_ind), part1_data_table.heat_peak_duration(trial_table_ind), part1_data_table.heat_ramp_up_rate(trial_table_ind), part1_data_table.heat_ramp_down_rate(trial_table_ind), main_dir);
        part1_data_table.program_num(trial_table_ind) = thermode_program;
        part1_data_table.total_stim_duration(trial_table_ind) = total_stim_duration;
        part1_data_table.medocResponseStr_choose_program(trial_table_ind) = responseStr_choose_program;
        if trial_num > num_dummy_trials_per_block && mod(session_num, 2) == 1 % ask for expectation ratings only if it's not a dummy trial and an odd session
            %% Expectation rating
            if use_biopac
                biopac_signal(biopac_signal_out.expectation_rating);
            end
            rating_type = 'expectation_pain';
            [pain_expect, trajectory, rating_onset, response_onset] = semi_circular_rating(rating_type, main_dir, p, rating_duration);
            part1_data_table.pain_expect(trial_table_ind) = pain_expect;
            part1_data_table.pain_expect_onset(trial_table_ind) = rating_onset-task_onset;
            %task1_data_table.pain_expect_duration(trial_table_ind) = RT;
            part1_data_table.pain_expect_trajectory{trial_table_ind} = trajectory;
            part1_data_table.pain_expect_response_onset(trial_table_ind) = response_onset-task_onset;
        end
        %% "Get ready!"
        Screen('TextSize', p.ptb.window, 48);
        DrawFormattedText(p.ptb.window, 'Get ready!', 'center', 'center',p.ptb.white);
        %start.texture = Screen('MakeTexture',p.ptb.window, imread(get_ready));
        %Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
        get_ready_onset = Screen('Flip',p.ptb.window);
        if use_biopac
            biopac_signal(biopac_signal_out.get_ready);
        end
        part1_data_table.get_ready_onset(trial_table_ind) = get_ready_onset - task_onset;
        WaitSecs(get_ready_duration);
        
        %% jittered pre-stim fixation cross
        %Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        %    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
        Screen('TextSize', p.ptb.window, 72);
        DrawFormattedText(p.ptb.window, '+', 'center', 'center',p.ptb.white);
        pre_stim_fixation_onset = Screen('Flip', p.ptb.window);
        if use_biopac
            biopac_signal(biopac_signal_out.prestim_fixation);
        end
        part1_data_table.pre_stim_fixation_onset(trial_table_ind) = pre_stim_fixation_onset - task_onset;
        WaitSecs(pre_stim_durations(trial_table_ind));
        
        %% pain delivery
        % the thermode function triggers the thermodes and waits for the
        % duration of the stimulus (including ramp up and down)
        if use_biopac
            biopac_signal(biopac_signal_out.stimulus_temps_signals(biopac_signal_out.potential_temps == part1_data_table.heat_temp(trial_table_ind)));
        end
        [heat_onset, responseStr_trigger] = thermode_trigger(thermode_program, total_stim_duration); % delivers the heat stimuli
        part1_data_table.heat_onset(trial_table_ind) = heat_onset - task_onset;
        part1_data_table.medocResponseStr_trigger(trial_table_ind) = responseStr_trigger;
        
        %% post-stim jittered fixation
        %Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        %    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
        Screen('TextSize', p.ptb.window, 72);
        DrawFormattedText(p.ptb.window, '+', 'center', 'center',p.ptb.white);
        post_stim_fixation_onset = Screen('Flip', p.ptb.window);
        if use_biopac
            biopac_signal(biopac_signal_out.poststim_fixation_start);
        end
        part1_data_table.post_stim_fixation_onset(trial_table_ind) = post_stim_fixation_onset - task_onset;
        WaitSecs(post_stim_fixation_durations(trial_table_ind));
        
        %% pain ratings
        if use_biopac
            biopac_signal(biopac_signal_out.pain_rating_start);
        end
        rating_type = 'pain';
        [pain_rating, trajectory, rating_onset, response_onset] = semi_circular_rating(rating_type, main_dir, p, rating_duration);
        part1_data_table.pain_rating(trial_table_ind) = pain_rating;
        part1_data_table.pain_rating_onset(trial_table_ind) = rating_onset-task_onset;
        %task1_data_table.pain_rating_duration(trial_table_ind) = RT;
        part1_data_table.pain_rating_trajectory{trial_table_ind} = trajectory;
        part1_data_table.pain_rating_response_onset(trial_table_ind) = response_onset-task_onset;
        
        %% ISI jittered fixation
        %Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        %    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
        Screen('TextSize', p.ptb.window, 72);
        DrawFormattedText(p.ptb.window, '+', 'center', 'center',p.ptb.white);
        ISI_fixation_onset = Screen('Flip', p.ptb.window);
        if use_biopac
            biopac_signal(biopac_signal_out.isi_fixation_start);
        end
        part1_data_table.ISI_fixation_onset(trial_table_ind) = ISI_fixation_onset - task_onset;
        WaitSecs(ISI_fixation_durations(trial_table_ind));
        while GetSecs - trial_onset < 30
            % each trial should be at least 30 secs to follow the lab's guidelines with heat stimuli
        end
        
        %% trial offset
        trial_offset = GetSecs;
        if use_biopac
            biopac_signal(biopac_signal_out.trial_end);
        end
        part1_data_table.trial_offset(trial_table_ind) = trial_offset - task_onset;
        
        %% save trial info
        writetable(part1_data_table, data_filename);
        
    end % end trial loop
    
    % Play a sound for post-hoc syncronization with the facial and thermal recordings ("GoPro hilight")
    sound(gopro_hilight, Fs_gopro_hilight);
    end_sound_onset = GetSecs;
    part1_data_table.end_sound_onset(trial_table_ind) = end_sound_onset - task_onset;
    WaitSecs(2);
    % stop gopro recording with voice command ("GoPro stop recording")
    sound(gopro_stop, Fs_gopro_stop);
    
    %% signal Biopac that the block ended
    if use_biopac
        biopac_signal(biopac_signal_out.block_end);
    end
    
end % end block loop

%% save final table (also as a .mat file)
if use_biopac
    biopac_signal(biopac_signal_out.task_end);
end
writetable(part1_data_table, data_filename);
save([data_filename(1:end-4) '_' timestamp], 'part1_data_table');

%% show end of block / end of task msg
start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_task_end));
Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
Screen('Flip',p.ptb.window);

%% wait for experimenter to end the task
WaitKeyPress(p.keys.end);
Screen('Flip',p.ptb.window);

%% end part1
cleanup;

end % end main function
