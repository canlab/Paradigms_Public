function [part3_data_table, post_session_table, wtp] = run_NOF_part3(running_mode)
% PART 3 - COUNTERFACTUAL
%
% code by Rotem Botvinik-Nezer
% based on codes by Heejung Jung and Xiaochun Han
% Last updated February 2021
%
% This function runs the 3rd part (counterfactual task) of the NOF experiment.
% This task takes place only in sessions 7-10 (when the pain-cue part is shorter).
%
% This code runs all blocks of the task.
% Before each block (including the first one), there is a screen with
% instructions to the experimenter with everything that needs to happen
% before starting the block (for example, the skin site to put the thermode
% on). It then waits for the experimenter to indicate everything is ready,
% before presenting the task instructions to the participant.
% Code ends after all blocks are completed (based on num_blocks)
% Each block starts with one dummy trial for adaptation effects.
% Each trial includes the following parts:
% The two alternatives are shown, outcome is shown (chosen stim),
% post-outcome fixation, affect rating (negative to positive),
% "Get ready!", pre-stim fixation, heat stim/monetary outcome:
% if pain trial: pain stim, post-stim fixation, pain ratings (self-paced),
% if money trial: monetary amount shown
% ISI fixation.
% After all blocks are completed, there's a self-paced post-session task, where each
% pair is presented once and participants are asked to indicate which of
% the two options they prefer in each pair. Then, they are asked to
% indicate how much they are willing to pay to avoid each of the 3 pain
% stimuli (low, medium, high).
%
% Input:
% running_mode: should be 'debugging' for debugging mode (smaller screen,
% cursor is shown, less trials per block). Otherwise, leave empty.
%
% Output:
% part3_data_table: the output table (also saved to file)
% post_session_table: the output table of the post-session task (also saved
% to file)
%
% Functions needed to run properly:
% semi_circular_rating.m
% exp_sample.m
% cleanup.m
% initialize_ptb_params.m
% WaitKeyPressMultiple.m
% WaitKeyPress.m
% thermode_trigger.m and thermode_choose_program.m (and all their dependents)
% biopac_signal.m
% get_params_from_experimenter.m
%
% Directories and files required to run properly:
% (sub folders in the main experiment folder)
% 'data/' for the output
% 'instructions/' with the pics of the instructions (start block, end block)
% 'audio_files/' with the audio files
% 'scale/' with pics of the scales to be used for rating
% 'cues/' with pics of the cues (money, pain)

%% set random seed
rng shuffle

%% use debugging mode?
if nargin > 0 && strcmp(running_mode, 'debugging')
    debugging_mode = 1;
else
    debugging_mode = 0;
end

%% -----------------------------------------------------------------------------
%                           Parameters
% ______________________________________________________________________________

%% --------------------------- Basic parameters ---------------------------
experiment_name = 'NOF';
task_name = 'counterfactual';
task_name_audio_file = 'CF';
main_dir = fileparts(pwd); % main dir is one dir up
output_dir = [main_dir filesep 'data'];

%% --------------------- Parameters from experimenter ---------------------
[data_filename, session_num, use_biopac, ~, subject_str, subj_main_output_dir, ~] = get_params_from_experimenter(experiment_name,task_name,output_dir);

%% ------------------- Load participant parameters file -------------------
filename = fullfile(subj_main_output_dir, [subject_str '_parameters.mat']);
load(filename, 'participant_parameters');

%% --------------------------- Fixed parameters ---------------------------
sites_order = participant_parameters.sites.counterfactual(session_num,:);
num_blocks_per_session = 2;
counterfactual_sessions = 7:10;
num_sessions = length(counterfactual_sessions);
exp_trials_per_block = 8; % not including the dummy trial
num_dummy_trials_per_block = 1;
dummy_temp = 47 + participant_parameters.calibration_factor;
total_trials_per_block = num_dummy_trials_per_block + exp_trials_per_block;
heat_peak_duration = 5; % heat stimulus duration (at peak) in seconds
ramp_up_rate = 10; % ramp up rate in degrees per second (TSA2 max is 13)
ramp_down_rate = 13; % ramp up rate in degrees per second (TSA2 max is 13)
rating_duration = 'self_paced'; % duration in seconds or the string 'self_paced'
pair_duration = 1.5; % duration of binary options display, in secs
lottery_duration = 3;
outcome_duration = 3; % duration of outcome presentation, in secs
med_heat_temps = (47:48) + participant_parameters.calibration_factor;
low_heat_temp = 46 + participant_parameters.calibration_factor;
high_heat_temp = 49 + participant_parameters.calibration_factor;
potential_gains = 3:6;
potential_losses = -6:-3;
money_outcome_duration = 5; % duration of monetary outcome display, in secs

%% ------------------------------ time stamp ------------------------------
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];

%% --------------------------- timing parameters --------------------------
% define durations of "get ready"
get_ready_duration = 1;

% define duration of post-outcome fixation
post_outcome_duration_mean = 3; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
post_outcome_duration_min = 1; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
post_outcome_duration_max = 5; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
post_outcome_duration_interval = 0.5;  % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
post_outcome_durations = zeros(total_trials_per_block,num_blocks_per_session);
for ind = 1:total_trials_per_block*num_blocks_per_session
    post_outcome_durations(ind) = exp_sample(post_outcome_duration_mean,post_outcome_duration_min,post_outcome_duration_max,post_outcome_duration_interval);
end
% define duration of pre stimulus fixation
pre_stim_duration_mean = 3; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
pre_stim_duration_min = 1; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
pre_stim_duration_max = 5; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
pre_stim_duration_interval = 0.5;  % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
pre_stim_durations = zeros(total_trials_per_block,num_blocks_per_session);
for ind = 1:total_trials_per_block*num_blocks_per_session
    pre_stim_durations(ind) = exp_sample(pre_stim_duration_mean,pre_stim_duration_min,pre_stim_duration_max,pre_stim_duration_interval);
