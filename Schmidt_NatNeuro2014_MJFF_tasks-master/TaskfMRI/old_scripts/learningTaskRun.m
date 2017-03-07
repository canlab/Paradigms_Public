
function theData = learningTaskRun(expVars,thePath)


%Prepares the screen
[Window,Rect] = initializeScreen;

% Sets up keyboard
k = getKeyboardNumber;
KbCheck(k);

screenWidth=Rect(3);
screenHeight=Rect(4);
midlineWidth=screenWidth/2;
midlineHeight=screenHeight/2;
sideBuffer=screenWidth/20;
heightBuffer=screenHeight/10;

leftRec=[sideBuffer*5 heightBuffer*3 midlineWidth-sideBuffer screenHeight-heightBuffer*3.5];
rightRec=[midlineWidth+sideBuffer heightBuffer*3 screenWidth-sideBuffer*5 screenHeight-heightBuffer*3.5];



DrawFormattedText(Window, 'Loading images.\nThe experiment will begin shortly.','center','center',255);
Screen('Flip',Window);

stimPics = learningTaskPicLoader(thePath.stim);

stimList=learningTaskListRead(expVars.listName,thePath);

readList=learningTaskStimArrange(stimList,stimPics);
numTrials=length(readList);

% Makes the textures
for i=1:numTrials
    if isempty(readList{i,1})==0
        leftPic=readList{i,1};
        leftPicPtrs{i}=Screen('MakeTexture',Window,leftPic);

        rightPic=readList{i,2};
        rightPicPtrs{i}=Screen('MakeTexture',Window,rightPic);
    end
end




%expVars.ek=ek;
expVars.k=k;
theData.startTimes=zeros(1,numTrials);
theData.response=ones(1,numTrials)*3;
theData.RTs=zeros(1,numTrials);
theData.accuracy=cell(1,numTrials);
iti=2;
fbTime=1;

DrawFormattedText(Window, 'Press ''t'' to continue','center','center',255);
Screen('Flip',Window);

getKey('t',k);
blockStart=getSecs;
theData.blockStart=blockStart;
DrawFormattedText(Window, 'Get Ready!','center','center',255);
Screen('Flip',Window);

waitSecs(1);

Screen('TextSize',Window,72);
%Screen('DrawTexture',Window,fixPtr);
DrawFormattedText(Window,'+','center','center',255);
Screen('Flip',Window);

waitSecs(2);

idealDur=3;

for i=1:numTrials
    dur=stimList.trialDuration(i);
    trialStartTime=getSecs;

    theData.startTimes(i)=trialStartTime-blockStart;


    if strcmp(stimList.condition{i},'fix')==0

        % PRESENTS STIMS

        leftPtr=leftPicPtrs{i};
        Screen('DrawTexture',Window,leftPtr,[],leftRec);

        rightPtr=rightPicPtrs{i};
        Screen('DrawTexture',Window,rightPtr,[],rightRec);

        Screen('Flip',Window);




        % COLLECTS RESPONSE
        [keys RT]=recordKeys(idealDur+blockStart,dur,k);
        try
            subjAns = convertResponse(keys(1))  % convert to match infoStruct.Response
        catch
            subjAns=9;
        end
        theData.response(i)=subjAns;
        theData.RTs(i)=RT(1);

        % CALCULATES ACCURACY
        if subjAns==stimList.corResponse(i)
            theData.accuracy{i}='Correct';
        elseif subjAns==9
            theData.accuracy{i}='Invalid';
        else
            theData.accuracy{i}='Incorrect';
        end



        % CALCULATES & DISPLAYS FEEDBACK
        % R condition
        if strcmp(stimList.condition{i},'R')
            greenColors=[0 300 0];
            if strcmp(theData.accuracy{i},'Correct')
                if stimList.fbAns(i)==stimList.corResponse(i)
                    DrawFormattedText(Window, 'Correct! +1','center','center',greenColors);
                else
                    DrawFormattedText(Window, 'Incorrect! +0','center','center',greenColors);
                end
            elseif strcmp(theData.accuracy{i},'Incorrect')
                if stimList.fbAns(i)~=stimList.corResponse(i)
                    DrawFormattedText(Window, 'Correct! +1','center','center',greenColors);
                else
                    DrawFormattedText(Window, 'Incorrect! +0','center','center',greenColors);
                end
            else
                DrawFormattedText(Window, 'INVALID! +0','center','center',255);
            end



        elseif strcmp(stimList.condition{i},'P')
            redColors=[300 0 0];
            if strcmp(theData.accuracy{i},'Correct')
                if stimList.fbAns(i)==stimList.corResponse(i)
                    DrawFormattedText(Window, 'Correct! -0','center','center',redColors);
                else
                    DrawFormattedText(Window, 'Incorrect! -1','center','center',redColors);
                end
            elseif strcmp(theData.accuracy{i},'Incorrect')
                if stimList.fbAns(i)~=stimList.corResponse(i)
                    DrawFormattedText(Window, 'Correct! -0','center','center',redColors);
                else
                    DrawFormattedText(Window, 'Incorrect! -1','center','center',redColors);
                end
            else
                DrawFormattedText(Window, 'INVALID! -1','center','center',redColors);
            end




        else
            if strcmp(theData.accuracy{i},'Correct')
                if strcmp(stimList.fbAns(i),stimList.corResponse(i))
                    DrawFormattedText(Window, 'Correct!','center','center',255);
                else
                    DrawFormattedText(Window, 'Incorrect!','center','center',255);
                end
            elseif strcmp(theData.accuracy{i},'Incorrect')
                if stimList.fbAns(i)~=stimList.corResponse(i)
                    DrawFormattedText(Window, 'Correct!','center','center',255);
                else
                    DrawFormattedText(Window, 'Incorrect!','center','center',255);
                end
            else
                DrawFormattedText(Window, 'INVALID!','center','center',255);
            end

        end
        
                Screen('Flip',Window);
                waitSecs(fbTime);
                



    end
    DrawFormattedText(Window, '+','center','center',255);
    Screen('Flip',Window);
    waitSecs(iti)
    idealDur=idealDur+iti
    realTime=getSecs;
    elapsedTime=realTime-blockStart
    idealDur=elapsedTime;
end

clear Screen