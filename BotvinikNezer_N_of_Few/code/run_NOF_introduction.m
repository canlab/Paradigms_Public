function participant_parameters = run_NOF_introduction(running_mode)
% Intro - familiarization and calibration
%
% code by Rotem Botvinik-Nezer
% based on codes by Heejung Jung and Xiaochun Han
% Last updated January 2021
%
% This function runs the familiarization and calibration part of NOF
% In this part, participants experience a series of heat stimuli in order
% to get used to the stimuli and the scale, and also to make sure they can
% tolerate the experiment. After the series of stimuli, they are asked
% whether they can tolerate these stimuli, and the temps for the rest of
% the experiment are adjusted accordingly (no change / up to -1 degree)
%
% Thermodes should be connected to skin site 1
% there's a screen at the beginning of the task, reminding the 
% experimenter what needs to be done.
% It then waits for the experimenter to indicate everything is ready,
% before starting the trials.
% Cameras and Biopac recordings are not needed in this part.
%
% Input:
% running_mode: should be 'debugging' for debugging mode (smaller screen,
% cursor is shown, less trials per block). Otherwise, leave empty.
%
% Output:
% participant_parameters: a structure with the parameters for the
% participants for the rest of the experiment. This structure is saved as a
% .mat file and is later updated and used throughout the experiment.
%
% Functions needed to run properly:
% semi_circular_rating.m
% exp_sample.m
% WaitKeyPress.m
% WaitKeyPressMultiple.m
% initialize_ptb_params.m
% trigger_thermode.m (and all its dependents)
% biopac_signal.m
% get_params_from_experimenter.m
% 
% Directories and files required to run properly:
% (sub folders in the main experiment folder)
% 'data/' for the output
% 'instructions/' with the pics of the instructions (start block, end block)
% 'scale/' with pics of the scales to be used for rating

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

%% --------------------------- Fixed parameters ---------------------------
experiment_name = 'NOF';
task_name = 'intro'; % used to correctly choose the thermode triggering program
main_dir = fileparts(pwd); % main dir is one dir up
output_dir = [main_dir filesep 'data'];
skin_site = 1;
num_blocks = 1;
trials_per_block = 7; % not including the dummy trial
heat_peak_duration = 7; % heat stimulus duration (at peak) in seconds
ramp_up_rate = 10; % ramp up rate in degrees per second (TSA2 max is 13)
ramp_down_rate = 13; % ramp up rate in degrees per second (TSA2 max is 13)
rating_duration = 'self_paced'; % duration in seconds or the string 'self_paced'
heat_temps = 43:49;

%% ------------------------------ time stamp ------------------------------
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];

%% --------------------- Parameters from experimenter ---------------------
[data_filename, session_num, use_biopac, ~, subject_str, subj_main_output_dir, ~] = get_params_from_experimenter(experiment_name,task_name,output_dir);
if session_num ~= 1
   error('The introduction task is only for session 1!'); 
end

