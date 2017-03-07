clear all; close all;

% Make sure the script is running on Psychtoolbox-3:
AssertOpenGL;


% identification
nsub=input('subject number ?');
nsession=input('session number ?');
resultname=strcat('SideEffectsRatSub',num2str(nsub),'Session',num2str(nsession));


%Prepares the screen
[Window,Rect] = initializeScreen;


%config screen
screenWidth=Rect(3);
screenHeight=Rect(4);
xcenter=screenWidth/2;
ycenter=screenHeight/2;

%trialvector
totaltrial=16;

%time variables
fixationtime=1;

% Set keys.
rightKey = KbName('RightArrow');
leftKey = KbName('LeftArrow');
confirmKey = KbName('SPACE');

% oval parameters
initialovalrects=[xcenter-10 ycenter-10 xcenter+10 ycenter+10]; %central circle
colors=[255 0 0]; %red
xinitialshift=0;
centeredspotRect = CenterRect(initialovalrects, Rect); 
xshift = xinitialshift;
yshift=0;

%variables to save
data=[];
reactime=cell(totaltrial,1);
choicetime=zeros(totaltrial,1);
startfix=zeros(totaltrial,1);
choice=zeros(totaltrial,1);
startchoic=zeros(totaltrial,1);

%list
list=cell(16,2);
list{1,1}='alert';
list{2,1}='calm';
list{3,1}='strong';
list{4,1}='clear-headed';
list{5,1}='well-coordinated';
list{6,1}='energetic';
list{7,1}='contented';
list{8,1}='tranquil';
list{9,1}='quick-witted';
list{10,1}='relaxed';
list{11,1}='attentive';
list{12,1}='proficient';
list{13,1}='happy';
list{14,1}='amicable';
list{15,1}='interested';
list{16,1}='gregarious';

list{1,2}='drowsy';
list{2,2}='excited';
list{3,2}='feeble';
list{4,2}='muzzy';
list{5,2}='clumsy';
list{6,2}='lethargic';
list{7,2}='discontented';
list{8,2}='troubled';
list{9,2}='mentally slow';
list{10,2}='tense';
list{11,2}='dreamy';
list{12,2}='incompetent';
list{13,2}='sad';
list{14,2}='antagonistic';
list{15,2}='bored';
list{16,2}='withdrawn';

xcoordinate(1,1)=xcenter-560; %alert
xcoordinate(2,1)=xcenter-560;%calm
xcoordinate(3,1)=xcenter-580;%strong
xcoordinate(4,1)=xcenter-590;%clear headed
xcoordinate(5,1)=xcenter-590;%well coordinated
xcoordinate(6,1)=xcenter-580;%energetic
xcoordinate(7,1)=xcenter-600;%contented
xcoordinate(8,1)=xcenter-580;%tranquil
xcoordinate(9,1)=xcenter-610;%quick witted
xcoordinate(10,1)=xcenter-580;%relaxed
xcoordinate(11,1)=xcenter-580;%attentive
xcoordinate(12,1)=xcenter-590;%proficient
xcoordinate(13,1)=xcenter-580;%happy
xcoordinate(14,1)=xcenter-580;%amicale
xcoordinate(15,1)=xcenter-580;%interested
xcoordinate(16,1)=xcenter-590;%gregarious

xcoordinate(1,2)=xcenter+500; %drowsy
xcoordinate(2,2)=xcenter+500;%excited
xcoordinate(3,2)=xcenter+510;%feeble
xcoordinate(4,2)=xcenter+500;%muzzy
xcoordinate(5,2)=xcenter+500;%clumsy
xcoordinate(6,2)=xcenter+480;%lethargic
xcoordinate(7,2)=xcenter+440;%discontended
xcoordinate(8,2)=xcenter+480;%troubled
xcoordinate(9,2)=xcenter+420;%mentally slow
xcoordinate(10,2)=xcenter+500;%tense
xcoordinate(11,2)=xcenter+500;%dreamy
xcoordinate(12,2)=xcenter+450;%incompetent
xcoordinate(13,2)=xcenter+520;%sad
xcoordinate(14,2)=xcenter+430;%antagonistic
xcoordinate(15,2)=xcenter+500;%bored
xcoordinate(16,2)=xcenter+470;%withdrawn



% ready to start
DrawFormattedText(Window, 'Ready','center','center',355);
readytime=Screen('Flip',Window);


waitSecs(1)

for trial=1:totaltrial
    
    % fixation
    Screen('TextSize',Window,72);
    DrawFormattedText(Window,'+','center','center',255);
    startfix(trial)=Screen('Flip',Window);
    waitSecs(fixationtime)
    
    xshift = xinitialshift;
    yshift=0;
    
    %stimulus
    while GetSecs>0
        

        Screen('DrawLine',Window,[300 300 300],xcenter-535, ycenter, xcenter+545, ycenter, 8);
        
            
        Screen('TextSize',Window,48);
        DrawFormattedText(Window,'|',xcenter-540,ycenter-45,[300 300 300]);
        DrawFormattedText(Window,'|',xcenter+540,ycenter-45,[300 300 300]);
        Screen('TextSize',Window,30);
        DrawFormattedText(Window,list{trial,1},xcoordinate(trial,1),ycenter-100,[300 300 300]);
        DrawFormattedText(Window,list{trial,2},xcoordinate(trial,2),ycenter-100,[300 300 300]);
        
        xOffset = xshift;
        yOffset = yshift;
        offsetCenteredspotRect = OffsetRect(initialovalrects, xOffset, yOffset);
        Screen('FillOval', Window, [255 0 0], offsetCenteredspotRect);
       
        startchoic(trial)=Screen('Flip',Window);
       

        % response
        [ keyIsDown, seconds, keyCode ] = KbCheck;
        
        if keyIsDown
           
             if keyCode(rightKey);
                xshift=xshift+5;
                reactime{trial}=[reactime{trial} GetSecs];
             elseif keyCode(leftKey)
                 xshift=xshift-5;
                 reactime{trial}=[reactime{trial} GetSecs];
             elseif keyCode(confirmKey)
                 choice(trial)=xshift;
                 choicetime(trial)=GetSecs; %time choice done
                 break;
             end
        end
    end
 end
Screen('TextSize',Window,72);
DrawFormattedText(Window,'END','center','center',255);
Screen('Flip',Window);
waitSecs(5);
clear screen
data=[choice startfix startchoic choicetime];
save(resultname,'data', 'reactime');
