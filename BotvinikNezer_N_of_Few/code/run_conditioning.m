function part2_conditioning_data_table = run_conditioning(p,subject_num,session_num,use_biopac,debugging_mode,participant_parameters, num_blocks, sites_order)
% code by Rotem Botvinik-Nezer
% based on codes by Heejung Jung and Xiaochun Han
% Last updated January 2021
%
% This function runs the conditioning task of the cue-pain part of the NOF experiment
% with heat stimuli and pain and expectation ratings.
% All cues are presented in a random order. Participants rate expectations+confidence,
% then stimuli are delivered, low after low cues or high after high cues, and
% participants rate pain.
% 3 blocks per session (only sessions 1-6), each block with 6 trials (3 for each cue, 1 for
% each cue+temp combination) + one dummy trial at the beginning of the block.
%
% Before each block (including the first one), there is a screen with
% instructions to the experimenter with everything that needs to happen
% before starting the block (for example, the skin site to put the thermode
% on). It then waits for the experimenter to indicate everything is ready,
% before presenting the task instructions to the participant.
% Code ends after all blocks are completed (based on num_blocks)
% Each trial includes the following parts:
% Cue, expectation and confidence ratings, "Get ready!", pre-stim fixation, heat stim, post-stim fixation, pain rating,
% ISI fixation.
%
% Input:
% p: psychtoolbox parameters (struct)
% subject_num: the participant number (e.g. 101) (numeric)
% session_num: the number of the session (double)
% use_biopac: whether to use biopac or not (logical)
% debugging_mode: whether to use debugging mode (smaller screen, cursor is
% shown, less trials per block) (logical)
% participant_parameters: the global participant parameters, including the
% allocation of cues for the specific participant (table) and the
% calibration factor.
% num_blocks: the number of blocks to be used in the task (numeric)
% sites_order: the order of sites for this task, current session (numeric
% array)
% Output:
% part2_conditioning_data_table: the table with all the information about the task,
% including timing, parameters, ratings, trajectories, etc.
%
% Functions needed to run properly:
% semi_circular_rating.m
% exp_sample.m
% WaitKeyPress.m
% thermode_choose_program.m, thermode_trigger.m and their dependencies
% biopac_signal.m
% create_file_and_dir_names.m
%
% Directories and files required to run properly:
% (sub folders in the main experiment folder)
% 'data/' for the output
% 'instructions/' with the pics of the instructions (start task, end task etc.)
% 'audio_files/' with the audio files
% 'scale/' with pics of the scales to be used for rating
% 'cues/' with pics of the cues (dog, cat, truck, car, H, L, neutral)

%% -----------------------------------------------------------------------------
%                           Parameters
% ______________________________________________________________________________

%% --------------------------- Fixed parameters ---------------------------
experiment_name = 'NOF';
task_name = 'conditioning';
task_name_audio_file = 'cue_C';
main_dir = fileparts(pwd); % main dir is one dir up
output_dir = [main_dir filesep 'data'];
subject_id = [experiment_name '_' num2str(subject_num)];
conditioning_cues = {participant_parameters.cues.conditioning_low{1}, participant_parameters.cues.conditioning_high{1}};
all_cues_with_dummy = [conditioning_cues,{'dummy_no_cue'}];
cues_types = {'low','high','dummy_no_cue'};
low_heat_temps = (45:47) + participant_parameters.calibration_factor;
high_heat_temps = (47:49) + participant_parameters.calibration_factor;
num_trials_per_cue = 3;
num_trials_per_cue_temp = num_trials_per_cue / length(low_heat_temps);
exp_trials_per_block = num_trials_per_cue * length(conditioning_cues); % not including the dummy trial
if mod(num_trials_per_cue,1) ~= 0 || mod(num_trials_per_cue_temp,1) ~= 0 || mod(exp_trials_per_block,1) ~= 0
   error('Please check the settings of the number and type of trials, at least one number is not round (conditioning task)');
end
num_dummy_trials_per_block = 1;
dummy_cue_id = length(all_cues_with_dummy);
dummy_temp = 47 + participant_parameters.calibration_factor;
total_trials_per_block = num_dummy_trials_per_block + exp_trials_per_block;
heat_peak_duration = 5; % heat stimulus duration (at peak) in seconds
ramp_up_rate = 10; % ramp up rate in degrees per second (TSA2 max is 13)
ramp_down_rate = 13; % ramp up rate in degrees per second (TSA2 max is 13)
cue_duration = 2; % presentation of the cue, in secs
rating_duration = 'self_paced'; % duration in seconds or the string 'self_paced'

