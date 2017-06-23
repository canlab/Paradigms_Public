% AcEquivListRead.m

% Reads the list file for each block

function stimList = AcEquivListRead(listName,thePath)

cd(thePath.lists);

[numeric,txt,raw] = xlsread(listName);
% names = {'TrialType','Response','Duration','Face','LScene','RScene'};
% info = {txt(2:end,1),numeric(2:end,2),numeric(2:end,3),txt(2:end,4),txt(2:end,5),txt(2:end,6)};
% stimList = cell2struct(info,names,2);

stimList.condition=cat(1,raw(2:end,1));
stimList.trialDuration=cat(1,raw{2:end,2});
stimList.leftPic=cat(1,raw(2:end,3));
stimList.rightPic=cat(1,raw(2:end,4));
stimList.corResponse=cat(1,raw{2:end,5});
stimList.fbAns=cat(1,raw{2:end,6});

