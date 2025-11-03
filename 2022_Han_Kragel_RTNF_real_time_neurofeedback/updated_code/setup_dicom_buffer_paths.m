%C:\Users\CANLab\Desktop\ 
%C:\Users\CANLab\Desktop\

% addpath(genpath('C:\Users\CANLab\Desktop\rtfMRI\code\fieldtrip-20170217'))
% addpath(genpath('C:\Users\CANLab\Desktop\rtfMRI\code\spm12'))
% addpath 'C:\Users\CANLab\Desktop\rtfMRI' %needs to be near top
% cd('C:\Users\CANLab\Desktop\rtfMRI\code\fieldtrip-20170217\fileio\private') %need files in this folder specifically - cannot add because it is private
% spm_jobman('initcfg');
% 

% addpath(genpath('C:\Users\CANLab\Desktop\rtfMRI\code\fieldtrip-20170217'))
% addpath(genpath('C:\Users\CANLab\Desktop\rtfMRI\code\spm12'))
addpath(genpath('C:\Users\CANLab\Google Drive\fMRI_NF_study\Paradigm\updated_code\code\spm12'))
addpath 'C:\Users\CANLab\Google Drive\fMRI_NF_study\Paradigm\rtFMRI' %needs to be near top
addpath 'C:\Users\CANLab\Google Drive\fMRI_NF_study\Paradigm\updated_code'
% cd('C:\Users\CANLab\Desktop\rtfMRI\code\fieldtrip-20170217\fileio\private') %need files in this folder specifically - cannot add because it is private
spm_jobman('initcfg');
cd 'C:\Users\CANLab\Google Drive\fMRI_NF_study\Paradigm\updated_code\code\fieldtrip-20170217\fileio\private'


%delete old .nii/.mat files
delete('*.nii')
delete('*sn.mat')