%% ---------------- choose (pseudo) random order of trials ----------------
% first, randomize cues order within each block
% row = trial, column - block
cues_order = zeros(total_trials_per_block, num_blocks);
all_cues_per_block = repelem(1:length(conditioning_cues), num_trials_per_cue);
% don't allow the same cue to repeat on more than 2 consecutive trials
% within each block
for block_ind = 1:num_blocks
    max_strike_valid = 2;
    valid_order = 0;
    while ~valid_order
        cues_order(:,block_ind) = [dummy_cue_id, all_cues_per_block(randperm(length(all_cues_per_block)))];
        valid_order = 1;
        for row_ind = 1:size(cues_order,1)-max_strike_valid
            if unique(cues_order(row_ind:row_ind+max_strike_valid, block_ind)) == 1
                valid_order = 0;
            end
        end
        
    end
end
% now, randomize temps within blocks (based on temp distributions for each cue).
% Don't allow more than 3 consecutive trials with temp > = 47 (within the same block)
temps_order = zeros(size(cues_order));
temps_order(cues_order == dummy_cue_id) = dummy_temp;
for block_ind = 1:num_blocks
    max_strike_valid = 3;
    valid_order = 0;
    while ~ valid_order
        temps_order(cues_order(:,block_ind) == 1,block_ind) = low_heat_temps(randperm(length(low_heat_temps))); % randomize low temps order
        temps_order(cues_order(:,block_ind) == 2,block_ind) = high_heat_temps(randperm(length(high_heat_temps))); % randomize high temps order
        
        valid_order = 1;
        for trial_ind = 1:size(temps_order,1)-max_strike_valid
            if all(temps_order(trial_ind:trial_ind+max_strike_valid, block_ind) >= 47)
                valid_order = 0;
            end
        end
    end
end

%% --------------------------- timing parameters --------------------------
% define durations of "get ready"
get_ready_duration = 1;

% define durations of pre stimulus fixation
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

%% ------------------------------ time stamp ------------------------------
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];

%% -------------------------- Biopac Parameters ---------------------------
% biopac channel settings for relevant events
% the biopac_code_dict for the entire experiment can be found in an excel
% file under main_dir/code
biopac_signal_out = struct;
biopac_signal_out.baseline = 0;
biopac_signal_out.task_id = 4;
biopac_signal_out.task_start = 7;
biopac_signal_out.task_end = 8;
biopac_signal_out.block_start = 9;
biopac_signal_out.block_end = 10;
biopac_signal_out.block_middle = 11;
biopac_signal_out.trial_start = 12;
biopac_signal_out.trial_end = 13;
biopac_signal_out.cue_conditioning_low_start = 14;
biopac_signal_out.cue_conditioning_high_start = 15;
biopac_signal_out.expectation_rating = 21;
biopac_signal_out.confidence_rating = 22;
biopac_signal_out.get_ready = 23;
biopac_signal_out.prestim_fixation = 24;
biopac_signal_out.poststim_fixation_start = 37;
biopac_signal_out.pain_rating_start = 38;
biopac_signal_out.isi_fixation_start = 39;
biopac_signal_out.potential_temps = [40:50, 40.5:49.5]; % temps that are coded
biopac_signal_out.stimulus_temps_signals = [25:35,45:54]; % the associated codes

%% ------------------------------------------------------------------------
%       Load and define required stimuli, cues, output files, etc.
% _________________________________________________________________________

%% ------------------------------ output file -----------------------------
data_filename = create_file_and_dir_names(experiment_name,task_name,output_dir,subject_num,session_num);

%% ---------------------------- load cues pics ----------------------------
cues_dir = [main_dir filesep 'cues'];
low_cue = imread([cues_dir filesep conditioning_cues{1} '.png']);
high_cue = imread([cues_dir filesep conditioning_cues{2} '.png']);

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

