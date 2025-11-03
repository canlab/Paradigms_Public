%% NEW START

%% !!!EXPERIENCE!!!
clear all;
[ts, post_q] = generate_ts_mpa2_part2_resting;
data = mpa2_main(ts, 'fmri', 'biopac', 'postrun_questions', post_q);

% record eye
% data = mpa2_main(ts, 'fmri', 'biopac', 'eyelink', 'postrun_questions', {'overall_resting*'});

%% !!!REGULATION!!!
clear all;
[ts, post_q] = generate_ts_mpa2_part2_resting;
data = mpa2_main(ts, 'fmri', 'biopac', 'regulate', 'postrun_questions', post_q);

% record eye
% data = mpa2_main(ts, 'fmri', 'biopac', 'eyelink', 'regulate', 'postrun_questions', {'overall_resting*'});

%% TESTING
% clear all;
% ts = generate_ts_mpa2_part2;
% ts{1} = ts{1}(1:2);
% ts{1}{2}{3} = '0001';
% data = mpa2_main(ts, 'test', 'postrun_questions', {'overall_resting*'}, 'scriptdir', pwd);


%% START after an error

% % load subject's data from "task_functions_v4/MPA1_data"
% data = mpa1_main(trial_sequence, 'fmri', 'biopac');

