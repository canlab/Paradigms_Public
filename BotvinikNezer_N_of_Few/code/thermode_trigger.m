function [heat_onset, responseStr_organized] = thermode_trigger(thermode_program, total_stim_duration)
% This function triggers the thermodes based on the program, and then
% waits for the stimulus duration interval, defined by the
% total_stim_duration input (in secs).
% the thermode_program is a number 0-255 that represent the 8bit set on
% Medoc software. It is chosen based on the function
% thermode_choose_program.m
% code by Rotem Botvinik-Nezer
% Last updated January 2021

ip = '192.168.0.114';
port = 20121;

responseStr = main(ip, port, 4, thermode_program); % trigger
responseStr_organized = [responseStr{1} ', ' responseStr{2} ', ' responseStr{3} ', ' responseStr{4} ', ' responseStr{5} ', ' responseStr{6} ', ' responseStr{7}];
heat_onset = GetSecs; % record stimulus onset
WaitSecs(ceil(total_stim_duration)); % wait for the stimulus duration (ceiled just in case)
end