%% ----------------------- Make output data table -------------------------                    
var_names = {'subject_id','session','task_onset','block',...
    'block_onset','site','trial','trial_onset',...
    'start_sound_onset','middle_sound_onset','end_sound_onset'...
    'cue','cue_type','cue_onset','cue_duration',...
    'pain_expect_onset','pain_expect_response_onset','pain_expect',...
    'expect_confidence_onset','expect_confidence_response_onset','expect_confidence',...
    'get_ready_onset','get_ready_duration','pre_stim_fixation_onset','pre_stim_fixation_duration',...
    'heat_onset','heat_temp','heat_peak_duration','heat_ramp_up_rate','heat_ramp_down_rate',...
    'total_stim_duration','program_num','medocResponseStr_choose_program','medocResponseStr_trigger',...
    'post_stim_fixation_onset','post_stim_fixation_duration',...
    'pain_rating_onset','pain_rating_response_onset','pain_rating', ...
    'ISI_fixation_onset','trial_offset','use_biopac',...
    'pain_expect_trajectory','expect_confidence_trajectory','pain_rating_trajectory'};
var_types = {'string','double','double','double',...
    'double','double','double','double',...
    'double','double','double',...
    'string','string','double','double',...
    'double','double','double',...
    'double','double','double',...
    'double','double','double','double',...
    'double','double','double','double','double',...
    'double','double','string','string',...
    'double','double',...
    'double','double','double',...
    'double','double', 'logical',...
    'cell','cell','cell'};
part2_conditioning_data_table = table('Size',[total_trials_per_block*num_blocks,length(var_names)],'VariableTypes',var_types,'VariableNames',var_names);
part2_conditioning_data_table.subject_id(:) = subject_id;
part2_conditioning_data_table.session(:) = session_num;
part2_conditioning_data_table.block(:) = repelem(1:num_blocks,total_trials_per_block);
part2_conditioning_data_table.site(:) = repelem(sites_order,total_trials_per_block);
part2_conditioning_data_table.trial(:) = repmat(1:total_trials_per_block,1,num_blocks);
part2_conditioning_data_table.get_ready_duration(:) = get_ready_duration;
part2_conditioning_data_table.pre_stim_fixation_duration(:) = pre_stim_durations(:);
part2_conditioning_data_table.post_stim_fixation_duration(:) = post_stim_fixation_durations(:);
part2_conditioning_data_table.heat_temp(:) = temps_order(:);
part2_conditioning_data_table.heat_peak_duration(:) = heat_peak_duration;
part2_conditioning_data_table.heat_ramp_up_rate(:) = ramp_up_rate;
part2_conditioning_data_table.heat_ramp_down_rate(:) = ramp_down_rate;
part2_conditioning_data_table.cue_duration(:) = cue_duration;
part2_conditioning_data_table.cue(:) = all_cues_with_dummy(cues_order(:));
part2_conditioning_data_table.cue_type(:) = cues_types(cues_order(:));
part2_conditioning_data_table.use_biopac(:) = use_biopac;
writetable(part2_conditioning_data_table, data_filename);

%% --------------------------- Load instructions -------------------------- 
instruct_filepath = [main_dir filesep 'instructions'];
instruct_task_start = fullfile(instruct_filepath, 'cue_pain_conditioning_start.png');
instruct_between_blocks = fullfile(instruct_filepath, 'between_blocks.png');
instruct_task_end = fullfile(instruct_filepath, 'task_end.png');
%get_ready = fullfile(instruct_filepath, 'get_ready.png');


%% ------------------------------------------------------------------------------
%                             Run blocks & trials
%________________________________________________________________________________

if ~debugging_mode
    HideCursor;
end

% set the signal in the digital channels via parallel port
if use_biopac
    biopac_signal(biopac_signal_out.task_id);
end

