function run_pre_experiment_test()
% Created by Rotem Botvinik-Nezer
% December 2020
%
% This function tests that the thermodes are triggered, the biopac
% signaling is working and the participant number is correct, before
% starting the experiment

% keyboard keys
start_button = KbName('s');

% check everything is connected and ready to go
disp('******** instructions *******');
disp('Please make sure you followed all the preparations steps prior to this on the experimental procedure doc (SOP)');
disp('Press ''s'' when ready to start the quick code testing');
disp('*****************************');
WaitKeyPress(start_button);

% fixed params
experiment_name = 'NOF';
task_name = 'PRE_EXP_CODE_TESTING';
main_dir = fileparts(pwd); % main dir is one dir up
output_dir = [main_dir filesep 'data'];

% make sure thermodes are triggered - choose program (need to happen a few
% seconds before triggering
disp('******** instructions *******');
fprintf('The code is now choosing a program for the thermodes.\nIt may fail if the TSA2 is not on,\nnot connected to the medoc computer,\nor the medoc software is not waiting for externa trigger\n');
disp('Press s to start the test');
disp('*****************************');
WaitKeyPress(start_button);
[thermode_program, overall_stim_duration, ~] = thermode_choose_program(experiment_name, 43, 7, 10, 13, main_dir);

% get params from experimenter
% and make sure participant number and session are correct, and there aren't
% files already
disp('******** instructions *******');
disp('Now, let''s make sure you''ve got a valid combination of participant numebr and session');
disp('*****************************');
[~, session_num, ~, subject_num] = get_params_from_experimenter(experiment_name,task_name,output_dir);
disp('******** instructions *******');
fprintf('If no warnings or errors were shown on the screen,\nthe participant number and session are valid\n(=don''t already exists in the the files)\n');
disp('Press s when ready to continue');
disp('*****************************');
WaitKeyPress(start_button);

% make sure thermodes are triggered
disp('******** instructions *******');
disp('Now, let''s test the thermode triggering.');
disp('Press s to start the triggering test');
disp('*****************************');
WaitKeyPress(start_button);
thermode_trigger(thermode_program, overall_stim_duration);

% make sure we can send signal to biopac
disp('******** instructions *******');
fprintf('Now, let''s test we can send signals to the digital channels of the biopac\n');
fprintf('Look at the Acknowledge window on the experimenter computer\nto make sure the signal is recieved.\nYou should see all the digital channels changing signal to the max for 3 seconds and then back to 0\n');
disp('Press s to start the biopac test');
disp('*****************************');
WaitKeyPress(start_button);
biopac_signal(255);
WaitSecs(3);
biopac_signal(0);

% make sure the GoPro is responding to the voice commands and record as
% needed
% Load audio files
disp('******** instructions *******');
disp('Now, let''s test the GoPro''s voice commands');
[gopro_start, Fs_gopro_start] = audioread(fullfile(main_dir, 'audio_files', 'GoPro_start_recording.m4a'));
[gopro_stop, Fs_gopro_stop] = audioread(fullfile(main_dir, 'audio_files', 'GoPro_stop_recording.m4a'));
% start gopro recording with voice command ("GoPro start recording")
gopro_command_works = 0;
while ~gopro_command_works
    sound(gopro_start, Fs_gopro_start);
    GoPro = input('Make sure that the GoPro is recording now! If it does, press ''y'', if it doesn''t, press ''n'': ','s');
    disp('*****************************');
    switch GoPro
        case 'y'
            disp('Wait for the stop recording command');
            gopro_command_works = 1;
            WaitSecs(1);
        case 'n'
            disp('Please make sure that:');
            disp('(1) the GoPro is on and charged.');
            disp('(2) the memory card is in the camera and empty.');
            disp('(3) that voice commands are enabled (see SOP for instructions if needed).');
            disp('In addition please make sure the volume in the participant computer is set to 100 (the highest possible)');
            input('When ready to proceed, please press 1 ');  
            disp('*****************************');
    end
end
sound(gopro_stop, Fs_gopro_stop);
disp('******** instructions *******');
fprintf('Please make sure that the GoPro has stopped recording.\nIf there''s any issue, please run this code again to make sure everything is working properly\n');
disp('*****************************');

% test the screen
disp('******** instructions *******');
disp('Now let''s test that the screen is working');
disp('Press s to start the test');
WaitKeyPress(start_button);

try
    initialize_ptb_params;
    WaitSecs(2);
    sca;
    disp('Looks like it work!')
catch
   disp('Looks like it''s not working.');
   disp('Try to restart the computer');
   disp('Open SpeaceDesk in the computer in the control room');
   disp('And only then reopen matlab here and run this code again');
   disp('If it still does not work, close SpaceDesk and try again.');
end
disp('*****************************');

% end of testing
disp('******** instructions *******');
disp(['Pre-testing completed, for participant ' num2str(subject_num) ' session ' num2str(session_num)]);
disp('Thank you for testing!');
disp('*****************************');