end
% define durations of post-stim fixation
post_stim_fixation_duration_mean = 7; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
post_stim_fixation_duration_min = 3; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
post_stim_fixation_duration_max = 11; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
post_stim_fixation_duration_interval = 0.5;  % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
post_stim_fixation_durations = zeros(total_trials_per_block,num_blocks_per_session);
for ind = 1:total_trials_per_block*num_blocks_per_session
    post_stim_fixation_durations(ind) = exp_sample(post_stim_fixation_duration_mean,post_stim_fixation_duration_min,post_stim_fixation_duration_max,post_stim_fixation_duration_interval);
end
% define durations of ISI fixation
ISI_fixation_duration_mean = 3; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
ISI_fixation_duration_min = 1; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
ISI_fixation_duration_max = 5; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
ISI_fixation_duration_interval = 0.5;  % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
ISI_fixation_durations = zeros(total_trials_per_block,num_blocks_per_session);
for ind = 1:total_trials_per_block*num_blocks_per_session
    ISI_fixation_durations(ind) = exp_sample(ISI_fixation_duration_mean,ISI_fixation_duration_min,ISI_fixation_duration_max,ISI_fixation_duration_interval);
end

%% ------------------------------------------------------------------------
%                      Organize trials for all sessions
% _________________________________________________________________________
% if it's the first session with the counterfactual task, organize trials
% for all sessions and save the table
table_filename = fullfile(subj_main_output_dir, [subject_str '_counterfactual_trials_table.csv']);
if session_num == counterfactual_sessions(1)
    % load general table
    load([main_dir filesep 'cues' filesep 'counterfactual_trials_table.mat'], 'counterfactual_all_trials_table');
    counterfactual_all_trials_table.heat_temp(:) = 0;
    counterfactual_all_trials_table.heat_temp(strcmp(counterfactual_all_trials_table.heat,'low')) = low_heat_temp;
    counterfactual_all_trials_table.heat_temp(strcmp(counterfactual_all_trials_table.heat,'high')) = high_heat_temp;
    counterfactual_all_trials_table.heat_temp(strcmp(counterfactual_all_trials_table.heat,'med1')) = med_heat_temps(1);
    counterfactual_all_trials_table.heat_temp(strcmp(counterfactual_all_trials_table.heat,'med2')) = med_heat_temps(2);
    % randomize gains and losses across blocks and sessions
    % until no session has a final outcome of lossing more than $3
    valid_monetary_outcome = 0;
    while ~valid_monetary_outcome
        % gains
        num_trials_with_gain = sum(strcmp(counterfactual_all_trials_table.right_option,'gain') | strcmp(counterfactual_all_trials_table.left_option,'gain'));
        random_gains = [];
        for ind = 1:num_trials_with_gain/length(potential_gains)
            random_gains = [random_gains potential_gains(randperm(length(potential_gains)))];
        end
        counterfactual_all_trials_table.gain(:) = 0;
        counterfactual_all_trials_table.gain(strcmp(counterfactual_all_trials_table.right_option,'gain') | strcmp(counterfactual_all_trials_table.left_option,'gain')) = random_gains;
        % losses
        num_trials_with_loss = sum(strcmp(counterfactual_all_trials_table.right_option,'lose') | strcmp(counterfactual_all_trials_table.left_option,'lose'));
        random_losses = [];
        for ind = 1:num_trials_with_loss/length(potential_losses)
            random_losses = [random_losses potential_losses(randperm(length(potential_losses)))];
        end
        counterfactual_all_trials_table.loss(:) = 0;
        counterfactual_all_trials_table.loss(strcmp(counterfactual_all_trials_table.right_option,'lose') | strcmp(counterfactual_all_trials_table.left_option,'lose')) = random_losses;
        
        % make sure they don't lose more than $3 on any specific session, and
        % lose/gain something in the first session (so they won't think it
        % doesn't matter anyway) and overall their summed outcome from
        % sessions 7-10 is either 0 or positive
        final_outcomes = zeros(num_sessions, 1);
        for session_ind = 1:num_sessions
            cur_session = counterfactual_sessions(session_ind);
            gains_session = counterfactual_all_trials_table.gain(strcmp(counterfactual_all_trials_table.outcome, 'gain') & counterfactual_all_trials_table.session == cur_session);
            sum_gains = sum(gains_session);
            losses_session = counterfactual_all_trials_table.loss(strcmp(counterfactual_all_trials_table.outcome, 'lose') & counterfactual_all_trials_table.session == cur_session);
            sum_losses = sum(losses_session);
            final_outcomes(session_ind) = sum_gains + sum_losses;
        end
        if all(final_outcomes >= -3) && final_outcomes(1)~=0 && sum(final_outcomes)>=0
            valid_monetary_outcome = 1;
        end
    end
    
    % randomly divide trials in each session to blocks
    % but keep a fixed number of pain outcome trials and equal distribution of
    % temps across blocks
    counterfactual_all_trials_table.block(:) = 0;
    for session_ind = 1:num_sessions
        cur_session = counterfactual_sessions(session_ind);
        session_trials = counterfactual_all_trials_table(counterfactual_all_trials_table.session == cur_session,:);
        session_trials = session_trials(randperm(height(session_trials)),:);
        session_trials = sortrows(session_trials, {'outcome','is_outcome_best','heat'});
        for block_num = 1:num_blocks_per_session
            block_trials = session_trials(block_num:num_blocks_per_session:end,:);
            block_trials.block(:) = block_num;
            % randomize order of trials within each block
            % make sure the same outcome doesn't repeat on more than 2
            % consecutive trials, and the same for best/worst outcome, and
            % for temp>=48
            invalid_num_repetitions = 3;
            valid_trials_order = 0;
            while ~valid_trials_order
                block_trials = block_trials(randperm(height(block_trials)),:);
                valid_trials_order = 1;
                for trial_ind = 1:height(block_trials)-invalid_num_repetitions+1
                    if length(unique(block_trials.outcome(trial_ind:trial_ind + invalid_num_repetitions - 1))) == 1 || length(unique(block_trials.is_outcome_best(trial_ind:trial_ind + invalid_num_repetitions - 1))) == 1 || all(block_trials.heat_temp(trial_ind:trial_ind + invalid_num_repetitions - 1) >= (48 + participant_parameters.calibration_factor)) || all(block_trials.heat_temp(trial_ind:trial_ind + invalid_num_repetitions - 1) <= (46 + participant_parameters.calibration_factor))
                        valid_trials_order = 0;
                        break
                    end
                end
            end
            block_trials.trial_num(:) = 1:height(block_trials);
            session_trials(block_num:num_blocks_per_session:end,:) = block_trials;
        end
        session_trials = sortrows(session_trials, {'block', 'trial_num'});
        counterfactual_all_trials_table(counterfactual_all_trials_table.session == cur_session,:) = session_trials;
    end
    
    % save participant table for later sessions
    writetable(counterfactual_all_trials_table, table_filename);
    
    % If it's not the first session with the counterfactual task, load the
    % table that was created for the specific participant
else
    % load participant table
    counterfactual_all_trials_table = readtable(table_filename);
end

%% ------------------------------------------------------------------------
%                    Organize trials for current session
% _________________________________________________________________________
% take trials for current session
exp_trials = counterfactual_all_trials_table(counterfactual_all_trials_table.session == session_num,:);
% add dummy trials
num_dummy_trials = num_dummy_trials_per_block * num_blocks_per_session;
dummy_trials = exp_trials(1:num_dummy_trials,:);
dummy_trials.trial_num(:) = 0;
dummy_trials.block(:) = repelem(1:num_blocks_per_session,num_dummy_trials_per_block,1);
dummy_trials(:,{'left_option','right_option','outcome','heat'}) = {'dummy'};
dummy_trials.is_outcome_best(:) = NaN;
dummy_trials.heat_temp(:) = dummy_temp;
dummy_trials.gain(:) = 0;
dummy_trials.loss(:) = 0;
% concat dummy and exp trials
all_trials = [dummy_trials; exp_trials];
% sort trials based on block and then trial_num, to put the dummy trials at
% the beginning of each block
all_trials = sortrows(all_trials,{'block', 'trial_num'});
% compute comulative monetary outcome
all_trials.monetary_outcome(:) = 0;
all_trials.monetary_outcome(ismember(all_trials.outcome, {'gain', 'lose'})) = all_trials.gain(ismember(all_trials.outcome, {'gain', 'lose'})) + all_trials.loss(ismember(all_trials.outcome, {'gain', 'lose'}));
all_trials.cum_monetary_outcome = cumsum(all_trials.monetary_outcome);

%% -------------------------- Biopac Parameters ---------------------------
% biopac channel settings for relevant events
% the biopac_code_dict for the entire experiment can be found in an excel
% file under main_dir/code
biopac_signal_out = struct;
biopac_signal_out.baseline = 0;
biopac_signal_out.task_id = 6;
biopac_signal_out.task_start = 7;
biopac_signal_out.task_end = 8;
biopac_signal_out.block_start = 9;
biopac_signal_out.block_end = 10;
biopac_signal_out.block_middle = 11;
biopac_signal_out.trial_start = 12;
biopac_signal_out.trial_end = 13;
biopac_signal_out.get_ready = 23;
biopac_signal_out.prestim_fixation = 24;
biopac_signal_out.poststim_fixation_start = 37;
biopac_signal_out.pain_rating_start = 38;
biopac_signal_out.isi_fixation_start = 39;
biopac_signal_out.potential_temps = [40:50, 40.5:49.5]; % temps that are coded
biopac_signal_out.stimulus_temps_signals = [25:35,45:54]; % the associated codes
biopac_signal_out.pair_start_med_low = 60;
biopac_signal_out.pair_start_med_high = 61;
biopac_signal_out.pair_start_med_gain = 62;
biopac_signal_out.pair_start_med_loss = 63;
biopac_signal_out.lottery_start = 64;
biopac_signal_out.outcome_start_med = 65;
biopac_signal_out.outcome_start_low = 66;
biopac_signal_out.outcome_start_high = 67;
biopac_signal_out.outcome_start_gain = 68;
biopac_signal_out.outcome_start_loss = 69;
biopac_signal_out.post_outcome_fixation_start = 70;
biopac_signal_out.affect_rating = 71;
biopac_signal_out.gain_outcome_start = 72;
biopac_signal_out.loss_outcome_start = 73;

%% ------------------- initialize psychtoolbox parameters -----------------
p = initialize_ptb_params(debugging_mode);

if ~debugging_mode
    HideCursor;
end

%% ------------------- set left and right rects for stimuli -----------------
% get screen center
xcenter = p.ptb.screenXpixels/2;
ycenter = p.ptb.screenYpixels/2;
% stimuli locations
stimW = 298;
stimH = 197;
distcent = 150;
left_rect = [xcenter-stimW-distcent ycenter-stimH/2 xcenter-distcent ycenter+stimH/2];
right_rect = [xcenter+distcent ycenter-stimH/2 xcenter+stimW+distcent ycenter+stimH/2];

%% ----------------------- Make output data table -------------------------
var_names = {'subject_id','task_onset','block_onset','site','trial_onset',...
    'start_sound_onset','middle_sound_onset','end_sound_onset',...
    'pair_onset','pair_duration','lottery_onset','lottery_duration',...
    'outcome_onset','outcome_duration','post_outcome_fixation_onset','post_outcome_fixation_duration',...
    'affect_rating_onset','affect_rating_response_onset','affect_rating',...
    'get_ready_onset','get_ready_duration','pre_stim_fixation_onset','pre_stim_fixation_duration',...
    'heat_onset','heat_peak_duration','heat_ramp_up_rate','heat_ramp_down_rate',...
    'total_stim_duration','program_num','medocResponseStr_choose_program', 'medocResponseStr_trigger',...
    'monetary_outcome_onset','monetary_outcome_duration',...
    'post_stim_fixation_onset','post_stim_fixation_duration',...
    'pain_rating_onset','pain_rating_response_onset','pain_rating', ...
    'ISI_fixation_onset','ISI_fixation_duration','trial_offset','use_biopac',...
    'pain_rating_trajectory','affect_rating_trajectory'};
var_types = {'string','double','double','double','double',...
    'double','double','double',...
    'double','double','double','double',...
    'double','double','double','double',...
    'double','double','double',...
    'double','double','double','double',...
    'double','double','double','double',...
    'double','double','string','string',...
    'double','double'...
    'double','double',...
    'double','double','double',...
    'double','double','double','logical',...
    'cell','cell'};

part3_data_table = table('Size',[total_trials_per_block*num_blocks_per_session,length(var_names)],'VariableTypes',var_types,'VariableNames',var_names);
% concat the table with all trials information with this table
part3_data_table = [all_trials, part3_data_table];
part3_data_table.subject_id(:) = subject_str;
part3_data_table.pair_duration(:) = pair_duration;
part3_data_table.lottery_duration(:) = lottery_duration;
part3_data_table.outcome_duration(:) = outcome_duration;
part3_data_table.post_outcome_fixation_duration(:) = post_outcome_durations(:);
part3_data_table.get_ready_duration(:) = get_ready_duration;
part3_data_table.pre_stim_fixation_duration(:) = pre_stim_durations(:);
part3_data_table.post_stim_fixation_duration(:) = post_stim_fixation_durations(:);
part3_data_table.heat_peak_duration(part3_data_table.heat_temp~=0) = heat_peak_duration;
part3_data_table.heat_ramp_up_rate(part3_data_table.heat_temp~=0) = ramp_up_rate;
part3_data_table.heat_ramp_down_rate(part3_data_table.heat_temp~=0) = ramp_down_rate;
part3_data_table.monetary_outcome_duration(strcmp(part3_data_table.heat,'none')) = money_outcome_duration;
part3_data_table.ISI_fixation_duration(:) = ISI_fixation_durations(:);
part3_data_table.use_biopac(:) = use_biopac;
part3_data_table.site(:) = repelem(sites_order,total_trials_per_block);

writetable(part3_data_table, data_filename);

%% ---------------------------- load cues pics ----------------------------
cues_dir = [main_dir filesep 'cues'];
counterfactual_alternatives_dir = [cues_dir filesep 'counterfactual'];
all_cues = dir([counterfactual_alternatives_dir filesep '*.png']);
all_cues = extractfield(all_cues, 'name')';
all_cues_pics = cellfun(@imread, strcat([counterfactual_alternatives_dir filesep], all_cues),'UniformOutput', false);
cues_table = table(all_cues, all_cues_pics);
%pair_pic = imread([cues_dir filesep 'counterfactual_trial.png']);
% post_session_pair_pic = imread([cues_dir filesep 'counterfactual_post_session_trial.png']);

%% -------------------- load arrows pics (for lottery) --------------------
arrows_dir = [counterfactual_alternatives_dir filesep 'arrows'];
all_arrows = dir([arrows_dir filesep '*.png']);
all_arrows = extractfield(all_arrows, 'name')';
all_arrows_pics = cellfun(@imread, strcat([arrows_dir filesep], all_arrows),'UniformOutput', false);

%% ------------------------- Load audio files -----------------------------
[gopro_start, Fs_gopro_start] = audioread([main_dir filesep 'audio_files' filesep 'GoPro_start_recording.m4a']);
[gopro_stop, Fs_gopro_stop] = audioread([main_dir filesep 'audio_files' filesep 'GoPro_stop_recording.m4a']);
[gopro_hilight, Fs_gopro_hilight] = audioread([main_dir filesep 'audio_files' filesep 'GoPro_hilight.m4a']);
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
instruct_task_start = fullfile(instruct_filepath, 'counterfactual_start.png');
instruct_between_blocks = fullfile(instruct_filepath, 'between_blocks.png');
instruct_post_session = fullfile(instruct_filepath, 'counterfactual_post_session_tasks.png');
%get_ready = fullfile(instruct_filepath, 'get_ready.png');

%% ------------------------------------------------------------------------------
%                             Run blocks & trials
%________________________________________________________________________________

% set the signal in the digital channels via parallel port
if use_biopac
    biopac_signal(biopac_signal_out.task_id);
end

% start block loop
for block_num = 1:num_blocks_per_session
    
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
    if block_num == 1
        task_onset = GetSecs;
        part3_data_table.task_onset(:) = 0; % task_onset is used as the anchor for all other timings
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
    part3_data_table.start_sound_onset(1+total_trials_per_block*(block_num-1)) = task_onset-start_sound_onset;
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
    part3_data_table.block_onset(1+(total_trials_per_block*(block_num-1)):total_trials_per_block*(block_num)) = block_onset - task_onset;
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
        pain_trial = part3_data_table.heat_temp(trial_table_ind)~=0;
        dummy_trial = strcmp(part3_data_table.heat(trial_table_ind), 'dummy');
        % if it's the middle trial, play a sound for post-hoc syncronization
        % with the facial and thermal recordings
        if trial_num == ceil(total_trials_per_block / 2)
            part3_data_table.middle_sound_onset(trial_table_ind) = GetSecs - task_onset;
            sound(gopro_hilight, Fs_gopro_hilight);
            if use_biopac
                biopac_signal(biopac_signal_out.block_middle);
            end
            WaitSecs(2);
        end
        trial_onset = GetSecs;
        part3_data_table.trial_onset(trial_table_ind) = trial_onset - task_onset;
        if use_biopac
            biopac_signal(biopac_signal_out.trial_start);
        end
        
        if pain_trial
            %% choose a program for the thermode and start it (no trigger yet)
            [thermode_program, total_stim_duration, responseStr_choose_program] = thermode_choose_program(experiment_name, part3_data_table.heat_temp(trial_table_ind), part3_data_table.heat_peak_duration(trial_table_ind), part3_data_table.heat_ramp_up_rate(trial_table_ind), part3_data_table.heat_ramp_down_rate(trial_table_ind), main_dir);
            part3_data_table.program_num(trial_table_ind) = thermode_program;
            part3_data_table.total_stim_duration(trial_table_ind) = total_stim_duration;
            part3_data_table.medocResponseStr_choose_program(trial_table_ind) = responseStr_choose_program;
        end
        if ~dummy_trial %  display pair and ask for expectation ratings only if it's not a dummy trial
            
            %% display pair
            outcome = part3_data_table.outcome{trial_table_ind};
            left_stim = part3_data_table.left_option{trial_table_ind};
            if strcmp(left_stim, 'gain') || strcmp(left_stim, 'lose')
                left_stim = [left_stim, num2str(abs(part3_data_table.gain(trial_table_ind)+part3_data_table.loss(trial_table_ind)))];
                if part3_data_table.heat_temp(trial_table_ind)==0 % if outcome is monetary
                    outcome =  left_stim;
                end
            end
            right_stim = part3_data_table.right_option{trial_table_ind};
            if strcmp(right_stim, 'gain') || strcmp(right_stim, 'lose')
                right_stim = [right_stim, num2str(abs(part3_data_table.gain(trial_table_ind)+part3_data_table.loss(trial_table_ind)))];
                if part3_data_table.heat_temp(trial_table_ind)==0 % if outcome is monetary
                    outcome =  right_stim;
                end
            end
            left_stim_pic = cues_table.all_cues_pics{strcmp(cues_table.all_cues,[left_stim '.png'])};
            right_stim_pic = cues_table.all_cues_pics{strcmp(cues_table.all_cues,[right_stim '.png'])};
            outcome_pic = cues_table.all_cues_pics{strcmp(cues_table.all_cues,[outcome '.png'])};
            %Screen('PutImage',p.ptb.window, pair_pic);
            Screen('PutImage',p.ptb.window, left_stim_pic, left_rect);
            Screen('PutImage',p.ptb.window, right_stim_pic, right_rect);
            Screen('TextSize', p.ptb.window, 48);
            DrawFormattedText(p.ptb.window, 'OR', 'center', 'center',p.ptb.white);
            Screen('TextSize', p.ptb.window, 24);
            DrawFormattedText(p.ptb.window, '50% chance', xcenter-stimW-distcent/2, ycenter-stimH/2,p.ptb.white);
            DrawFormattedText(p.ptb.window, '50% chance', xcenter+stimW-distcent/2, ycenter-stimH/2,p.ptb.white);
            %Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
            %    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
            pair_onset = Screen('Flip',p.ptb.window);
            if use_biopac
                curr_stim_pair = {part3_data_table.left_option{trial_table_ind}, part3_data_table.right_option{trial_table_ind}};
                if ismember('low_pain', curr_stim_pair)
                    biopac_signal(biopac_signal_out.pair_start_med_low);
                elseif ismember('high_pain', curr_stim_pair)
                    biopac_signal(biopac_signal_out.pair_start_med_high);
                elseif ismember('gain', curr_stim_pair)
                    biopac_signal(biopac_signal_out.pair_start_med_gain);
                elseif ismember('lose', curr_stim_pair)
                    biopac_signal(biopac_signal_out.pair_start_med_loss);
                end
            end
            part3_data_table.pair_onset(trial_table_ind) = pair_onset - task_onset;
            WaitSecs(part3_data_table.pair_duration(trial_table_ind));
            
            %% display "lottery"
            lottery_onset = GetSecs;
            if use_biopac
                biopac_signal(biopac_signal_out.lottery_start);
            end
            part3_data_table.lottery_onset(trial_table_ind) = lottery_onset - task_onset;
            
            if strcmp(outcome, left_stim)
                % last arrow should point to the left = arrow10
                last_arrow = 10;
                % outcome rect is left rect
                outcome_rect = left_rect;
            else
                % last arrow should pont to the right = arrow04
                last_arrow = 4;
                % outcome rect is right rect
                outcome_rect = right_rect;
            end
            
            arrow_num = 0;
            while GetSecs < lottery_onset + lottery_duration || arrow_num ~= last_arrow
                if arrow_num == 12
                    arrow_num = 1;
                else
                    arrow_num =  arrow_num + 1;
                end
                Screen('PutImage',p.ptb.window, all_arrows_pics{arrow_num});
                Screen('PutImage',p.ptb.window, left_stim_pic, left_rect);
                Screen('PutImage',p.ptb.window, right_stim_pic, right_rect);
                Screen('TextSize', p.ptb.window, 24);
                DrawFormattedText(p.ptb.window, '50% chance', xcenter-stimW-distcent/2, ycenter-stimH/2,p.ptb.white);
                DrawFormattedText(p.ptb.window, '50% chance', xcenter+stimW-distcent/2, ycenter-stimH/2,p.ptb.white);
                Screen('Flip',p.ptb.window);
                WaitSecs(0.02);
            end
            
            %% display outcome
            Screen('PutImage',p.ptb.window, all_arrows_pics{last_arrow});
            Screen('PutImage',p.ptb.window, left_stim_pic, left_rect);
            Screen('PutImage',p.ptb.window, right_stim_pic, right_rect);
            Screen('TextSize', p.ptb.window, 24);
            DrawFormattedText(p.ptb.window, '50% chance', xcenter-stimW-distcent/2, ycenter-stimH/2,p.ptb.white);
            DrawFormattedText(p.ptb.window, '50% chance', xcenter+stimW-distcent/2, ycenter-stimH/2,p.ptb.white);
            Screen('FrameRect', p.ptb.window, [0 255 0], outcome_rect, 3);
            outcome_onset = Screen('Flip',p.ptb.window);
            
            if use_biopac
                switch part3_data_table.outcome{trial_table_ind}
                    case 'med_pain'
                        biopac_signal(biopac_signal_out.outcome_start_med);
                    case 'low_pain'
                        biopac_signal(biopac_signal_out.outcome_start_low);
                    case 'high_pain'
                        biopac_signal(biopac_signal_out.outcome_start_high);
                    case 'gain'
                        biopac_signal(biopac_signal_out.outcome_start_gain);
                    case 'lose'
                        biopac_signal(biopac_signal_out.outcome_start_loss);
                end
            end
            part3_data_table.outcome_onset(trial_table_ind) = outcome_onset - task_onset;
            WaitSecs(part3_data_table.outcome_duration(trial_table_ind));

            %% jittered post-outcome fixation cross
            Screen('TextSize', p.ptb.window, 72);
            DrawFormattedText(p.ptb.window, '+', 'center', 'center',p.ptb.white);
            post_outcome_fixation_onset = Screen('Flip', p.ptb.window);
            if use_biopac
                biopac_signal(biopac_signal_out.post_outcome_fixation_start);
            end
            part3_data_table.post_outcome_fixation_onset(trial_table_ind) = post_outcome_fixation_onset - task_onset;
            WaitSecs(post_outcome_durations(trial_table_ind));
            
            %% Affect rating
            if use_biopac
                biopac_signal(biopac_signal_out.affect_rating);
            end
            rating_type = 'affect';
            [affect_rating, trajectory, rating_onset, response_onset] = semi_circular_rating(rating_type, main_dir, p, rating_duration);
            part3_data_table.affect_rating(trial_table_ind) = affect_rating;
            part3_data_table.affect_rating_onset(trial_table_ind) = rating_onset-task_onset;
            %task1_data_table.pain_expect_duration(trial_table_ind) = RT;
            part3_data_table.affect_rating_trajectory{trial_table_ind} = trajectory;
            part3_data_table.affect_rating_response_onset(trial_table_ind) = response_onset-task_onset;
            
        end
        %% "Get ready!"
        Screen('TextSize', p.ptb.window, 48);
        %start.texture = Screen('MakeTexture',p.ptb.window, imread(get_ready));
        %Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
        DrawFormattedText(p.ptb.window, 'Get ready!', 'center', 'center',p.ptb.white);
        get_ready_onset = Screen('Flip',p.ptb.window);
        if use_biopac
            biopac_signal(biopac_signal_out.get_ready);
        end
        part3_data_table.get_ready_onset(trial_table_ind) = get_ready_onset - task_onset;
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
        part3_data_table.pre_stim_fixation_onset(trial_table_ind) = pre_stim_fixation_onset - task_onset;
        WaitSecs(pre_stim_durations(trial_table_ind));
        
        if pain_trial
            %% pain delivery
            % the thermode function triggers the thermodes and waits for the
            % duration of the stimulus (including ramp up and down)
            if use_biopac
                biopac_signal(biopac_signal_out.stimulus_temps_signals(biopac_signal_out.potential_temps == part3_data_table.heat_temp(trial_table_ind)));
            end
            [heat_onset, responseStr_trigger] = thermode_trigger(thermode_program, total_stim_duration); % delivers the heat stimuli
            part3_data_table.heat_onset(trial_table_ind) = heat_onset - task_onset;
            part3_data_table.medocResponseStr_trigger(trial_table_ind) = responseStr_trigger;
            
            %% post-stim jittered fixation
            %Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
            %    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
            Screen('TextSize', p.ptb.window, 72);
            DrawFormattedText(p.ptb.window, '+', 'center', 'center',p.ptb.white);
            post_stim_fixation_onset = Screen('Flip', p.ptb.window);
            if use_biopac
                biopac_signal(biopac_signal_out.poststim_fixation_start);
            end
            part3_data_table.post_stim_fixation_onset(trial_table_ind) = post_stim_fixation_onset - task_onset;
            WaitSecs(post_stim_fixation_durations(trial_table_ind));
            
            %% pain ratings
            if use_biopac
                biopac_signal(biopac_signal_out.pain_rating_start);
            end
            rating_type = 'pain';
            [pain_rating, trajectory, rating_onset, response_onset] = semi_circular_rating(rating_type, main_dir, p, rating_duration);
            part3_data_table.pain_rating(trial_table_ind) = pain_rating;
            part3_data_table.pain_rating_onset(trial_table_ind) = rating_onset-task_onset;
            part3_data_table.pain_rating_trajectory{trial_table_ind} = trajectory;
            part3_data_table.pain_rating_response_onset(trial_table_ind) = response_onset-task_onset;
            
        else
            % monetary outcome
            % show monetary outcome
            start.texture = Screen('MakeTexture',p.ptb.window, outcome_pic);
            Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
            money_outcome_onset = Screen('Flip', p.ptb.window);
            if use_biopac
                switch part3_data_table.outcome{trial_table_ind}
                    case 'gain'
                        biopac_signal(biopac_signal_out.gain_outcome_start);
                    case 'lose'
                        biopac_signal(biopac_signal_out.loss_outcome_start);
                end
            end
            part3_data_table.monetary_outcome_onset(trial_table_ind) = money_outcome_onset - task_onset;
            WaitSecs(money_outcome_duration);
        end
        
        %% ISI jittered fixation
        %Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        %    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
        Screen('TextSize', p.ptb.window, 72);
        DrawFormattedText(p.ptb.window, '+', 'center', 'center',p.ptb.white);
        ISI_fixation_onset = Screen('Flip', p.ptb.window);
        if use_biopac
            biopac_signal(biopac_signal_out.isi_fixation_start);
        end
        part3_data_table.ISI_fixation_onset(trial_table_ind) = ISI_fixation_onset - task_onset;
        WaitSecs(part3_data_table.ISI_fixation_duration(trial_table_ind));
        
        %% trial offset
        trial_offset = GetSecs;
        if use_biopac
            biopac_signal(biopac_signal_out.trial_end);
        end
        part3_data_table.trial_offset(trial_table_ind) = trial_offset - task_onset;
        
        %% save trial info
        writetable(part3_data_table, data_filename);
        
    end % end trial loop
    
    % Play a sound for post-hoc syncronization with the facial and thermal recordings ("GoPro hilight")
    sound(gopro_hilight, Fs_gopro_hilight);
    end_sound_onset = GetSecs;
    part3_data_table.end_sound_onset(trial_table_ind) = end_sound_onset - task_onset;
    WaitSecs(2);
    % stop gopro recording with voice command ("GoPro stop recording")
    sound(gopro_stop, Fs_gopro_stop);
    
    %% signal Biopac that the block ended
    if use_biopac
        biopac_signal(biopac_signal_out.block_end);
    end
    
end % end block loop

if use_biopac
    biopac_signal(biopac_signal_out.task_end);
end

%% save final table (also as a .mat file)
writetable(part3_data_table, data_filename);
save([data_filename(1:end-4) '_' timestamp], 'part3_data_table');

%% ------------------------------------------------------------------------------
%                             Run post-session task
%________________________________________________________________________________
% show instructions
start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_post_session));
Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
Screen('Flip',p.ptb.window);

