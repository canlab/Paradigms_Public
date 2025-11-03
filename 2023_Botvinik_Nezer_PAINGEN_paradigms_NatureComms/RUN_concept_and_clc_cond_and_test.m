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

% % familiarizing 
%  % familiarize control
%  fprintf('Farmiliarizing control site\n');
%  [ts, exp, post_q] = generate_ts_soc_cond_ctrl;
%   data = main(ts, 'explain_scale', {'overall_expect'; 'overall_int'});
%  
%  % familiarize prodicaine
 fprintf('Farmiliarizing prodicaine site\n');
 [ts, exp, post_q] = generate_ts_soc_cond_prodicaine;
 %data = main(ts, 'scriptdir', pwd);
 data = main(ts);
%   
%  % familiarize prodicaine
%  fprintf('Farmiliarizing prodicaine site\n');
%  [ts, exp, post_q] = generate_ts_soc_cond_prodicaine;
%  data = main(ts);
% %  
%  %familiarize control
%  fprintf('Farmiliarizing control site\n');
%  [ts, exp, post_q] = generate_ts_soc_cond_ctrl;
%  %data = main(ts, 'test', 'scriptdir', pwd);
%  data = main(ts);
% 
%  clc
%  
% %% familiarizing
% familiarize control
% fprintf('Farmiliarizing control site\n');
% [ts, exp, post_q] = generate_ts_pain_cond_ctrl;
% %data = main(ts, 'test', 'scriptdir', pwd);
% data = main(ts);
% % 
% % familiarize Prodicaine
% fprintf('Familiarizing prodicaine site\n');
% [ts, exp, post_q] = generate_ts_pain_cond_prodicaine;
% data = main(ts);
% 
% % familiarize Prodicaine
% fprintf('Familiarizing prodicaine site\n');
% [ts, exp, post_q] = generate_ts_pain_cond_prodicaine;
% data = main(ts);
% 
%  % familiarize control
% fprintf('Familiarizing control site\n');
% [ts, exp, post_q] = generate_ts_pain_cond_ctrl;
% data = main(ts);
% % 
%  %% test
%  % test control
% fprintf('Testing control site\n');
% [ts, exp, post_q] = generate_ts_pain_only_test;
% data = main(ts);
% % 
% % % test prodicaine
% fprintf('Testing prodicaine site\n');
% [ts, exp, post_q] = generate_ts_pain_only_test;
% data = main(ts);
% % 
% % % test prodicaine
% fprintf('Testing prodicaine site\n');
% [ts, exp, post_q] = generate_ts_pain_only_test;
% data = main(ts);
% % 
% % test control
% fprintf('Testing control site\n');
% [ts, exp, post_q] = generate_ts_pain_only_test;
% data = main(ts);

% fprintf('regulation task\n');
% [ts, exp, post_q] = generate_ts_pain_reg_task_temp;
% data = main(ts, 'biopac','fmri','regulate','female'); %male or female