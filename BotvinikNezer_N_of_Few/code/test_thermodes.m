ip = '192.168.0.114';
port = 20121;
programs = 201:223;
num_reps = 10;
log_var_names = {'repetition', 'program_num','response_select','time_select','response_start', 'time_start'};
log_var_types = {'double', 'double', 'string', 'double', 'string', 'double'};
logs = table('size', [num_reps, length(log_var_names)],'VariableTypes',log_var_types,'VariableNames',log_var_names);
loop_onset = GetSecs;
for rep_ind = 1:num_reps
    logs.repetition(rep_ind) = rep_ind;
    disp(['----------- Rep ind: ' num2str(rep_ind) ' -----------']);
    program_num = programs(randi(length(programs)));
    logs.program_num(rep_ind) = program_num;
    disp(['----------- Program num: ' num2str(program_num) ' -----------']);
    % select program
    logs.time_select(rep_ind) = GetSecs - loop_onset;
    responseStr = main(ip, port, 1, program_num);
    logs.response_select(rep_ind) = [responseStr{1} ', ' responseStr{2} ', ' responseStr{3} ', ' responseStr{4} ', ' responseStr{5} ', ' responseStr{6} ', ' responseStr{7}];
    disp('----------- Selected program -----------');
    % wait
    WaitSecs(3);
    % start stim
    logs.time_start(rep_ind) = GetSecs - loop_onset;
    responseStr = main(ip, port, 4, program_num);
    logs.response_start(rep_ind) = [responseStr{1} ', ' responseStr{2} ', ' responseStr{3} ', ' responseStr{4} ', ' responseStr{5} ', ' responseStr{6} ', ' responseStr{7}];
    disp('----------- Started -----------');
    % wait
    WaitSecs(15);
end
disp('DONE!');
