%% run this on another instance of matlab to project data
%C:\Users\CANLab\Desktop\
% 
% addpath(genpath('C:\Users\CANLab\Desktop\rtfMRI\code\fieldtrip-20170217'))
% addpath 'C:\Users\CANLab\Desktop\rtfMRI\code\fieldtrip-20170217\realtime\online_mri'
% addpath(genpath('C:\Users\CANLab\Desktop\rtfMRI\code\spm12'));
% cd 'C:\Users\CANLab\Desktop\rtfMRI\code\fieldtrip-20170217\fileio\private'
% addpath 'C:\Users\CANLab\Desktop\rtfMRI'
% cfg.target.datafile='buffer://localhost:1972';
% cfg.bufferdata='last';


addpath(genpath('C:\Users\CANLab\Google Drive\fMRI_NF_study\Paradigm\updated_code\code\fieldtrip-20170217'))
addpath 'C:\Users\CANLab\Google Drive\fMRI_NF_study\Paradigm\updated_code\code\fieldtrip-20170217\realtime\online_mri'
addpath(genpath('C:\Users\CANLab\Google Drive\fMRI_NF_study\Paradigm\updated_code\code\spm12'));
cd 'C:\Users\CANLab\Google Drive\fMRI_NF_study\Paradigm\updated_code\code\fieldtrip-20170217\fileio\private'
addpath 'C:\Users\CANLab\Google Drive\fMRI_NF_study\Paradigm\rtfMRI'
addpath 'C:\Users\CANLab\Google Drive\fMRI_NF_study\Paradigm\updated_code'
addpath(genpath('C:\Users\CANLab\Google Drive\fMRI_NF_study\Paradigm\updated_code\MATLAB_LJUDDotNET'))

cfg.target.datafile='buffer://localhost:1972';
cfg.bufferdata='last';
cfg.correctSliceTime=false;