function [data_filename, session_num, use_biopac, subject_num, subject_str, subj_main_output_dir, session_str] = get_params_from_experimenter(experiment_name,task_name,output_dir)
% Created by Rotem Botvinik-Nezer
% December 2020
%% --------------------- Parameters from experimenter ---------------------
prompt = {'Participant''s number: ', 'Session: ', 'Use biopac (1 or 0): '};
get_params = 1;
while get_params
    subject_num = input(prompt{1}); % experimenter inputs subject_num 101,102,103...
    session_num = input(prompt{2}); % experimenter inputs session num
    use_biopac = input(prompt{3});
    [data_filename, subj_main_output_dir, subject_str, session_str] = create_file_and_dir_names(experiment_name,task_name,output_dir,subject_num,session_num);
    fprintf(['Participant: ', num2str(subject_num), '\nSession: ', num2str(session_num), '\nUse biopac: ', num2str(use_biopac) '\n']);
    get_params = input('Do you want to change parameters? choose 1 (yes, change) or 0 (no, proceed with current parameters): ');
end
end % end function

