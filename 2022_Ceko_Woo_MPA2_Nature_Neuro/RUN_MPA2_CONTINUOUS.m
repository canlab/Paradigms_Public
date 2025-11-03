%% NEW START
clear all;
ts = generate_ts_mpa2_continuous;
data = mpa2_main(ts, 'explain_scale', {'cont_avoidance_exp'});

%% START after an error

% % load subject's data from "task_functions_v4/MPA1_data"
% data = mpa1_main(trial_sequence, 'fmri', 'biopac');

