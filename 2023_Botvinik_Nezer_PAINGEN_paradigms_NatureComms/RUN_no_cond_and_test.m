
%% NEW START
restoredefaultpath

%% !!!EXPERIENCE!!!
%clear all;

cwd = pwd;
cd([ pwd '\Psychtoolbox\']);
SetupPsychtoolbox
cd(cwd);
try %for windows
    addpath(genpath([ pwd '\library_dependencies']));
catch %for mac/linux (not tested)
    addpath(genpath([ pwd '/library_dependencies']));
end

%% familiarizing 
% familiarize control
% fprintf('Farmiliarizing control site\n');
% [ts, exp, post_q] = generate_ts_soc_cond_ctrl;
%  data = main(ts, 'explain_scale', {'overall_expect'; 'overall_int'}, 'biopac');
% %data = main(ts, 'biopac');
% 
% % familiarize lidocain
% fprintf('Farmiliarizing placebo site\n');
% [ts, exp, post_q] = generate_ts_soc_cond_lidocain;
% data = main(ts, 'biopac');
% 
% % familiarize lidocain
% fprintf('Farmiliarizing placebo site\n');
% [ts, exp, post_q] = generate_ts_soc_cond_lidocain;
% data = main(ts, 'biopac');
% 
% % familiarize control
% fprintf('Farmiliarizing control site\n');
% [ts, exp, post_q] = generate_ts_soc_cond_ctrl;
% data = main(ts, 'biopac');

%% test
% test control
fprintf('Testing control site\n');
[ts, exp, post_q] = generate_ts_pain_only_test;
data = main(ts, 'biopac');

% test lidocain
fprintf('Testing lidocain site\n');
[ts, exp, post_q] = generate_ts_pain_only_test;
data = main(ts, 'biopac');

% test lidocain
fprintf('Testing lidocain site\n');
[ts, exp, post_q] = generate_ts_pain_only_test;
data = main(ts, 'biopac');

% test control
fprintf('Testing control site\n');
[ts, exp, post_q] = generate_ts_pain_only_test;
data = main(ts, 'biopac');