%% ---------------------------- Site Parameters ---------------------------
% randomize sites for the entire experiment and save with the participant's parameters
% current version: 2 sites for dose response (used in all sessions), 4
% sites for cue=pain (sessions 1-6 3 for conditioning 1 for test; sessions
% 7-10 4 for test), and 2 sites for counterfactual (used in sessions 7-10)
num_sessions_all_exp = 10;
task_parameters = struct;
task_parameters.task_name = {'dose_response','cue_pain','counterfactual'};
task_parameters.sessions = {1:10, 1:10, 7:10};
task_parameters.sites_nums = {1:2, 3:6, 7:8};
for task_ind = 1:length(task_parameters.task_name)
    curr_task = task_parameters.task_name{task_ind};
    curr_task_sessions = task_parameters.sessions{task_ind};
    curr_task_num_sessions = length(curr_task_sessions);
    curr_task_sites_nums = task_parameters.sites_nums{task_ind};
    curr_task_all_unique_orders = perms(curr_task_sites_nums);
    if curr_task_num_sessions > size(curr_task_all_unique_orders,1)
        curr_task_all_orders = repmat(curr_task_all_unique_orders,[ceil(curr_task_num_sessions/size(curr_task_all_unique_orders,1)),1]);
    else
        curr_task_all_orders = curr_task_all_unique_orders;
    end
    curr_task_rand_orders = curr_task_all_orders(randperm(size(curr_task_all_orders,1)),:);
    while strcmp(curr_task, 'dose_response') && curr_task_rand_orders(1,1) ~= 1
        curr_task_rand_orders = curr_task_all_orders(randperm(size(curr_task_all_orders,1)),:);
    end
    curr_task_rand_orders = curr_task_rand_orders(1:curr_task_num_sessions,:);
    if strcmp(curr_task, 'cue_pain')
       % for the last 4 sessions, we only need 3 sites.
       % Make sure on each of them we exclude a different site.
       num_sessions_with_less_blocks = 4;
       num_sites_for_these_sessions = 3;
       seqs = nchoosek(curr_task_sites_nums, num_sites_for_these_sessions); % get all sequences
       seqs = seqs(randperm(size(seqs,1)),:); % randomly sort the order of sequences
       seqs = seqs(1:num_sessions_with_less_blocks, :); % take only the number of permutations that are needed
       for row_ind = 1:size(seqs,1)
          seqs(row_ind, :) = Shuffle(seqs(row_ind, :)); 
       end
       seqs = [seqs, zeros(num_sessions_with_less_blocks, length(curr_task_sites_nums)-num_sites_for_these_sessions)];
       curr_task_rand_orders(end-num_sessions_with_less_blocks+1:end,:) = seqs;
    end
    if strcmp(curr_task, 'counterfactual')
       % for the counterfactual task, add zeros for all previous sessions
       curr_task_rand_orders = [zeros(num_sessions_all_exp - curr_task_num_sessions,size(curr_task_rand_orders,2));curr_task_rand_orders];
    end
    participant_parameters.sites.(curr_task) = curr_task_rand_orders;
end
    
%% --------------------------- timing parameters --------------------------
% define durations of "get ready"
get_ready_duration = 1;

% define duration of pre stimulus fixation
pre_stim_duration_mean = 4; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
pre_stim_duration_min = 1; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
pre_stim_duration_max = 7; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
pre_stim_duration_interval = 0.5;  % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
pre_stim_durations = zeros(trials_per_block,num_blocks);
for ind = 1:trials_per_block*num_blocks
    pre_stim_durations(ind) = exp_sample(pre_stim_duration_mean,pre_stim_duration_min,pre_stim_duration_max,pre_stim_duration_interval);
end

% define durations of post-heat fixation
post_stim_fixation_duration_mean = 7; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
post_stim_fixation_duration_min = 3; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
post_stim_fixation_duration_max = 11; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
post_stim_fixation_duration_interval = 0.5;  % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
post_stim_fixation_durations = zeros(trials_per_block,num_blocks);
for ind = 1:trials_per_block*num_blocks
    post_stim_fixation_durations(ind) = exp_sample(post_stim_fixation_duration_mean,post_stim_fixation_duration_min,post_stim_fixation_duration_max,post_stim_fixation_duration_interval);
end

% define durations of ISI fixation
ISI_fixation_duration_mean = 3; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
ISI_fixation_duration_min = 1; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
ISI_fixation_duration_max = 5; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
ISI_fixation_duration_interval = 0.5;  % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
ISI_fixation_durations = zeros(trials_per_block,num_blocks);
for ind = 1:trials_per_block*num_blocks
    ISI_fixation_durations(ind) = exp_sample(ISI_fixation_duration_mean,ISI_fixation_duration_min,ISI_fixation_duration_max,ISI_fixation_duration_interval);
end
    
%% --------------------------- Heat parameters ----------------------------
% set temps random order. Make sure there's no strike of 3 successive
% stimuli with temp >=47, and the first temp <=45C
randomized_heat_temps = zeros(trials_per_block,num_blocks);
invalid_strike = 3;
strike_min_temp = 47;
max_first_temp = 45;
for block_num = 1:num_blocks
    valid_temps = 0;
    while valid_temps == 0
        block_heat_temps = heat_temps(randperm(length(heat_temps)));
        randomized_heat_temps(:,block_num) = block_heat_temps;
        if block_heat_temps(1) <= max_first_temp
            valid_temps = 1;
        else
            continue;
        end
        for ind = 1:(length(block_heat_temps) - invalid_strike + 1)
            if block_heat_temps(ind:ind+2) >= strike_min_temp
                valid_temps = 0;
                break
            end
        end
    end
end

