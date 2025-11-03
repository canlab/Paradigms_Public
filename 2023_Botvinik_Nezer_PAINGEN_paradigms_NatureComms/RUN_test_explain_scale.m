%% NEW START
restoredefaultpath

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

%% To test scripts - but leave commented out when running experiment
% data = main(ts, 'test', 'scriptdir', pwd);

%% Familiarizing conceptual
% familiarize control
 fprintf('Farmiliarizing control site\n');
 [ts, exp, post_q] = generate_ts_soc_cond_ctrl;
 data = main(ts, 'explain_scale', {'overall_expect'; 'overall_int'});
% 