% Wait for participant's confirmation to Begin
WaitKeyPress(p.keys.start);

% here we want to ask the participant which alternaive they prefer in each pair
% define a table with al possible pairs
main_stim = 'med_pain.png';
alternative = cues_table.all_cues(~strcmp(cues_table.all_cues, main_stim));
post_session_table = table(alternative);
post_session_table.main_stim(:) = {main_stim};
post_session_table.main_stim_left = randi([0 1], height(post_session_table),1);
post_session_table.participant_choice(:) = {''};
post_session_table.pair_onset(:) = 0;
post_session_table.RT(:) = 0;
% randomize rials order
post_session_table = post_session_table(randperm(height(post_session_table)), :);

%% run over all pairs and save participants' choices + RT
penWidth = 10;
for trial_ind = 1:height(post_session_table)
    % prepare pair
    if post_session_table.main_stim_left(trial_ind)
        left_stim = post_session_table.main_stim(trial_ind);
        right_stim = post_session_table.alternative(trial_ind);
    else
        right_stim = post_session_table.main_stim(trial_ind);
        left_stim = post_session_table.alternative(trial_ind);
    end
    left_stim_pic = cues_table.all_cues_pics{strcmp(cues_table.all_cues,left_stim)};
    right_stim_pic = cues_table.all_cues_pics{strcmp(cues_table.all_cues,right_stim)};
    
    %% prepare display
    Screen('PutImage',p.ptb.window, left_stim_pic, left_rect);
    Screen('PutImage',p.ptb.window, right_stim_pic, right_rect);
    Screen('TextSize', p.ptb.window, 48);
    DrawFormattedText(p.ptb.window, 'OR', 'center', 'center',p.ptb.white);
    DrawFormattedText(p.ptb.window, 'Which one do you prefer?\n\nPress ''q'' for the left option or ''p'' for the right option', 'center',ycenter - 2*stimH , p.ptb.white);
    Screen('TextSize', p.ptb.window, 36);
    right_msg = '-->p';
    left_msg = 'q<--';
    DrawFormattedText(p.ptb.window, left_msg, xcenter-stimW/2-distcent-length(left_msg),ycenter + stimH , p.ptb.white);
    DrawFormattedText(p.ptb.window, right_msg, xcenter+stimW/2+distcent-length(right_msg),ycenter + stimH , p.ptb.white);
    
    %% display pair
    pair_onset = Screen('Flip',p.ptb.window);
    post_session_table.pair_onset(trial_ind) = pair_onset - task_onset;
    % wait for participant to respond with 'q' for the left option and 'p'
    % for the right option
    [key_pressed, response_time] = WaitKeyPressMultiple([p.keys.left, p.keys.right]);
    %% record and display choice
    post_session_table.RT(trial_ind) = response_time;
    color_left = p.ptb.black;
    color_right = p.ptb.black;
    % display choice
    Screen('PutImage',p.ptb.window, left_stim_pic, left_rect);
    Screen('PutImage',p.ptb.window, right_stim_pic, right_rect);
    Screen('TextSize', p.ptb.window, 48);
    DrawFormattedText(p.ptb.window, 'OR', 'center', 'center',p.ptb.white);
    DrawFormattedText(p.ptb.window, 'Which one do you prefer?\n\nPress ''q'' for the left option or ''p'' for the right option', 'center',ycenter - 2*stimH , p.ptb.white);
    Screen('TextSize', p.ptb.window, 36);
    right_msg = '-->p';
    left_msg = 'q<--';
    DrawFormattedText(p.ptb.window, left_msg, xcenter-stimW/2-distcent-length(left_msg),ycenter + stimH , p.ptb.white);
    DrawFormattedText(p.ptb.window, right_msg, xcenter+stimW/2+distcent-length(right_msg),ycenter + stimH , p.ptb.white);
    if key_pressed == p.keys.left
        post_session_table.participant_choice{trial_ind} = 'left';
        color_left = [0 255 0];
    elseif key_pressed == p.keys.right
        post_session_table.participant_choice{trial_ind} = 'right';
        color_right = [0 255 0];
    else
        warning('do not recognize pressed button');
    end
    Screen('FrameRect', p.ptb.window, color_left, left_rect, penWidth);
    Screen('FrameRect', p.ptb.window, color_right, right_rect, penWidth);
    Screen('Flip',p.ptb.window);
    WaitSecs(1);
    % show fixation for 1 sec between trials
    Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    Screen('Flip', p.ptb.window);
    WaitSecs(1);
    