%% -------------------------- Biopac Parameters ---------------------------
% biopac channel settings for relevant events
% the biopac_code_dict for the entire experiment can be found in an excel
% file under main_dir/code
biopac_signal_out = struct;
biopac_signal_out.baseline = 0;
biopac_signal_out.task_id = 1;
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

%% ------------------- initialize psychtoolbox parameters -----------------
p = initialize_ptb_params(debugging_mode);

%% ----------------------- Make output data table -------------------------                    
var_names = {'subject_id','session','task_onset','block',...
    'block_onset','site','trial','trial_onset',...
    'get_ready_onset','get_ready_duration','pre_stim_fixation_onset','pre_stim_fixation_duration',...
    'heat_onset','heat_temp','heat_peak_duration',...
    'heat_ramp_up_rate','heat_ramp_down_rate','total_stim_duration','program_num',...
    'medocResponseStr_choose_program', 'medocResponseStr_trigger',...
    'post_stim_fixation_onset','post_stim_fixation_duration',...
    'pain_rating_onset','pain_rating_response_onset','pain_rating', ...
    'ISI_fixation_onset','trial_offset','use_biopac',...
    'pain_rating_trajectory'};
var_types = {'string','double','double','double',...
    'double','double','double','double',...
    'double','double','double','double',...
    'double','double','double',...
    'double','double','double','double',...
    'string','string',...
    'double','double',...
    'double','double','double',...
    'double','double', 'logical',...
    'cell'};
intro_data_table = table('Size',[trials_per_block*num_blocks,length(var_names)],'VariableTypes',var_types,'VariableNames',var_names);
intro_data_table.subject_id(:) = subject_str;
intro_data_table.site(:) = skin_site;
intro_data_table.session(:) = session_num;
intro_data_table.block(:) = repelem(1:num_blocks,trials_per_block);
intro_data_table.trial(:) = repmat(1:trials_per_block,1,num_blocks);
intro_data_table.get_ready_duration(:) = get_ready_duration;
intro_data_table.pre_stim_fixation_duration(:) = pre_stim_durations(:);
intro_data_table.post_stim_fixation_duration(:) = post_stim_fixation_durations(:);
intro_data_table.heat_temp(:) = randomized_heat_temps(:);
intro_data_table.heat_peak_duration(:) = heat_peak_duration;
intro_data_table.heat_ramp_up_rate(:) = ramp_up_rate;
intro_data_table.heat_ramp_down_rate(:) = ramp_down_rate;
intro_data_table.use_biopac(:) = use_biopac;
writetable(intro_data_table, data_filename);

%% --------------------------- Load instructions -------------------------- 
instruct_filepath = [main_dir filesep 'instructions'];
instruct_task_start = fullfile(instruct_filepath, 'intro_start.png');
instruct_between_blocks = fullfile(instruct_filepath, 'between_blocks.png');
instruct_familiarization_end = fullfile(instruct_filepath, 'familiarization_end.png');
calibration_tolerate_question = fullfile(instruct_filepath, 'calibration_tolerate_question.png');
calibration_pre_stim = fullfile(instruct_filepath, 'calibration_pre_stim.png');
calibration_reach_lowest = fullfile(instruct_filepath, 'calibration_reach_lowest.png');
calibration_end = fullfile(instruct_filepath, 'calibration_end.png');

if ~debugging_mode
    HideCursor;
end

%% ------------------------------------------------------------------------------
%                             Run blocks & trials
%________________________________________________________________________________

% set the signal in the digital channels via parallel port
if use_biopac
    biopac_signal(biopac_signal_out.task_id);    
end

