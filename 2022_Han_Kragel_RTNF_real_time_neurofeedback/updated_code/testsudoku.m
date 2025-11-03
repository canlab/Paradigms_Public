function [testval]=testsudoku(sudoku)

[nrows ncols] = size(sudoku);
nval=3;
ctest=0;
rtest=0;

for c = 1:ncols
    for val = 1:nval
        ctest=ctest+(sum(length(find(sudoku(:,c)==val)))>(nrows/nval));
    end
end

for r=1:nrows
    for val = 1:nval
        rtest=rtest+(sum(length(find(sudoku(r,:)==val)))>(ncols/nval));
    end
end

testval=rtest+ctest;