end

%% save post_session_table (also as a .mat file)
post_session_table_filename = [data_filename(1:end-4) '_postsession_' timestamp '.csv'];
writetable(post_session_table, post_session_table_filename);
save(post_session_table_filename(1:end-4), 'post_session_table');

%% obtain WTP for the 3 types of pain
ListenChar(2);
pain_levels = {'low_pain','med_pain','high_pain'};
pain_levels = pain_levels(randperm(length(pain_levels)))';
wtp = zeros(length(pain_levels),1);
for pain_level_ind = 1:length(pain_levels)
    % show the pain cue and ask how much they are willing to pay
    pain_level = [pain_levels{pain_level_ind} '.png'];
    pain_pic = cues_table.all_cues_pics{strcmp(cues_table.all_cues,pain_level)};
    start.texture = Screen('MakeTexture',p.ptb.window, pain_pic);
    Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
    DrawFormattedText(p.ptb.window, 'How much money (in $) would you pay to avoid such a pain stimulus?\n\nPress ''s'' when ready to provide your answer.\n\nThen, in the next screen, please type your answer, and press enter when you are done.', 'center',ycenter - 2*stimH , p.ptb.white);
    Screen('Flip', p.ptb.window);
    WaitKeyPress(p.keys.start);
    worked = 0;
    while ~worked
        try
            clear KbCheck;
            wtp(pain_level_ind) = GetEchoNumber(p.ptb.window,'How much would you pay (in $)? (type number and then enter)',10,ycenter - 2*stimH, p.ptb.white, p.ptb.black);
            Screen('Flip', p.ptb.window);
            DrawFormattedText(p.ptb.window, ['Your answer was ' num2str(wtp(pain_level_ind)) '\n\n\nType ''y'' if correct, or ''n'' if not'], 'center', 'center',p.ptb.white);
            Screen('Flip', p.ptb.window);
            key_pressed = WaitKeyPressMultiple([p.keys.yes, p.keys.no]);
            if key_pressed == p.keys.yes
                worked = 1;
            else
                worked = 0;
            end
        catch
            DrawFormattedText(p.ptb.window, 'Something didn''t work properly.\n\n\nPlease try again.', 'center', 'center',p.ptb.white);
            Screen('Flip', p.ptb.window);
            WaitSecs(1);
            worked = 0;
        end
    end
    WaitSecs(0.25);
    Screen('Flip', p.ptb.window);
    DrawFormattedText(p.ptb.window, '+', 'center', 'center',p.ptb.white);
    Screen('Flip', p.ptb.window);
    WaitSecs(1);
