function [fname,start_line,SID] = subjectinfo_check(savedir)

% SUBJECT INFORMATION: file exists?
% [fname,start_line,SID] = subjectinfo_check

% Subject ID    
fprintf('\n');
SID = input('Subject ID? ','s');
    
% check if the data file exists
fname = fullfile(savedir, ['s' SID '.mat']);
if ~exist(savedir, 'dir')
    mkdir(savedir);
    whattodo = 1;
else
    if exist(fname, 'file')
        str = ['The Subject ' SID ' data file exists. Press a button for the following options'];
        disp(str);
        whattodo = input('1:Save new file, 2:Save the data from where we left off, Ctrl+C:Abort? ');
    else
        whattodo = 1;
    end
end
    
if whattodo == 2
    load(fname);
    start_line = 1;
    for i = 1:numel(data.dat)
        start_line = start_line + numel(data.dat{i});
    end
else
    start_line = 1;
end
   
end