% AcEquivListRead.m

% Reads the list file for each block

function readList = learningTaskStimArrange(stimList,stimPics)


numTrials=length(stimList.condition);

% Establishes the vector for readList (each position will contain a cell
% array w/the dur, face and scenes for each trial)
%readList=[1:numTrials]';

% Why not just make a 2-D cell array then?
readList={};


% Progresses through the stim presentation list, grouping the trigram for
% each trial along w/its duration
for i=1:numTrials
    % Checks that it isn't a fix trial
    if strcmp(stimList.condition{i},'fix')==0
        % Reads the entry for this trial's face picture and isolates the
        % image number
        leftPicFile=stimList.leftPic{i};
        stringLength=length(leftPicFile);
        leftNum=str2num(leftPicFile( (stringLength-1):stringLength));
        % Stores the pic w/that number from facePics in a full list for the
        % block
        readList{i,1}=stimPics{leftNum};
        
        % Repeats for LScene and RScene
        rightPicFile=stimList.rightPic{i};
        stringLength=length(rightPicFile);
        rightNum=str2num(rightPicFile((stringLength-1):stringLength));
        
        readList{i,2}=stimPics{rightNum};
        
        
    end
end
    