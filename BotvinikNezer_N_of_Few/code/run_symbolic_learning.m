function part2_symbolic_data_table = run_symbolic_learning(p,subject_num,session_num,debugging_mode,symbolic_cues,num_blocks)
% code by Rotem Botvinik-Nezer
% based on codes by Heejung Jung and Xiaochun Han
% Last updated January 2021
%
% This function runs the symbolic learning task of the cue-pain part of the NOF experiment
% with expectation ratings and pictures of thermometers.
% All cues are presented in a random order. Participants rate
% expectations+confidence and then see a picture of a thermometer
% representing the temperature- low after low cue (thermometers 1-3) and
% high after high cue (thermometers 3-5).

% Three blocks per session, each block with 6 trials (3 for each cue, 1 for
% each cue+temp combination)
%
% There's no need to record thermal and facial expressions or to connect
% the thermodes and Biopac sensors for this task.
% Instructions for the experimenter are presented at the beginning.
% It then waits for the experimenter to indicate everything is ready,
% before starting the trials

% Code ends after all blocks are completed (based on num_blocks). Since
% there's no heat delivery in this task, thermode doesn't have to be
% connected, and starting the next block doesn't require the experimenter.
%
% Each trial includes the following parts:
% Cue, expectation and confidence ratings, thermometer picture, ISI fixation.
%
% Input:
% p: psychtoolbox parameters (struct)
% subject_num: the participant number (e.g. 101) (numeric)
% session_num: the number of the session (double)
% debugging_mode: whether to use debugging mode (smaller screen, cursor is
% shown, less trials per block) (logical)
% symbolic_cues: the two symbolic cues, the first string is the low cue and the second string is the high cue (cell)
% symbolic_num_blocks: the number of blocks to run
%
% Output:
% part2_symbolic_data_table: the table with all the information about the task,
% including timing, parameters, ratings, trajectories, etc.
%
% Functions needed to run properly:
% semi_circular_rating.m
% exp_sample.m
% WaitKeyPress.m
% biopac_signal.m
% create_file_and_dir_names.m
%
% Directories and files required to run properly:
% (sub folders in the main experiment folder)
% 'data/' for the output
% 'instructions/' with the pics of the instructions (start task, end task etc.)
% 'audio_files/' with the audio files
% 'scale/' with pics of the scales to be used for rating
% 'cues/' with pics of the cues (dog, cat, truck, car, H, L, neutral) and
% pics of the thermometers

%% -----------------------------------------------------------------------------
%                           Parameters
% ______________________________________________________________________________

%% --------------------------- Fixed parameters ---------------------------
experiment_name = 'NOF';
main_dir = fileparts(pwd); % main dir is one dir up
output_dir = [main_dir filesep 'data'];
subject_id = [experiment_name '_' num2str(subject_num)];
task_name = 'symbolic';
use_biopac = 0;
cues_types = {'low','high'};
num_thermometers = 5;
low_thermometers = 1:3;
high_thermometers = 3:5;
num_trials_per_cue = 3;
num_trials_per_cue_temp = num_trials_per_cue / length(low_thermometers);
total_trials_per_block = num_trials_per_cue * length(symbolic_cues); % not including the dummy trial
if mod(num_trials_per_cue,1) ~= 0 || mod(num_trials_per_cue_temp,1) ~= 0 || mod(total_trials_per_block,1) ~= 0
   warning('Please check the settings of the number and type of trials, at least one number is not round');
end
cue_duration = 2; % presentation of the cue, in secs
thermometer_duration = 3; % presentation of the thermometer, in secs
rating_duration = 'self_paced'; % duration in seconds or the string 'self_paced'