% start block loop  
for block_num = 1:num_blocks
    
    %% Show the site number, and wait for the experimenter to indicate everything is ready (thermode and sensors are placed, data is recorded on Acknowledge and Medoc's system is waiting for external trigger)
    Screen('TextSize', p.ptb.window, 36);
    site_msg = ['Experimenter, please place the thermode on site ' num2str(sites_order(block_num)) '.\n\nMake sure that:\n\n(1) The Biopac sensors are placed and turned on\n(2) Acknowledge is recording data\n(3) Medoc''s system is waiting for trigger\n(4) The GoPro is open and charged\n(5) The thermal camera is recording and charged\n\nPress ''s'' when ready.'];
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
        part2_conditioning_data_table.task_onset(:) = 0; % task_onset is used as the anchor for all other timings
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
    part2_conditioning_data_table.start_sound_onset(1+total_trials_per_block*(block_num-1)) = start_sound_onset - task_onset;
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
    part2_conditioning_data_table.block_onset(1+(total_trials_per_block*(block_num-1)):total_trials_per_block*(block_num)) = block_onset - task_onset;
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
            part2_conditioning_data_table.middle_sound_onset(trial_table_ind) = GetSecs - task_onset;
            sound(gopro_hilight, Fs_gopro_hilight);
            if use_biopac
                biopac_signal(biopac_signal_out.block_middle);
            end
            WaitSecs(2);
        end
        trial_onset = GetSecs;
        part2_conditioning_data_table.trial_onset(trial_table_ind) = trial_onset - task_onset;
        if use_biopac
            biopac_signal(biopac_signal_out.trial_start);
        end
        
        %% choose a program for the thermode and start it (no trigger yet)
        [thermode_program, total_stim_duration, responseStr_choose_program] = thermode_choose_program(experiment_name, part2_conditioning_data_table.heat_temp(trial_table_ind), part2_conditioning_data_table.heat_peak_duration(trial_table_ind), part2_conditioning_data_table.heat_ramp_up_rate(trial_table_ind), part2_conditioning_data_table.heat_ramp_down_rate(trial_table_ind), main_dir);
        part2_conditioning_data_table.program_num(trial_table_ind) = thermode_program;
        part2_conditioning_data_table.total_stim_duration(trial_table_ind) = total_stim_duration;
        part2_conditioning_data_table.medocResponseStr_choose_program(trial_table_ind) = responseStr_choose_program;
        
        % show cue and expectation ratings only if not a dummy trial
        if trial_num > num_dummy_trials_per_block % show cue only if it's not a dummy trial
            %% cue
            cur_cue_type = part2_conditioning_data_table.cue_type(trial_table_ind);
            switch cur_cue_type
                case 'low'
                    start.texture = Screen('MakeTexture',p.ptb.window, low_cue);
                case 'high'
                    start.texture = Screen('MakeTexture',p.ptb.window, high_cue);
            end
            Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
            cue_onset = Screen('Flip',p.ptb.window);
            if use_biopac
                switch cur_cue_type
                    case 'low'
                        biopac_signal(biopac_signal_out.cue_conditioning_low_start);
                    case 'high'
                        biopac_signal(biopac_signal_out.cue_conditioning_high_start);
                end
            end
            part2_conditioning_data_table.cue_onset(trial_table_ind) = cue_onset - task_onset;
            WaitSecs(cue_duration);
            
            
            %% Expectation rating
            if use_biopac
                biopac_signal(biopac_signal_out.expectation_rating);
            end
            rating_type = 'expectation_pain';
            [pain_expect, trajectory, rating_onset, response_onset] = semi_circular_rating(rating_type, main_dir, p, rating_duration);
            part2_conditioning_data_table.pain_expect(trial_table_ind) = pain_expect;
            part2_conditioning_data_table.pain_expect_onset(trial_table_ind) = rating_onset-task_onset;
            %task1_data_table.pain_expect_duration(trial_table_ind) = RT;
            part2_conditioning_data_table.pain_expect_trajectory{trial_table_ind} = trajectory;
            part2_conditioning_data_table.pain_expect_response_onset(trial_table_ind) = response_onset-task_onset;
            
            %% Confidence rating
            if use_biopac
                biopac_signal(biopac_signal_out.confidence_rating);
            end
            rating_type = 'confidence';
            [expect_confidence, trajectory, rating_onset, response_onset] = semi_circular_rating(rating_type, main_dir, p, rating_duration);
            part2_conditioning_data_table.expect_confidence(trial_table_ind) = expect_confidence;
            part2_conditioning_data_table.expect_confidence_onset(trial_table_ind) = rating_onset-task_onset;
            %task1_data_table.expect_confidence_duration(trial_table_ind) = RT;
            part2_conditioning_data_table.expect_confidence_trajectory{trial_table_ind} = trajectory;
            part2_conditioning_data_table.expect_confidence_response_onset(trial_table_ind) = response_onset-task_onset;
            
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
        part2_conditioning_data_table.get_ready_onset(trial_table_ind) = get_ready_onset - task_onset;
        WaitSecs(get_ready_duration);
        
        %% jittered pre-stim fixation cross
        %Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        %   p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
        Screen('TextSize', p.ptb.window, 72);
        DrawFormattedText(p.ptb.window, '+', 'center', 'center',p.ptb.white);
        pre_stim_fixation_onset = Screen('Flip', p.ptb.window);
        if use_biopac
            biopac_signal(biopac_signal_out.prestim_fixation);
        end
        part2_conditioning_data_table.pre_stim_fixation_onset(trial_table_ind) = pre_stim_fixation_onset - task_onset;
        WaitSecs(pre_stim_durations(trial_table_ind));
        
        %% pain delivery
        % the thermode function triggers the thermodes and waits for the
        % duration of the stimulus (including ramp up and down)
        if use_biopac
            biopac_signal(biopac_signal_out.stimulus_temps_signals(biopac_signal_out.potential_temps == part2_conditioning_data_table.heat_temp(trial_table_ind)));
        end
        [heat_onset, responseStr_trigger] = thermode_trigger(thermode_program, total_stim_duration); % delivers the heat stimuli
        part2_conditioning_data_table.heat_onset(trial_table_ind) = heat_onset - task_onset;
        part2_conditioning_data_table.medocResponseStr_trigger(trial_table_ind) = responseStr_trigger;
        
        %% post-stim jittered fixation
        %Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        %    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
        Screen('TextSize', p.ptb.window, 72);
        DrawFormattedText(p.ptb.window, '+', 'center', 'center',p.ptb.white);
        post_stim_fixation_onset = Screen('Flip', p.ptb.window);
        if use_biopac
            biopac_signal(biopac_signal_out.poststim_fixation_start);
        end
        part2_conditioning_data_table.post_stim_fixation_onset(trial_table_ind) = post_stim_fixation_onset - task_onset;
        WaitSecs(post_stim_fixation_durations(trial_table_ind));
        
        %% pain ratings
        if use_biopac
            biopac_signal(biopac_signal_out.pain_rating_start);
        end
        rating_type = 'pain';
        [pain_rating, trajectory, rating_onset, response_onset] = semi_circular_rating(rating_type, main_dir, p, rating_duration);
        part2_conditioning_data_table.pain_rating(trial_table_ind) = pain_rating;
        part2_conditioning_data_table.pain_rating_onset(trial_table_ind) = rating_onset-task_onset;
        %task1_data_table.pain_rating_duration(trial_table_ind) = RT;
        part2_conditioning_data_table.pain_rating_trajectory{trial_table_ind} = trajectory;
        part2_conditioning_data_table.pain_rating_response_onset(trial_table_ind) = response_onset-task_onset;
        
        %% ISI jittered fixation
        %Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        %    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
        Screen('TextSize', p.ptb.window, 72);
        DrawFormattedText(p.ptb.window, '+', 'center', 'center',p.ptb.white);
        ISI_fixation_onset = Screen('Flip', p.ptb.window);
        if use_biopac
            biopac_signal(biopac_signal_out.isi_fixation_start);
        end
        part2_conditioning_data_table.ISI_fixation_onset(trial_table_ind) = ISI_fixation_onset - task_onset;
        WaitSecs(ISI_fixation_durations(trial_table_ind));
        
        %% trial offset
        trial_offset = GetSecs;
        if use_biopac
            biopac_signal(biopac_signal_out.trial_end);
        end
        part2_conditioning_data_table.trial_offset(trial_table_ind) = trial_offset - task_onset;
        
        %% save trial info
        writetable(part2_conditioning_data_table, data_filename);
        
    end % end trial loop
    
    % Play a sound for post-hoc syncronization with the facial and thermal recordings ("GoPro hilight")
    sound(gopro_hilight, Fs_gopro_hilight);
    end_sound_onset = GetSecs;
    part2_conditioning_data_table.end_sound_onset(trial_table_ind) = end_sound_onset - task_onset;
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
writetable(part2_conditioning_data_table, data_filename);
save([data_filename(1:end-4) '_' timestamp], 'part2_conditioning_data_table');

%% show end of task msg
start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_task_end));
Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
Screen('Flip',p.ptb.window);

%% wait for experimenter to end the task
WaitKeyPress(p.keys.end);
Screen('Flip',p.ptb.window);

end % end main function

