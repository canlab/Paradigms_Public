%Pleasantness ratings of learnt symbols
%09/16/10 Liane Schmidt

clear all; close all;

% Make sure the script is running on Psychtoolbox-3:
AssertOpenGL;


% identification
nsub=input('subject number ?');
nsession=input('session number ?');
resultname=strcat('ILtestPleasRatSub',num2str(nsub),'Session',num2str(nsession));


%Prepares the screen
[Window,Rect] = initializeScreen;


%config screen
screenWidth=Rect(3);
screenHeight=Rect(4);
xcenter=screenWidth/2;
ycenter=screenHeight/2;

%Loading test images
letterA='A';
letterB='B';
nstim=[1 2];
symbol=[];
symbol{1}=imread(strcat('Stim',num2str(nsession),num2str(nstim(1)),letterA,'.bmp'));
symbol{2}=imread(strcat('Stim',num2str(nsession),num2str(nstim(1)),letterB,'.bmp'));
symbol{3}=imread(strcat('Stim',num2str(nsession),num2str(nstim(2)),letterA,'.bmp'));
symbol{4}=imread(strcat('Stim',num2str(nsession),num2str(nstim(2)),letterB,'.bmp'));
symbol{5}=imread(strcat('Stim',num2str(nsession+1),num2str(nstim(1)),letterA,'.bmp'));
symbol{6}=imread(strcat('Stim',num2str(nsession+1),num2str(nstim(1)),letterB,'.bmp'));
symbol{7}=imread(strcat('Stim',num2str(nsession+1),num2str(nstim(2)),letterA,'.bmp'));
symbol{8}=imread(strcat('Stim',num2str(nsession+1),num2str(nstim(2)),letterB,'.bmp'));

%trialvector
totaltrial=8;
trialvector=randperm(8);

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

% ready to start
DrawFormattedText(Window, 'Ready','center','center',355);
readytime=Screen('Flip',Window);

% % get devnumbers: internal keyboard
% devnumberlap=0;
% if devnumberlap == 0
%     ds=PsychHID('Devices'); 
%     xx = zeros(1,length(ds));
%     xx(strmatch('Keyboard',str2mat(ds.usageName))) = xx(strmatch('Keyboard',str2mat(ds.usageName)))+1;
%     xx(strmatch('Apple Keyboard',str2mat(ds.product))) = xx(strmatch('Apple Keyboard',str2mat(ds.product))) + 1; %labtop
% 
%     if ~any(xx==2)
%         beep,beep,beep
%         error('Cannot Find Xkeys Keyboard device!');
%         Screen('CloseAll');
%     else
%         devnumberlap =find(xx==2);
%     end
% end

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
        S=Screen('MakeTexture',Window, symbol{trialvector(trial)});
        SRec=[xcenter-70 ycenter-240 xcenter+70 ycenter-120]; %center

        Screen('DrawLine',Window,[300 300 300],xcenter-535, ycenter, xcenter+545, ycenter, 8);
        Screen('DrawTexture',Window,S,[],SRec);
            
        Screen('TextSize',Window,48);
        DrawFormattedText(Window,'|',xcenter-540,ycenter-15,[300 300 300]);
        DrawFormattedText(Window,'|',xcenter+540,ycenter-15,[300 300 300]);
        Screen('TextSize',Window,30);
        DrawFormattedText(Window,'most unpleasant',xcenter-630,ycenter-50,[300 300 300]);
        DrawFormattedText(Window,'most pleasant',xcenter+425,ycenter-50,[300 300 300]);
        DrawFormattedText(Window,'-10',xcenter-565,ycenter+40,[300 300 300]);
        DrawFormattedText(Window,'+10',xcenter+505,ycenter+40,[300 300 300]);
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

data=[choice startfix startchoic choicetime trialvector'];
save(resultname,'data', 'reactime', 'trialvector');

clear screen





    
    
    
    
    
    