%% --------------------------- timing parameters --------------------------
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
biopac_signal_out.task_id = 3;
biopac_signal_out.task_start = 7;
biopac_signal_out.task_end = 8;
biopac_signal_out.block_start = 9;
biopac_signal_out.block_end = 10;
biopac_signal_out.block_middle = 11;
biopac_signal_out.trial_start = 12;
biopac_signal_out.trial_end = 13;
biopac_signal_out.cue_symbolic_low_start = 16;
biopac_signal_out.cue_symbolic_high_start = 17;
biopac_signal_out.expectation_rating = 21;
biopac_signal_out.confidence_rating = 22;
biopac_signal_out.isi_fixation_start = 39;
biopac_signal_out.thermometer1_pic_start = 40;
biopac_signal_out.thermometer2_pic_start = 41;
biopac_signal_out.thermometer3_pic_start = 42;
biopac_signal_out.thermometer4_pic_start = 43;
biopac_signal_out.thermometer5_pic_start = 44;

%% -----------------------------------------------------------------------------
%       Load and define required stimuli, cues, output files, etc.
% ______________________________________________________________________________

%% ------------------------------ output file -----------------------------
data_filename = create_file_and_dir_names(experiment_name,task_name,output_dir,subject_num,session_num);

%% ---------------------------- load cues pics ----------------------------
cues_dir = [main_dir filesep 'cues'];
low_cue = imread([cues_dir filesep symbolic_cues{1} '.png']);
high_cue = imread([cues_dir filesep symbolic_cues{2} '.png']);

%% ---------------------------- load thermometer pics ----------------------------
thermometer_pics = cell(num_thermometers,1);
for thermometer_ind = 1:num_thermometers
    thermometer_pics{thermometer_ind} = imread([cues_dir filesep 'thermometer' num2str(thermometer_ind) '.png']);
end

%% ---------------- choose (pseudo) random order of trials ----------------
% first, randomize cues order within each block
% row = trial, column - block
cues_order = zeros(total_trials_per_block, num_blocks);
all_cues_per_block = repelem(1:length(symbolic_cues), num_trials_per_cue);
% don't allow the same cue to repeat on more than X (defined below) consecutive trials
% within each block
for block_ind = 1:num_blocks
    max_strike_valid = 2;
    valid_order = 0;
    while ~valid_order
        cues_order(:,block_ind) = all_cues_per_block(randperm(length(all_cues_per_block)));
        valid_order = 1;
        for row_ind = 1:size(cues_order,1)-max_strike_valid
            if unique(cues_order(row_ind:row_ind+max_strike_valid, block_ind)) == 1
                valid_order = 0;
            end
        end
        
    end
end
% now, randomize thermometers within blocks (based on thermometers distributions for each cue).
thermometers_order = zeros(size(cues_order));
for block_ind = 1:num_blocks
    thermometers_order(cues_order(:,block_ind) == 1,block_ind) = low_thermometers(randperm(length(low_thermometers))); % randomize low thermometers order
    thermometers_order(cues_order(:,block_ind) == 2,block_ind) = high_thermometers(randperm(length(high_thermometers))); % randomize high thermometers order
end

%% ----------------------- Make output data table -------------------------                    
var_names = {'subject_id','session','task_onset','block',...
    'block_onset','trial','trial_onset',...
    'cue','cue_type','cue_onset','cue_duration',...
    'heat_expect_onset','heat_expect_response_onset','heat_expect',...
    'expect_confidence_onset','expect_confidence_response_onset','expect_confidence',...
    'thermometer_onset','thermometer_temp','thermometer_duration',...
    'ISI_fixation_onset','trial_offset','use_biopac',...
    'heat_expect_trajectory','expect_confidence_trajectory'};
var_types = {'string','double','double','double',...
    'double','double','double',...
    'string','string','double','double',...
    'double','double','double',...
    'double','double','double',... 
    'double','double','double',...
    'double','double', 'logical',...
    'cell','cell'};
