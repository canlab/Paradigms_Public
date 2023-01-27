function [thermode_program_num, total_stim_duration, responseStr_organized] = thermode_choose_program(experiment_name, peak_temp, peak_duration, ramp_up_rate, ramp_down_rate, main_dir)
% This function chooses the program based on parameters
% it outputs the program number, and starts the program on Medoc (no
% trigerring yet, as long as the program is set to "manual for trigger")
% code by Rotem Botvinik-Nezer
% Last updated January 2021
%
% This function reads the file
% "N_of_few_pain/files/thermode_programs_table.csv"
% to get the numbers for all relevant programs.
% If a change in the programs is needed, make sure to update them on
% Medoc's software, and also in that table, for this code to read it.
%
% Input:
% experiment_name - a string (e.g, 'NOF');
% peak_temp - numeric value, in celsius (e.g. 43.5)
% peak_duration- numeric value, in seconds (e.g. 7)
% ramp_up_rate- numeric value, degrees per second (e.g. 10)
% ramp_down_raye- numeric value, degrees per second (e.g. 13- 13 is the max
% rate for tsa2)
% main_dir - a string, the path for the main directory of the experiment
% (in which the subdirectory 'files' can be found)
%
% Output:
% thermode_progra_num- a numeric value, the number of the program on
% Medoc's external control (8 bit, so 0-255)
% total_stim_duration- a numeric value, in seconds. The total duration of
% the stimulus, including ramp up and ramp down duration.
% responseStr_organized: the response string from the TSA2, after adding tabs between each part (string)

addpath(genpath('triggering_thermodes'))

ip = '192.168.0.114';
port = 20121;

baseline_temp = 32;

% program name
program_name = [experiment_name '_' num2str(peak_temp) 'c_' num2str(peak_duration) 's_' num2str(ramp_up_rate) 'up_' num2str(ramp_down_rate) 'down'];

% define program number (8 bit)
thermode_programs_table_path = [main_dir filesep 'files'];
thermode_programs_table_filename = [thermode_programs_table_path filesep 'thermode_programs_table.csv'];
thermode_programs_table = readtable(thermode_programs_table_filename);

thermode_program_num = thermode_programs_table.program_num(strcmp(thermode_programs_table.program_name, program_name));

if isempty(thermode_program_num)
    error(['can''t trigger thermode, invalid program name: ' program_name]);
end

responseStr = main(ip, port, 1, thermode_program_num); % choose program to start
responseStr_organized = [responseStr{1} ', ' responseStr{2} ', ' responseStr{3} ', ' responseStr{4} ', ' responseStr{5} ', ' responseStr{6} ', ' responseStr{7}];
temp_diff = peak_temp - baseline_temp;
ramp_up_duration = temp_diff / ramp_up_rate;
ramp_down_duration = temp_diff / ramp_down_rate;
total_stim_duration = peak_duration+ramp_up_duration+ramp_down_duration;
end