end
wtp_table = table(pain_levels, wtp);
ListenChar(1);

%% save wtp_table (also as a .mat file)
wtp_table_filename = [data_filename(1:end-4) '_wtp_' timestamp '.csv'];
writetable(wtp_table, wtp_table_filename);
save(wtp_table_filename(1:end-4), 'wtp_table');

%% ------------------------------------------------------------------------------
%                                 Finish part3
%________________________________________________________________________________

%% show end of task msg, and display monetary outcome
final_outcome_session = part3_data_table.cum_monetary_outcome(end);
if final_outcome_session < 0
    final_outcome_prompt = ['In the current session, you lost $' num2str(abs(final_outcome_session))];
elseif final_outcome_session == 0
    final_outcome_prompt = 'In the current session, you didn''t lose/win money';
elseif final_outcome_session > 0
    final_outcome_prompt = ['In the current session, you won $' num2str(abs(final_outcome_session))];
end
Screen('TextSize', p.ptb.window, 36);
full_end_prompt = [final_outcome_prompt '\n\n\n\nThis is the end of this task.\n\nPlease wait for the experimenter.'];
DrawFormattedText(p.ptb.window, full_end_prompt, 'center', 'center', p.ptb.white);
Screen('TextSize', p.ptb.window, 24);
DrawFormattedText(p.ptb.window, 'experimenter: press ''e'' to end', 'center', ycenter+p.ptb.screenYpixels/3, p.ptb.white);
%start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_task_end));
%Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
Screen('Flip',p.ptb.window);

%% wait for experimenter to end the task
WaitKeyPress(p.keys.end);
Screen('Flip',p.ptb.window);

%% print the outcome msg to command window for experimenter
disp(final_outcome_prompt);

%% end part3
cleanup;

end % end main function