part2_symbolic_data_table = table('Size',[total_trials_per_block*num_blocks,length(var_names)],'VariableTypes',var_types,'VariableNames',var_names);
part2_symbolic_data_table.subject_id(:) = subject_id;
part2_symbolic_data_table.session(:) = session_num;
part2_symbolic_data_table.block(:) = repelem(1:num_blocks,total_trials_per_block);
part2_symbolic_data_table.trial(:) = repmat(1:total_trials_per_block,1,num_blocks);
part2_symbolic_data_table.thermometer_temp(:) = thermometers_order(:);
part2_symbolic_data_table.thermometer_duration(:) = thermometer_duration;
part2_symbolic_data_table.cue_duration(:) = cue_duration;
part2_symbolic_data_table.cue(:) = symbolic_cues(cues_order(:));
part2_symbolic_data_table.cue_type(:) = cues_types(cues_order(:));
part2_symbolic_data_table.use_biopac(:) = use_biopac;
writetable(part2_symbolic_data_table, data_filename);

%% --------------------------- Load instructions -------------------------- 
instruct_filepath = [main_dir filesep 'instructions'];
instruct_task_start = fullfile(instruct_filepath, 'cue_pain_symbolic_start.png');
instruct_between_blocks = fullfile(instruct_filepath, 'between_blocks_symbolic.png');
instruct_task_end = fullfile(instruct_filepath, 'task_end.png');

%% ------------------------------------------------------------------------------
%                             Run blocks & trials
%________________________________________________________________________________

if ~debugging_mode
    HideCursor;
end

%% --------------------------- BIOPAC setup ---------------------------
% set the signal in the digital channels via parallel port
if use_biopac
    biopac_signal(biopac_signal_out.task_id);
end

