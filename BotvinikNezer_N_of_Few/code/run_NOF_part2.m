function output_tables = run_NOF_part2(running_mode)
% PART 2 - CUE-PAIN
%
% code by Rotem Botvinik-Nezer
% based on codes by Heejung Jung and Xiaochun Han
% Last updated January 2021
%
% This function runs the second part of the NOF experiment.
% Includes all or some of the following tasks:
% Symbolic learning: pairing cues with pics of thermometer with low/high
% temp.
% Conditioning: pairing cues with low/high heat stimuli.
% Test: testing the effect of the previously paired (or instructed) cues on
% pain expectation and perception, with the same heat temp.
% Cues recognition: rating expectation for each cue, with no heat delivery
% or thermometer pics.
%
% Input:
% running_mode: should be 'debugging' for debugging mode (smaller screen,
% cursor is shown, less trials). Otherwise, leave empty.
%
% Functions needed to run properly:
% semi_circular_rating.m
% exp_sample.m
% initialize_ptb_params.m
% WaitKeyPress.m
% run_cues_recognition.m
% run_symbolic_learning.m
% run_conditioning.m
% run_test.m
% biopac_signal.m
% thermode_choose_program.m, thermode_trigger.m and their dependencies
% get_params_from_experimenter.m
% 
% Directories and files required to run properly:
% (sub folders in the main experiment folder)
% 'data/' for the output
% 'instructions/' with the pics of the instructions
% 'audio_files/' with the audio files
% 'scale/' with pics of the scales to be used for rating
% 'cues/' with pics of the cues (dog, cat, truck, car)


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
main_dir = fileparts(pwd); % main dir is one dir up
output_dir = [main_dir filesep 'data'];
task_name = 'cuepain';

%% --------------------- Parameters from experimenter ---------------------
[data_filename, session_num, use_biopac, subject_num, subject_str, subj_main_output_dir, ~] = get_params_from_experimenter(experiment_name,task_name,output_dir);

%% ------------------- Load participant parameters file -------------------
parameters_filename = fullfile(subj_main_output_dir, [subject_str '_parameters.mat']);
load(parameters_filename, 'participant_parameters');
start_task_prompt = 'If you want to start running this part from a task which is not the first for this session,\nplease type the number of the task (based on the order for part2 for the current session.\nOTHERWISE (most of the times) TYPE 1 AND PRESS ENTER: ';
start_from_task = input(start_task_prompt);

%% ------------------- initialize psychtoolbox parameters -----------------
p = initialize_ptb_params(debugging_mode);

%% --------------- define order of tasks and cues allocation --------------
switch session_num
    case {1,3,5}
        if mod(subject_num,2) == 1
            session_type = 1;
        else
            session_type = 2;
        end
    case {2,4,6}
        if mod(subject_num,2) == 1
            session_type = 2;
        else
            session_type = 1;
        end
    case {7,8,9,10}
        session_type = 3;
end

switch session_type
    case 1
        tasks_order = {'cues_recognition','symbolic_learning','conditioning','test','cues_recognition'};
    case 2
        tasks_order = {'cues_recognition','conditioning','symbolic_learning','test','cues_recognition'};
    case 3
        tasks_order = {'cues_recognition', 'test', 'cues_recognition'};
end

if session_num == 1 % if 1st session, remove the first cue_recognition
    tasks_order = tasks_order(2:end);
end

% cues allocation based on subject num
sub2cues_allocation = [101:1004; repmat(1:8, [1,113])]';
cues_allocation_row = sub2cues_allocation(sub2cues_allocation(:,1)==subject_num,2);
load(fullfile(main_dir, 'cues', 'cues_allocation_alternatives.mat'), 'cues_allocation_alternatives');
cues = cues_allocation_alternatives(cues_allocation_row,:);

output_tables = cell(size(tasks_order));

%% save task order and cues allocation to file, and participant_parameter struct if first session
cues_cell = [cues.Properties.VariableNames; table2cell(cues)];
cues_cell = cues_cell(:)';
part2_table = table(string(subject_str), session_num, session_type, tasks_order, cues_allocation_row, cues_cell, use_biopac);
writetable(part2_table, data_filename);
if session_num == 1
    participant_parameters.cues = cues;
    save(parameters_filename, 'participant_parameters');
end

%% -------------------- sites order and number of blocks ------------------
sites_order = participant_parameters.sites.cue_pain(session_num,:);
conditioning_num_blocks = 3;
if session_num <= 6
    test_num_blocks = 1;
    test_sites_order = sites_order(end-test_num_blocks+1:end);
    conditioning_sites_order = sites_order(1:conditioning_num_blocks);
else
    test_num_blocks = 3;
    test_sites_order = sites_order(1:test_num_blocks);
end

symbolic_num_blocks = conditioning_num_blocks;

%% ------------------------------- run tasks ------------------------------
% for each task, pass p, biopac, debugging_mode, subject_id, session_num,
% main_dir, relevant cues
for task_ind = start_from_task:length(tasks_order)
   current_task = tasks_order{task_ind};
   switch current_task
       case 'cues_recognition'
           % is this the first or second cue recognition of the current
           % session?
           if task_ind == 1 || ~ismember('cues_recognition', tasks_order(1:task_ind-1))
               cues_recognition_num = 1;
           else
               cues_recognition_num = 2;
           end
           output_tables{task_ind} = run_cues_recognition(p,subject_num,session_num,debugging_mode,participant_parameters,cues_recognition_num);
       case 'symbolic_learning'
           symbolic_cues = {cues.symbolic_low{1}, cues.symbolic_high{1}};
           output_tables{task_ind} = run_symbolic_learning(p,subject_num,session_num,debugging_mode,symbolic_cues, symbolic_num_blocks);
       case 'conditioning'
           output_tables{task_ind} = run_conditioning(p,subject_num,session_num,use_biopac,debugging_mode,participant_parameters,conditioning_num_blocks,conditioning_sites_order);
       case 'test'
           output_tables{task_ind} = run_test(p,subject_num,session_num,use_biopac,debugging_mode,participant_parameters,test_num_blocks,test_sites_order);
   end
end

%% end part2
cleanup;

end % end main function