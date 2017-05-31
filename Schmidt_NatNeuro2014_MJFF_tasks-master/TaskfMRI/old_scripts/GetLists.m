%takes GAresults.mat and creates stimlist to implement in SCMtask.m
% created 09/09/2010 by Liane Schmidt

% function [condition jitter]=GetLists

% load GAworkspace.mat

stimlist=M.stimlist;
%check number of 1 and 2 conditions and increase or decrease to 40:40
cond1=sum(stimlist==1);
cond2=sum(stimlist==2);

% compare conditions and exchange events
diffcond12=cond1-cond2;
diffcond21=cond2-cond1;
begin=0;

if diffcond12>0 % #1>#2
    idx2=find(stimlist==2);
    idx1=find(stimlist==1);
    for i=1:diffcond12
        pos(i)=RandSample(idx1);
        while begin==0
            if i==1
                stimlist(pos(i))=2;
                begin=1;
            elseif ~ismember(pos(i),pos(1:i-1))
                stimlist(pos(i))=2;
                begin=1;
            end
        end     
    end
    
elseif diffcond21 % #1<#2
    
    idx2=find(stimlist==2);
    idx1=find(stimlist==1);
    for i=1:diffcond21
        pos(i)=RandSample(idx2);
        while begin==0
           if i==1
                stimlist(pos(i))=1;
                begin=1;
            elseif ~ismember(pos(i),pos(1:i-1))
                stimlist(pos(i))=1;
                begin=1;
            end
        end
        
    end
    
end

% % check for number of null events
%
cond0=sum(stimlist==0);
diffcond0=cond0-80;

if diffcond0>0 % too many zeros
    idx0=find(stimlist==0);
    cond02=diffcond0/2;
    for i=1:diffcond0
        if i<=cond02
            stimlist(Randsample(idx0))=1;
        else
            stimlist(Randsample(idx0))=2;
        end
    end
    
    
else
    diffcondall=(cond1+cond2)-80;
    condall=diffcondall/2;
    idx1=find(stimlist==1);
    idx2=find(stimlist==2);
    
    for i=1:diffcondall
        if i<=condall
            stimlist(RandSample(idx1))=0;
        else
            stimlist(RandSample(idx2))=0;
        end
    end
end

% stimlist(stimlist==0)=3;
% 
% if sum(stimlist==3)~=80 && sum(stimlist==1)>40
%    stimlist(RandSample(find(stimlist==1)))=0;
% elseif sum(stimlist==3)~=80 && sum(stimlist==2)>40
%     stimlist(RandSample(find(stimlist==2)))=0;
% end
    
 

% return

