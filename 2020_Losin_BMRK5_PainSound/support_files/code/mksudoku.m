function [t, retval] = mksudoku

% init
clear
i=0;
keepgoing=1;
while keepgoing
    [t,r] = trysudoku;
    keepgoing=r;
    i=i+1;
    if i>1000
        retval=1;
        fprintf 'FAILED\n'
        return;
    end
end
retval=0;