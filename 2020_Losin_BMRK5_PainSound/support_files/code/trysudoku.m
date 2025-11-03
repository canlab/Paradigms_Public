function [sudoku, retval] = trysudoku

clear

nrow=3;
ncol=3;
nval=3;
sudoku=zeros(nrow,ncol);

% start
for r = 1:nrow
    for c = 1:ncol
        opts=randperm(nval);
        i=0;
        keepgoing=1;
        while keepgoing
            i=i+1;
            if i>nval
                retval=1;
                return;
            end
            
            sudoku(r,c)=opts(i);
            
            keepgoing=testsudoku(sudoku);
        end
    end
end

retval=0;