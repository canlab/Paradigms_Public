
%-----------------------------------------------------------------------
% Job saved on 19-Feb-2017 16:13:12 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
mats=dir('*sn.mat');
niis=dir('*.nii');
% pattern_dir='C:\Users\CANLab\Desktop\rtfMRI\code\fieldtrip-20170217\fileio\private\';
pattern_dir=pwd;

matlabbatch{1}.spm.util.defs.comp{1}.sn2def.matname = {[pattern_dir '\' mats.name]};
matlabbatch{1}.spm.util.defs.comp{1}.sn2def.vox = [NaN NaN NaN];
matlabbatch{1}.spm.util.defs.comp{1}.sn2def.bb = [NaN NaN NaN
                                                  NaN NaN NaN];
matlabbatch{1}.spm.util.defs.out{1}.push.fnames = {which('weights_NSF_grouppred_cvpcr.img')};
matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
matlabbatch{1}.spm.util.defs.out{1}.push.savedir.saveusr = {'X:\'}; %'C:\rtFMRI\'
matlabbatch{1}.spm.util.defs.out{1}.push.fov.file = {[pattern_dir '\' niis.name]};
matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 0;
matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [0 0 0];
matlabbatch{1}.spm.util.defs.out{1}.push.prefix = 'w';
spm_jobman('run',matlabbatch)