% start block loop
for block_num = 1:num_blocks

    %% Show the site number, and wait for the experimenter to indicate everything is ready (thermode and sensors are placed, data is recorded on Acknowledge and Medoc's system is waiting for external trigger)
    Screen('TextSize', p.ptb.window, 36);
    cur_site = skin_site;
    site_msg = ['Experimenter, please place the thermode on site ' num2str(cur_site) '.\n\nMake sure that:\n\n Medoc''s system is waiting for trigger\nNo need to record this part with cameras and Biopac\n\nPress ''s'' when ready to start.'];
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
       intro_data_table.task_onset(:) = 0; % task_onset is used as the anchor for all other timings
       if use_biopac
           biopac_signal(biopac_signal_out.task_start);
       end
    end
    Screen('Flip',p.ptb.window);
    
    % record block onset time
    block_onset = GetSecs;
    intro_data_table.block_onset(1+(trials_per_block*(block_num-1)):trials_per_block*(block_num)) = block_onset - task_onset;
    if use_biopac
        biopac_signal(biopac_signal_out.block_start);
    end
    
    %% ---------------------------- Trials loop ---------------------------
    % if debugging_mode, run just a few trials for each block
    if debugging_mode
     trials_per_block = 1; 
    end
    for trial_num = 1:trials_per_block
        trial_table_ind = trial_num + trials_per_block*(block_num-1);
        trial_onset = GetSecs;
        intro_data_table.trial_onset(trial_table_ind) = trial_onset - task_onset;
        if use_biopac
            biopac_signal(biopac_signal_out.trial_start);
        end
        
        %% choose a program for the thermode and start it (no trigger yet)
        [thermode_program, total_stim_duration, responseStr_choose_program] = thermode_choose_program(experiment_name, intro_data_table.heat_temp(trial_table_ind), intro_data_table.heat_peak_duration(trial_table_ind), intro_data_table.heat_ramp_up_rate(trial_table_ind), intro_data_table.heat_ramp_down_rate(trial_table_ind), main_dir);
        intro_data_table.program_num(trial_table_ind) = thermode_program;
        intro_data_table.total_stim_duration(trial_table_ind) = total_stim_duration;
        intro_data_table.medocResponseStr_choose_program(trial_table_ind) = responseStr_choose_program;

        %% "Get ready!"
        Screen('TextSize', p.ptb.window, 48);
        DrawFormattedText(p.ptb.window, 'Get ready!', 'center', 'center',p.ptb.white);
        %start.texture = Screen('MakeTexture',p.ptb.window, imread(get_ready));
        %Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
        get_ready_onset = Screen('Flip',p.ptb.window);
        if use_biopac
            biopac_signal(biopac_signal_out.get_ready);
        end
        intro_data_table.get_ready_onset(trial_table_ind) = get_ready_onset - task_onset;
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
        intro_data_table.pre_stim_fixation_onset(trial_table_ind) = pre_stim_fixation_onset - task_onset;
        WaitSecs(pre_stim_durations(trial_table_ind));
        
        %% pain delivery
        % the thermode function triggers the thermodes and waits for the
        % duration of the stimulus (including ramp up and down)
        if use_biopac
            biopac_signal(biopac_signal_out.stimulus_temps_signals(biopac_signal_out.potential_temps == intro_data_table.heat_temp(trial_table_ind)));
        end
        [heat_onset, responseStr_trigger] = thermode_trigger(thermode_program, total_stim_duration); % delivers the heat stimuli
        intro_data_table.heat_onset(trial_table_ind) = heat_onset - task_onset;
        intro_data_table.medocResponseStr_trigger(trial_table_ind) = responseStr_trigger;
        
        %% post-stim jittered fixation
        %Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        %    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
        Screen('TextSize', p.ptb.window, 72);
        DrawFormattedText(p.ptb.window, '+', 'center', 'center',p.ptb.white); 
        post_stim_fixation_onset = Screen('Flip', p.ptb.window);
        if use_biopac
            biopac_signal(biopac_signal_out.poststim_fixation_start);
        end
        intro_data_table.post_stim_fixation_onset(trial_table_ind) = post_stim_fixation_onset - task_onset;
        WaitSecs(post_stim_fixation_durations(trial_table_ind));
        
        %% pain ratings
        if use_biopac
            biopac_signal(biopac_signal_out.pain_rating_start);
        end
        rating_type = 'pain';
        [pain_rating, trajectory, rating_onset, response_onset] = semi_circular_rating(rating_type, main_dir, p, rating_duration);
        intro_data_table.pain_rating(trial_table_ind) = pain_rating;
        intro_data_table.pain_rating_onset(trial_table_ind) = rating_onset-task_onset;
        %task1_data_table.pain_rating_duration(trial_table_ind) = RT;
        intro_data_table.pain_rating_trajectory{trial_table_ind} = trajectory;
        intro_data_table.pain_rating_response_onset(trial_table_ind) = response_onset-task_onset;
        
        %% ISI jittered fixation
        %Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        %    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
        Screen('TextSize', p.ptb.window, 72);
        DrawFormattedText(p.ptb.window, '+', 'center', 'center',p.ptb.white); 
        ISI_fixation_onset = Screen('Flip', p.ptb.window);
        if use_biopac
            biopac_signal(biopac_signal_out.isi_fixation_start);
        end
        intro_data_table.ISI_fixation_onset(trial_table_ind) = ISI_fixation_onset - task_onset;
        WaitSecs(ISI_fixation_durations(trial_table_ind));
        while GetSecs - trial_onset < 30
            % each trial should be at least 30 secs to follow the lab's guidelines with heat stimuli
        end
        
        %% trial offset
        trial_offset = GetSecs;
        if use_biopac
            biopac_signal(biopac_signal_out.trial_end);
        end
        intro_data_table.trial_offset(trial_table_ind) = trial_offset - task_onset;
        
        %% save trial info
        writetable(intro_data_table, data_filename);
        
    end % end trial loop
       
    if use_biopac
        biopac_signal(biopac_signal_out.block_end);
    end
    
end % end block loop

if use_biopac
    biopac_signal(biopac_signal_out.task_end);
end
%% save final table (also as a .mat file)
writetable(intro_data_table, data_filename);
save([data_filename(1:end-4) '_' timestamp], 'intro_data_table');

%% show end of familiarization part
start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_familiarization_end));
Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
Screen('Flip',p.ptb.window);