% start block loop
for block_num = 1:num_blocks
    
    %% -------- Block start routine (instructions, response) -------
    %Screen('TextSize',p.ptb.window,72);
    if block_num == 1
        %% Show instructions to experimenter, and wait for the experimenter to indicate everything is ready
        Screen('TextSize', p.ptb.window, 36);
        site_msg = 'Experimenter, no need to record with the cameras or\n\nto connect the thermode or biopac sensors for the current task.\n\nPress ''s'' when ready to start. Instructions will be shown.';
        DrawFormattedText(p.ptb.window, site_msg, 'center', 'center',p.ptb.white);
        Screen('Flip',p.ptb.window);
        WaitKeyPress(p.keys.start);
        % participant's instructions
        start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_task_start));
    else
        start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_between_blocks));
    end
    Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
    Screen('Flip',p.ptb.window);
    
    % Wait for participant's confirmation to begin
    WaitKeyPress(p.keys.start);
    if block_num == 1
        task_onset = GetSecs;
        part2_symbolic_data_table.task_onset(:) = 0; % task_onset is used as the anchor for all other timings
        if use_biopac
            biopac_signal(biopac_signal_out.task_start);
        end
    end
    Screen('Flip',p.ptb.window);

    % record block onset time
    block_onset = GetSecs;
    part2_symbolic_data_table.block_onset(1+(total_trials_per_block*(block_num-1)):total_trials_per_block*(block_num)) = block_onset - task_onset;
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
        trial_onset = GetSecs;
        part2_symbolic_data_table.trial_onset(trial_table_ind) = trial_onset - task_onset;
        if use_biopac
            biopac_signal(biopac_signal_out.trial_start);
        end
        
        %% cue
        cur_cue_type = part2_symbolic_data_table.cue_type(trial_table_ind);
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
                    biopac_signal(biopac_signal_out.cue_symbolic_low_start);
                case 'high'
                    biopac_signal(biopac_signal_out.cue_symbolic_high_start);
            end
        end
        part2_symbolic_data_table.cue_onset(trial_table_ind) = cue_onset - task_onset;
        WaitSecs(cue_duration);
        
        %% Expectation rating
        if use_biopac
            biopac_signal(biopac_signal_out.expectation_rating);
        end
        rating_type = 'expectation_temp';
        [heat_expect, trajectory, rating_onset, response_onset] = semi_circular_rating(rating_type, main_dir, p, rating_duration);
        part2_symbolic_data_table.heat_expect(trial_table_ind) = heat_expect;
        part2_symbolic_data_table.heat_expect_onset(trial_table_ind) = rating_onset-task_onset;
        %task1_data_table.heat_expect_duration(trial_table_ind) = RT;
        part2_symbolic_data_table.heat_expect_trajectory{trial_table_ind} = trajectory;
        part2_symbolic_data_table.heat_expect_response_onset(trial_table_ind) = response_onset-task_onset;
        
        %% Confidence rating
        if use_biopac
            biopac_signal(biopac_signal_out.confidence_rating);
        end
        rating_type = 'confidence';
        [expect_confidence, trajectory, rating_onset, response_onset] = semi_circular_rating(rating_type, main_dir, p, rating_duration);
        part2_symbolic_data_table.expect_confidence(trial_table_ind) = expect_confidence;
        part2_symbolic_data_table.expect_confidence_onset(trial_table_ind) = rating_onset-task_onset;
        %task1_data_table.expect_confidence_duration(trial_table_ind) = RT;
        part2_symbolic_data_table.expect_confidence_trajectory{trial_table_ind} = trajectory;
        part2_symbolic_data_table.expect_confidence_response_onset(trial_table_ind) = response_onset-task_onset;
        
        %% thermometer picture
        cur_thermometer = part2_symbolic_data_table.thermometer_temp(trial_table_ind);
        start.texture = Screen('MakeTexture',p.ptb.window, thermometer_pics{cur_thermometer});
        Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
        thermometer_onset = Screen('Flip',p.ptb.window);
        if use_biopac
            switch cur_thermometer
                case 1
                    biopac_signal(biopac_signal_out.thermometer1_pic_start);
                case 2
                    biopac_signal(biopac_signal_out.thermometer2_pic_start);
                case 3
                    biopac_signal(biopac_signal_out.thermometer3_pic_start);
                case 4
                    biopac_signal(biopac_signal_out.thermometer4_pic_start);
                case 5
                    biopac_signal(biopac_signal_out.thermometer5_pic_start);
            end
        end
        part2_symbolic_data_table.thermometer_onset(trial_table_ind) = thermometer_onset - task_onset;
        WaitSecs(thermometer_duration);

        %% ISI jittered fixation
        %Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        %    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
        Screen('TextSize', p.ptb.window, 72);
        DrawFormattedText(p.ptb.window, '+', 'center', 'center',p.ptb.white);
        ISI_fixation_onset = Screen('Flip', p.ptb.window);
        if use_biopac
            biopac_signal(biopac_signal_out.isi_fixation_start);
        end
        part2_symbolic_data_table.ISI_fixation_onset(trial_table_ind) = ISI_fixation_onset - task_onset;
        WaitSecs(ISI_fixation_durations(trial_table_ind));
        
        %% trial offset
        trial_offset = GetSecs;
        if use_biopac
            biopac_signal(biopac_signal_out.trial_end);
        end
        part2_symbolic_data_table.trial_offset(trial_table_ind) = trial_offset - task_onset;
        
        %% save trial info
        writetable(part2_symbolic_data_table, data_filename);
        
    end % end trial loop
          
    %% signal Biopac that the block ended
    if use_biopac
        biopac_signal(biopac_signal_out.block_end);
    end
    
end % end block loop

%% save final table (also as a .mat file)
if use_biopac
    biopac_signal(biopac_signal_out.task_end);
end
writetable(part2_symbolic_data_table, data_filename);
save([data_filename(1:end-4) '_' timestamp], 'part2_symbolic_data_table');

%% show end of task msg
start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_task_end));
Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
Screen('Flip',p.ptb.window);

%% wait for experimenter to end the task
WaitKeyPress(p.keys.end);
Screen('Flip',p.ptb.window);

end % end main function

