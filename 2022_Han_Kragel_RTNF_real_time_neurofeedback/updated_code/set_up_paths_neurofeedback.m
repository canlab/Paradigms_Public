%% run this on another instance of matlab to project data
%C:\Users\CANLab\Desktop\

% addpath(genpath('X:\\rtfMRI\code\fieldtrip-20170217'))
% addpath 'X:\\rtfMRI\code\fieldtrip-20170217\realtime\online_mri'
% addpath(genpath('X:\\rtfMRI\code\spm12'));
% cd 'X:\\rtfMRI\code\fieldtrip-20170217\fileio\private'
% addpath 'X:\\rtfMRI'
% cfg.target.datafile='buffer://localhost:1972';


addpath(genpath('D:\Google Drive\fMRI_NF_study\Paradigm\updated_code\code\fieldtrip-20170217'))
addpath 'D:\Google Drive\fMRI_NF_study\Paradigm\updated_code\code\fieldtrip-20170217\realtime\online_mri'
addpath(genpath('D:\Google Drive\fMRI_NF_study\Paradigm\updated_code\code\spm12'));
cd 'D:\Google Drive\fMRI_NF_study\Paradigm\updated_code\code\fieldtrip-20170217\fileio\private'
addpath 'D:\Google Drive\fMRI_NF_study\Paradigm\rtfMRI'
cfg.target.datafile='buffer://localhost:1972';
% cfg.target.datafile='buffer://128.138.225.152:1973';

cfg.bufferdata='last';
