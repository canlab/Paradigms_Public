function [data_filename, subj_main_output_dir, subject_str, session_str] = create_file_and_dir_names(experiment_name,task_name,output_dir,subject_num,session_num)
% Created by Rotem Botvinik-Nezer
% December 2020
subject_str = ['sub-' experiment_name sprintf('%03d', subject_num)];
session_str =  strcat('ses-',  sprintf('%02d', session_num));
    bids_string = [subject_str '_' session_str, strcat('_task-', task_name)];
    subj_main_output_dir = fullfile(output_dir, subject_str);
    subj_beh_output_dir = fullfile(subj_main_output_dir, session_str, 'beh');
    if ~exist(subj_beh_output_dir, 'dir')
        mkdir(subj_beh_output_dir);
    end
    data_filename = fullfile(subj_beh_output_dir, bids_string);
    previous_files = dir([data_filename '*']);
    if ~isempty(previous_files)
        warning(['=========There is/are already ' num2str(length(previous_files)) ' file(s) for this task!=========']);
        data_filename = [data_filename '_' num2str(length(previous_files)+1)]; % new filename to avoid over-writing the previous files
    end
data_filename = [data_filename '.csv'];
end