%% get directory where DICOMS are being written - if this changes the script wont work
selpath = uigetdir;
cfg.target.datafile='buffer://localhost:1972';
cfg.input = [selpath '\*.dcm'];
cfg.speedup=1; %dont write faster than necessary


%% run this on one instance of matlab to create buffer
% k = waitforbuttonpress;  %wait for scanner trigger

% if k==1
    close all;
    ft_realtime_dicomproxy(cfg);
% end