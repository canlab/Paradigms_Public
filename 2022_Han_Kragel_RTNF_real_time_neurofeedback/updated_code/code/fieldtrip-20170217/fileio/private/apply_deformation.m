
%-----------------------------------------------------------------------
% Job saved on 19-Feb-2017 16:13:12 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
mats=dir('*sn.mat');
niis=dir('*.nii');
pattern_dir=pwd;
% pattern_dir='C:\Users\CANLab\Desktop\rtfMRI\code\fieldtrip-20170217\fileio\private\';
clear 'matlabbatch'

matlabbatch{1}.spm.util.defs.comp{1}.sn2def.matname = {[pattern_dir '\' mats(1).name]};
matlabbatch{1}.spm.util.defs.comp{1}.sn2def.vox = [NaN NaN NaN];
matlabbatch{1}.spm.util.defs.comp{1}.sn2def.bb = [NaN NaN NaN
                                                  NaN NaN NaN];
                                              
                                              if isempty(which('weights_NSF_grouppred_cvpcr.img'))
                                                 error('Please find file: weights_NSF_grouppred_cvpcr.img - check C:\Users\CANLab\Google Drive\fMRI_NF_study\Paradigm\updated_code\code\fieldtrip-20170217\fileio\private')  
                                              end
matlabbatch{1}.spm.util.defs.out{1}.push.fnames = {which('weights_NSF_grouppred_cvpcr.img')};
matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
matlabbatch{1}.spm.util.defs.out{1}.push.savedir.saveusr = {'C:\rtFMRI'}; %'C:\rtFMRI\'
matlabbatch{1}.spm.util.defs.out{1}.push.fov.file = {[pattern_dir '\' niis(1).name]};
matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 0;
matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [0 0 0];
matlabbatch{1}.spm.util.defs.out{1}.push.prefix = 'w';
spm_jobman('run',matlabbatch)
