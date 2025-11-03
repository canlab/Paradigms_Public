clear all; close all;
addpath(genpath('support_files'));

subnum = input('Subject: ');
%subnum = sprintf('%03d',subnum);

load(['bmrk4_calib_log_sub' subnum])

% pain
r2.painoverall = regplot(log.data(log.data(:,1)==1, [6 3]),'pain');
r2.painhand = regplot(log.data(log.data(:,1)==1 & log.data(:,7)<=4, [6 3]),'pain hand');
r2.painfoot = regplot(log.data(log.data(:,1)==1 & log.data(:,7)>=5, [6 3]),'pain foot');

% taste
r2.taste = regplot(log.data(log.data(:,1)==2, [5 3]),'taste');

% vision
r2.visionoverall = regplot(log.data(log.data(:,1)==3, [5 3]), 'vision');
r2.visionhand = regplot(log.data(log.data(:,1)==3 & log.data(:,8)==1, [5 3]), 'vision hand');
r2.visionfoot = regplot(log.data(log.data(:,1)==3 & log.data(:,8)==2, [5 3]), 'vision foot');

r2
