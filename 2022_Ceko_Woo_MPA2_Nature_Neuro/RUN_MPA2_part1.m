%% NEW START

%% !!!EXPERIENCE!!!
clear all;
[ts, exp, post_q] = generate_ts_mpa2_part1;
data = mpa2_main(ts, 'fmri', 'biopac', 'explain_scale', {'overall_avoidance'}, 'postrun_questions', post_q);

% record eye
% data = mpa2_main(ts, 'fmri', 'biopac', 'eyelink', 'explain_scale', exp.instructions, 'postrun_questions', {'overall_boredness', 'overall_alertness'});

%% !!!REGULATION!!!
clear all;
[ts, exp, post_q] = generate_ts_mpa2_part1;
data = mpa2_main(ts, 'fmri', 'biopac', 'explain_scale', {'overall_avoidance'}, 'regulate', 'postrun_questions', post_q);

% record eye
% data = mpa2_main(ts, 'fmri', 'biopac', 'eyelink', 'explain_scale', exp.instructions, 'regulate', 'postrun_questions', {'overall_boredness', 'overall_alertness'});

%% !!! TEST !!!
% clear all;
% [ts, exp] = generate_ts_mpa2_part1;
% data = mpa2_main(ts, 'test', 'scriptdir', pwd);


%% START after an error

% % load subject's data from "task_functions_v4/MPA1_data"
% data = mpa1_main(trial_sequence, 'fmri', 'biopac');

