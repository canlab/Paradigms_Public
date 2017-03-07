% Instrumental learning with monetary gain and loss
%  Behavioural test
%  Mathias Pessiglione April 2005 followed by Stefano Palminteri July 2009
%  followed by Liane Schmidt 2010
clear all; close all;

% Make sure the script is running on Psychtoolbox-3:
AssertOpenGL;


% identification
nsub=input('subject number ?');
nsession=input('session number ?');
resultname=strcat('ILtestSubVersion3',num2str(nsub),'Session',num2str(nsession));


%Prepares the screen
[Window,Rect] = initializeScreen;

% Sets up keyboard and keys
k = getKeyboardNumber;
KbCheck(k);


screenWidth=Rect(3);
screenHeight=Rect(4);
xcenter=screenWidth/2;
ycenter=screenHeight/2;

% DrawFormattedText(Window, 'Loading images.\nThe experiment will begin shortly.','center','center',255);
% Screen('Flip', Window)
% waitSecs(2);


% Loading images
% cross=imread('Cross.bmp');
gainfeedback=imread('win_.bmp');
lookfeedback=imread('nothing_.bmp');
% lossfeedback=imread('loss_.bmp');

nstim=1:2;

if nsession>3;
    nsession=nsession-3;
    nstim=[2 1];
end
% counterbalances symbols across subjects

if nsub/2==floor(nsub/2)
    letterA='A';
    letterB='B';
else
    letterA='B';
    letterB='A';
end

pairAgainA=imread(strcat('Stim',num2str(nsession),num2str(nstim(1)),letterA,'.bmp'));
pairAgainB=imread(strcat('Stim',num2str(nsession),num2str(nstim(1)),letterB,'.bmp'));
pairBgainA=imread(strcat('Stim',num2str(nsession),num2str(nstim(2)),letterA,'.bmp'));
pairBgainB=imread(strcat('Stim',num2str(nsession),num2str(nstim(2)),letterB,'.bmp'));
% pairlossA=imread(strcat('Stim',num2str(nsession),num2str(nstim(3)),letterA,'.bmp'));
% pairlossB=imread(strcat('Stim',num2str(nsession),num2str(nstim(3)),letterB,'.bmp'));
% 

% generator reset
rand('state',sum(100*clock));


% create trial vectors
totaltrial=20;
totaltrial2=totaltrial/2;
totaltrial4=totaltrial/4;
totaltrial8=totaltrial/8;


pair=       [];
for i=1:totaltrial2
    pair=[pair randperm(2)];
end

% create left-or-right vectors
gainupA=[];
for i=1:totaltrial4
    gainupA=[gainupA randperm(2)];
end
gainupA(gainupA==2)=-1;

gainupB=[];
for i=1:totaltrial4
    gainupB=[gainupB randperm(2)];
end
gainupB(gainupB==2)=-1;

% create feedback vectors

gainA=[];
for i=1:6
    gainA=[gainA randperm(3)];
end
gainA(gainA>1)=-1; 
gainA1=gainA(1:9);
gainA2=gainA(10:18);
gainA1(10)=-1;
gainA2(10)=-1;
gainA(1:10)=gainA1;
gainA(11:20)=gainA2;

gainB=[];
for i=1:6
    gainB=[gainB randperm(3)];
end
gainB(gainB>1)=-1; 
gainB1=gainB(1:9);
gainB2=gainB(10:18);
gainB1(10)=-1;
gainB2(10)=-1;
gainB(1:10)=gainB1;
gainB(11:20)=gainB2;


% variables for iteration
ngainA=0;
ngainB=0;
% nloss=0;

% data to save
session(1:totaltrial)=nsession;
trial=[1:totaltrial];
choice=zeros(1,totaltrial);
response=zeros(1,totaltrial);
feedback=zeros(1,totaltrial);
resptime=zeros(1,totaltrial+1);
starttrialtime=zeros(1,totaltrial);
startresponse=zeros(1,totaltrial);
data=zeros(9,totaltrial);
vectordata=zeros(4,40);

% time parameters
readytime=1;
fixationtime=3; %here jitter

choicetime=0.5;
feedbacktime=2;
trialtime=zeros(1,totaltrial);
leftkey=strcat('LeftArrow');
rightkey=strcat('RightArrow');


DrawFormattedText(Window, 'Ready','center','center',355);
Screen('Flip',Window);
waitSecs(1)

