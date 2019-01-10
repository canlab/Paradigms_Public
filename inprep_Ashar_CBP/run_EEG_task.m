
%% This script runs the MRI tasks for the chronic pain study. Just edit and run!
% 
% Please be sure to edit these values before running!

% Change to the participant's REDCap ID Number
SUBJECT = 1319;

% The default values for the bladder device are: [0.08 0.12 0.16 0.20]
% the 208 bladder regulator struggles with .08, so upping to .1
PRESSURE = [0.1 0.12 0.16 0.20];

cd C:\OLP4CBP\MATLAB\07_BackPain_EEG
Screen('Preference', 'SkipSyncTests', 1);
% Run Chronic Pain Task
chronic_data = run_backpain_task_EEG(SUBJECT, 1, PRESSURE)

%%

cd C:\OLP4CBP\MATLAB\08_ToneTracking_EEG
%%
% 
%   
% 

% ideally, look into why this is required and what implications are
Screen('Preference', 'SkipSyncTests', 1);

tone_data = run_tone_tracking_task_EEG(SUBJECT, 1);
