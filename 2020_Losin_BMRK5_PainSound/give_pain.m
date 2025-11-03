clear all; close all;

addpath(genpath('support_files'));

[ignore, hn] = system('hostname'); hn=deblank(hn); 
addpath(genpath('\Program Files\MATLAB\R2012b\Toolbox\io32'));

% set up thermode
global THERMODE_PORT;
if strcmp(hn,'INC-DELL-001')
    config_io;
    THERMODE_PORT = hex2dec('D050'); % this was copied from an E-prime program that worked on
    trigger_heat = str2func('TriggerHeat2');
else
    THERMODE_PORT = digitalio('parallel','LPT1');
    addline(THERMODE_PORT,0:7,'out');
    trigger_heat = str2func('TriggerHeat');
end

for i=1:24
    fprintf('\nTrial %d\n',i)
    t=input('What now?  ');
    feval(trigger_heat,t);
end

a=input('bye!');