for n=1:length(pair)
    
    % fixation
    starttrialtime(n)=GetSecs;  
    Screen('TextSize',Window,72);
    DrawFormattedText(Window,'+','center','center',255);
    Screen('Flip',Window);
    waitSecs(fixationtime+resptime(n))
    
      switch pair(n)
          
        case 1 % gain-associated pairA (+£1)

            ngainA=ngainA+1;
            % stimuli
            A=Screen('MakeTexture',Window, pairAgainA);
            B=Screen('MakeTexture',Window, pairAgainB);

            if gainupA(ngainA)==1
                pairAgainBRec=[xcenter-220 ycenter-60 xcenter-80 ycenter+60]; %left
                pairAgainARec=[xcenter+80 ycenter-60 xcenter+220 ycenter+60]; %right
            else
                pairAgainBRec=[xcenter+80 ycenter-60 xcenter+220 ycenter+60]; %right
                pairAgainARec=[xcenter-220 ycenter-60 xcenter-80 ycenter+60]; %left
            end
            
            Screen('TextSize',Window,72);
            DrawFormattedText(Window,'+','center','center',255);
            Screen('DrawTexture',Window,A,[],pairAgainARec);
            Screen('DrawTexture',Window,B,[],pairAgainBRec);
            Screen('Flip',Window);
            startresponse(n)=GetSecs;
            endtime=startresponse(n)+3;
                      
            % response
           
            while (GetSecs<=endtime)
                [keyIsDown, secs, keyCode] = KbCheck(k);
                if keyIsDown==1
                    resptime(n+1)=GetSecs-startresponse(n);
                    
                    break;
                end
            end
            
            tmp=KbName(find(keyCode));
            answleft=strcmp(tmp,leftkey);
            answright=strcmp(tmp,rightkey);
            
            %check keys
            if answleft==1
                choice(n)=-1;
                var=175;
            elseif answright==1
                choice(n)=1;
                var=125;
            else
                choice(n)=0;
                var=0;
            end

            DrawFormattedText(Window,'+','center','center',255);
            DrawFormattedText(Window,'^',xcenter+var*choice(n),ycenter+60,255);
            Screen('DrawTexture',Window,A,[],pairAgainARec);
            Screen('DrawTexture',Window,B,[],pairAgainBRec);
            Screen('Flip',Window);
            waitSecs(choicetime)
       
            
            % feedback
             
            Gain=Screen('MakeTexture',Window, gainfeedback);
            Look=Screen('MakeTexture',Window, lookfeedback);
            
            gainfeedbackRec=[xcenter-210 ycenter-100 xcenter+210 ycenter+100];
            lookfeedbackRec=[xcenter-210 ycenter-100 xcenter+210 ycenter+100];
            
            response(n)=gainupA(ngainA)*choice(n);
            feedback(n)=-response(n)*gainA(ngainA);
            
            Screen('TextSize',Window,72);
            if feedback(n)==1
               Screen('DrawTexture',Window,Gain,[],gainfeedbackRec);
            elseif feedback(n)==-1
               Screen('Drawtexture',Window,Look,[],lookfeedbackRec);
            else
               DrawFormattedText(Window,'######','center','center',255)
            end
            
            Screen('Flip',Window);
            waitSecs(feedbacktime);
            trialtime(n)=(fixationtime+resptime(n)+resptime(n+1)+choicetime+feedbacktime);
            
          case 2 % gain associated pair B

            ngainB=ngainB+1;

            % stimuli
            A=Screen('MakeTexture',Window, pairBgainA);
            B=Screen('MakeTexture',Window, pairBgainB);

            if gainupB(ngainB)==1
                pairBgainBRec=[xcenter-220 ycenter-60 xcenter-80 ycenter+60]; %left
                pairBgainARec=[xcenter+80 ycenter-60 xcenter+220 ycenter+60]; %right
            else
                pairBgainBRec=[xcenter+80 ycenter-60 xcenter+220 ycenter+60]; %right
                pairBgainARec=[xcenter-220 ycenter-60 xcenter-80 ycenter+60]; %left
            end

            
            Screen('TextSize',Window,72);
            DrawFormattedText(Window,'+','center','center',255)
            Screen('DrawTexture',Window,A,[],pairBgainARec);
            Screen('DrawTexture',Window,B,[],pairBgainBRec);
            Screen('Flip',Window);
            startresponse(n)=GetSecs;
            endtime=startresponse(n)+3;
                      
            % response
           
            while (GetSecs<=endtime)
                [keyIsDown, secs, keyCode] = KbCheck(k);
                if keyIsDown==1
                   resptime(n+1)=GetSecs-startresponse(n); 
                    break;
                end
            end
            
            tmp=KbName(find(keyCode));
            answleft=strcmp(tmp,leftkey);
            answright=strcmp(tmp,rightkey);
            
            %check keys
            if answleft==1
                choice(n)=-1;
                var=175;
            elseif answright==1
                choice(n)=1;
                var=125;
            else
                choice(n)=0;
                var=0;
            end
            
            DrawFormattedText(Window,'+','center','center',255);
            DrawFormattedText(Window,'^',xcenter+var*choice(n),ycenter+60,255);
            Screen('DrawTexture',Window,A,[],pairBgainARec);
            Screen('DrawTexture',Window,B,[],pairBgainBRec);
            Screen('Flip',Window);
            waitSecs(choicetime)
            
            % feedback
       
            Gain=Screen('MakeTexture',Window,gainfeedback);
            Look=Screen('MakeTexture',Window, lookfeedback);
            gainfeedbackRec=[xcenter-210 ycenter-100 xcenter+210 ycenter+100];
            lookfeedbackRec=[xcenter-210 ycenter-100 xcenter+210 ycenter+100];
            
            response(n)=gainupB(ngainB)*choice(n);
            feedback(n)=-response(n)*gainB(ngainB);
            
            Screen('TextSize',Window,72);
            
            if feedback(n)==1
               Screen('DrawTexture',Window,Gain,[],gainfeedbackRec);
            elseif feedback(n)==-1
               Screen('Drawtexture',Window,Look,[],lookfeedbackRec);
            else 
               DrawFormattedText(Window,'######','center','center',255) 
            end
            
            Screen('Flip',Window);
            waitSecs(feedbacktime);
            trialtime(n)=(fixationtime+resptime(n)+resptime(n+1)+choicetime+feedbacktime);
    

    end

end

%end
Screen('TextSize',Window,72);
DrawFormattedText(Window,'END','center','center',255);
Screen('Flip',Window);
waitSecs(5);
% 
data=[session' trial' pair' starttrialtime' resptime(2:21)' trialtime' choice' response' feedback'];
vectordata=[gainupA'; gainupB'; gainA'; gainB'].';
save(resultname,'data','vectordata');

clear screen

