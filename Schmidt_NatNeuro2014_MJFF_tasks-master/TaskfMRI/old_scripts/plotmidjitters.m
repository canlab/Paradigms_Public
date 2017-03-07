clear all; close all;
figure
for i=1:5
    resultname=strcat('stimlistSession', num2str(i), '.mat');
    load(resultname)
    newstimlist(:,i)=stimlist(:,1);
    
    if i==1
        plot(stimlist, 'b')
        hold
    elseif i==2
        plot(stimlist, 'y')
        hold on
    elseif i==3
        plot(stimlist, 'g')
        hold on
    elseif i==4
        plot(stimlist, 'k')
        hold on
    else
        plot(stimlist, 'r')
    end
end
