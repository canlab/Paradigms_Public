function estimate_norm(V)
%-----------------------------------------------------------------------
% Job saved on 19-Feb-2017 15:42:13 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.tools.oldnorm.est.subj.source = {[V.fname ',1']};
matlabbatch{1}.spm.tools.oldnorm.est.subj.wtsrc = '';
matlabbatch{1}.spm.tools.oldnorm.est.eoptions.template = {[which('EPI.nii,1')]};
matlabbatch{1}.spm.tools.oldnorm.est.eoptions.weight = '';
matlabbatch{1}.spm.tools.oldnorm.est.eoptions.smosrc = 8;
matlabbatch{1}.spm.tools.oldnorm.est.eoptions.smoref = 0;
matlabbatch{1}.spm.tools.oldnorm.est.eoptions.regtype = 'mni';
matlabbatch{1}.spm.tools.oldnorm.est.eoptions.cutoff = 25;
matlabbatch{1}.spm.tools.oldnorm.est.eoptions.nits = 16;
matlabbatch{1}.spm.tools.oldnorm.est.eoptions.reg = 1;
spm_jobman('run',matlabbatch)