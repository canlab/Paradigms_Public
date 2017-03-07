% stimlist=M.stimlist;

cond1=[];
for i=1:10
    cond1=[cond1 randperm(5)]
end


cond2=[];
for i=1:8
    cond2=[cond2 randperm(6)]
end



cond1=cond1';
cond2=cond2';
newstimlist(:,1)=stimlist(stimlist(:,1)>0);
% for i=1:length(cond1)
%     if cond1(i,1)==1
%         cond1(i,2)=0;
%     elseif cond2(i,1)==1
%         cond2(i,2)=0;
%     end
% end


        