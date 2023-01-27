function part2_recognition_data_table = run_cues_recognition(p,subject_num,session_num,debugging_mode,participant_parameters,cues_recognition_num)
% code by Rotem Botvinik-Nezer
% based on codes by Heejung Jung and Xiaochun Han
% Last updated December 2020
%
% This function runs the cues recognition task of the cue-pain conditioning part of the NOF experiment
% Cues are presented once each in a random order and the participant rate how hot
% they expect the stimulus following this cue to be.
% 
% There's no need to record thermal and facial expressions or to connect
% the thermodes and Biopac sensors for this task.
%
% Input:
% p: psychtoolbox parameters (struct)
% subject_num: the participant number (e.g. 101) (numeric)
% session_num: the number of the session (double)
% debugging_mode: whether to use debugging mode (smaller screen, cursor is
% shown, less trials per block) (logical)
% participant_parameters: the global participant parameters, including the
% allocation of cues for the specific participant (table) and the
% calibration factor.
% cues_recognition_num: the serial number of the cues recognition task in
% the current session, used in the output filename (double).
%
% Output:
% part2_recognition_data_table: the table with all the information about the task,
% including timing, parameters, ratings, trajectories, etc.
%
% Functions needed to run properly:
% semi_circular_rating.m
% exp_sample.m
% WaitKeyPress.m
% create_file_and_dir_names.m
%
% Directories and files required to run properly:
% (sub folders in the main experiment folder)
% 'data/' for the output
% 'instructions/' with the pics of the instructions (start task, end task etc.)
% 'scale/' with pics of the scales to be used for rating
% 'cues/' with pics of the cues (dog, cat, truck, car)

%% -----------------------------------------------------------------------------
%                           Parameters
% ______________________________________________________________________________

%% --------------------------- Fixed parameters ---------------------------
experiment_name = 'NOF';
main_dir = fileparts(pwd); % main dir is one dir up
output_dir = [main_dir filesep 'data'];
subject_id = [experiment_name '_' num2str(subject_num)];
task_name = ['recognition' num2str(cues_recognition_num)];
all_cues = {'dog','cat','truck','car','low','high','neutral'};
cues_types = cell(size(all_cues));
cues_types(end-2:end) = {'instruct_low','instruct_high','neutral'};
for cue_ind = 1:4
   cues_types(cue_ind) = participant_parameters.cues.Properties.VariableNames(strcmp(participant_parameters.cues{1,:}, all_cues{cue_ind}));
end
num_blocks = 1; % how many times to show each cue
num_trials_per_block = length(all_cues);
%cue_duration = 2; % presentation of the cue, in secs
rating_duration = 'self_paced'; % duration in seconds or the string 'self_paced'

%% ------------------------------ time stamp ------------------------------
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];

%% -----------------------------------------------------------------------------
%       Load and define required stimuli, cues, output files, etc.
% ______________________________________________________________________________

%% ------------------------------ output file -----------------------------
data_filename = create_file_and_dir_names(experiment_name,task_name,output_dir,subject_num,session_num);

%% ---------------------------- load cues pics ----------------------------
% cues_dir = [main_dir filesep 'cues'];
% pic_file_suffix = '.png';
% cues_pics = {imread([cues_dir filesep all_cues{1} pic_file_suffix])
%              imread([cues_dir filesep all_cues{2} pic_file_suffix])
%              imread([cues_dir filesep all_cues{3} pic_file_suffix])
%              imread([cues_dir filesep all_cues{4} pic_file_suffix])
%              imread([cues_dir filesep all_cues{5} pic_file_suffix])
%              imread([cues_dir filesep all_cues{6} pic_file_suffix])
%              imread([cues_dir filesep all_cues{7} pic_file_suffix])};

%% ---------------- set random order of cues ----------------
random_cues_order = zeros(num_trials_per_block,num_blocks);
for block_num = 1:num_blocks
    random_cues_order(:,block_num) = randperm(length(all_cues));
end

%% ----------------------- Make output data table -------------------------                    
var_names = {'subject_id','session','task_onset','cues_recognition_num',...
    'block','block_onset','trial','trial_onset',...
    'cue','cue_type',...
    'pain_expect_onset','pain_expect_response_onset','pain_expect',...
    'expect_confidence_onset','expect_confidence_response_onset','expect_confidence',...
    'trial_offset','pain_expect_trajectory','expect_confidence_trajectory'};
var_types = {'string','double','double','double',...
    'double','double','double','double',...
    'string','string',...
    'double','double','double',...
    'double','double','double',...
    'double','cell','cell'};
