
%% This script runs the MRI tasks for the chronic pain study. Just edit and run!
% 
% Please be sure to edit these values before running!

% Change to the participant's REDCap ID Number
SUBJECT = 9032;

% Which day of scans is it for this participant?
DAY = 1; 

% The default values for the bladder device are: [0.08 0.12 0.16 0.20]
PRESSURE = [0.08 0.12 0.16 0.20];

cd C:\Users\inc\Documents\CANlab\OLP4CBP\OLP4CBP\MATLAB

 %% Run Structural 
cd C:\Users\inc\Documents\CANlab\OLP4CBP\OLP4CBP\MATLAB\06_Structural
run_structural(SUBJECT, DAY)

%% Run Chronic Pain Task
cd C:\Users\inc\Documents\CANlab\OLP4CBP\OLP4CBP\MATLAB\04_BackPain
chronic_data = run_backpain_task_v2(SUBJECT, DAY, PRESSURE)

%% Run Resting State Task
cd C:\Users\inc\Documents\CANlab\OLP4CBP\OLP4CBP\MATLAB\01_RestingState
resting_data = run_restingstate(SUBJECT, DAY)

%% Run Acute Pain Task
cd C:\Users\inc\Documents\CANlab\OLP4CBP\OLP4CBP\MATLAB\02_AudioPressure
acute_data = run_autp_task(SUBJECT, DAY)