%% wait for experimenter to press the key to proceed to calibration
WaitKeyPress(p.keys.end);

%%% CALIBRATION TASK %%%
calibration_factor = 0;
%continue_calibration = 1;
last_calib_temp = max(heat_temps);
next_calib_temp = last_calib_temp;
%while continue_calibration && calibration_factor >= -1
while calibration_factor >= -1
    %% Ask whether stimuli are tolerable
    start.texture = Screen('MakeTexture',p.ptb.window, imread(calibration_tolerate_question));
    Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
    Screen('Flip',p.ptb.window);
    
    %% Wait for participant to respond
    key_pressed = WaitKeyPressMultiple([p.keys.yes, p.keys.no]);
    if key_pressed == p.keys.yes
        calibration_factor = last_calib_temp - max(heat_temps);
        %continue_calibration = 0;
        break
    elseif key_pressed == p.keys.no && calibration_factor == -1
        %% show msg that we can't go lower, participant needs to decide whether to proceed with this intensity or quit the experiment
        start.texture = Screen('MakeTexture',p.ptb.window, imread(calibration_reach_lowest));
        Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
        Screen('Flip',p.ptb.window);
        WaitKeyPress(p.keys.continue);
        break
    elseif ~(calibration_factor==0 && next_calib_temp==last_calib_temp)
        calibration_factor = calibration_factor - 1;
    end
    
    %% Get ready for next stimulus
    start.texture = Screen('MakeTexture',p.ptb.window, imread(calibration_pre_stim));
    Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
    Screen('Flip',p.ptb.window);    
    
    %% wait for participant to press the key when they are ready
    WaitKeyPress(p.keys.start);
    
    %% "Get ready!"
    Screen('TextSize', p.ptb.window, 48);
    DrawFormattedText(p.ptb.window, 'Get ready!', 'center', 'center',p.ptb.white);
    Screen('Flip',p.ptb.window);
    WaitSecs(3);
    
    %% show fixation
    Screen('TextSize', p.ptb.window, 72);
    DrawFormattedText(p.ptb.window, '+', 'center', 'center',p.ptb.white);
    Screen('Flip', p.ptb.window);
    
    %% Choose program
    [thermode_program, total_stim_duration] = thermode_choose_program(experiment_name, next_calib_temp, heat_peak_duration, ramp_up_rate, ramp_down_rate, main_dir);
    WaitSecs(3);
    
    %% deliver heat stimulus
    thermode_trigger(thermode_program, total_stim_duration);
    
    %% update temps
    last_calib_temp = next_calib_temp;
    next_calib_temp = next_calib_temp - 1; % adjust the temp for next stim if needed
    
end

%% Record calibration factor
participant_parameters.calibration_factor = calibration_factor;

%% Save participant parameters file
filename = fullfile(subj_main_output_dir, [subject_str '_parameters.mat']);
save(filename, 'participant_parameters');

%% Show calibration end screen
start.texture = Screen('MakeTexture',p.ptb.window, imread(calibration_end));
Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
Screen('Flip',p.ptb.window);

%% wait for experimenter to press the key
WaitKeyPress(p.keys.end);

%% end intro
cleanup;

end % end main function