part2_recognition_data_table = table('Size',[num_trials_per_block*num_blocks,length(var_names)],'VariableTypes',var_types,'VariableNames',var_names);
part2_recognition_data_table.subject_id(:) = subject_id;
part2_recognition_data_table.session(:) = session_num;
part2_recognition_data_table.block(:) = repelem(1:num_blocks,num_trials_per_block);
part2_recognition_data_table.cues_recognition_num(:) = cues_recognition_num;
part2_recognition_data_table.trial(:) = repmat(1:num_trials_per_block,1,num_blocks);
%part2_recognition_data_table.cue_duration(:) = cue_duration;
part2_recognition_data_table.cue(:) = all_cues(random_cues_order(:));
part2_recognition_data_table.cue_type(:) = cues_types(random_cues_order(:));
writetable(part2_recognition_data_table, data_filename);

%% --------------------------- Load instructions -------------------------- 
instruct_filepath = [main_dir filesep 'instructions'];
instruct_task_start = fullfile(instruct_filepath, 'cue_pain_recognition_start.png');
instruct_between_blocks = fullfile(instruct_filepath, 'between_blocks.png');
instruct_task_end = fullfile(instruct_filepath, 'task_end.png');

%% ------------------------------------------------------------------------------
%                             Run blocks & trials
%________________________________________________________________________________

if ~debugging_mode
    HideCursor;
end

% start block loop  
for block_num = 1:num_blocks
    
    %% -------- Block start routine (instructions, response, sound) -------
    %Screen('TextSize',p.ptb.window,72);
    if block_num == 1
        %% Show instructions to experimenter, and wait for the experimenter to indicate everything is ready
        Screen('TextSize', p.ptb.window, 36);
        site_msg = 'Experimenter, no need to record with the cameras or\n\nto connect the thermode or biopac sensors for the current task.\n\nPress ''s'' when ready to start. Instructions will be shown.';
        DrawFormattedText(p.ptb.window, site_msg, 'center', 'center',p.ptb.white);
        Screen('Flip',p.ptb.window);
        WaitKeyPress(p.keys.start);
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
       part2_recognition_data_table.task_onset(:) = 0; % task_onset is used as the anchor for all other timings
    end
    Screen('Flip',p.ptb.window);
    
    % record block onset time
    block_onset = GetSecs;
    part2_recognition_data_table.block_onset(1+(num_trials_per_block*(block_num-1)):num_trials_per_block*(block_num)) = block_onset - task_onset;
    
    %% ---------------------------- Trials loop ---------------------------
    % if debugging_mode, run just a few trials for each block
    if debugging_mode
        num_trials_per_block = 2; 
    end
    for trial_num = 1:num_trials_per_block
        trial_table_ind = trial_num + num_trials_per_block*(block_num-1);
        trial_onset = GetSecs;
        part2_recognition_data_table.trial_onset(trial_table_ind) = trial_onset - task_onset;
        
%         %% cue
%         start.texture = Screen('MakeTexture',p.ptb.window, cues_pics{random_cues_order(trial_num,block_num)});
%         Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
%         cue_onset = Screen('Flip',p.ptb.window);
%         part2_recognition_data_table.cue_onset(trial_table_ind) = cue_onset - task_onset;
%         WaitSecs(cue_duration);
        
        %% Expectation rating (cue is presented next to scale question)
        rating_type = ['recognition_' all_cues{random_cues_order(trial_num,block_num)}];
        [pain_expect, trajectory, rating_onset, response_onset] = semi_circular_rating(rating_type, main_dir, p, rating_duration);
        part2_recognition_data_table.pain_expect(trial_table_ind) = pain_expect;
        part2_recognition_data_table.pain_expect_onset(trial_table_ind) = rating_onset-task_onset;
        part2_recognition_data_table.pain_expect_trajectory{trial_table_ind} = trajectory;
        part2_recognition_data_table.pain_expect_response_onset(trial_table_ind) = response_onset-task_onset;
        
        %% Confidence rating
        rating_type = 'confidence';
        [expect_confidence, trajectory, rating_onset, response_onset] = semi_circular_rating(rating_type, main_dir, p, rating_duration);
        part2_recognition_data_table.expect_confidence(trial_table_ind) = expect_confidence;
        part2_recognition_data_table.expect_confidence_onset(trial_table_ind) = rating_onset-task_onset;
        part2_recognition_data_table.expect_confidence_trajectory{trial_table_ind} = trajectory;
        part2_recognition_data_table.expect_confidence_response_onset(trial_table_ind) = response_onset-task_onset;

        %% trial offset
        trial_offset = GetSecs;
        part2_recognition_data_table.trial_offset(trial_table_ind) = trial_offset - task_onset;
        
        %% save trial info
        writetable(part2_recognition_data_table, data_filename);
        
    end % end trial loop
    
end % end block loop

%% save final table (also as a .mat file)
writetable(part2_recognition_data_table, data_filename);
save([data_filename(1:end-4) '_' timestamp], 'part2_recognition_data_table');

%% show end of task msg
start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_task_end));
Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
Screen('Flip',p.ptb.window);

%% wait for experimenter to end the task
WaitKeyPress(p.keys.end);
Screen('Flip',p.ptb.window);

end % end main function

