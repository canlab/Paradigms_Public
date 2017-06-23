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
resultname=strcat('ILtestVersion2Sub',num2str(nsub),'Session',num2str(nsession));


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
lookfeedback=imread('neutral_.bmp');
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

firstpairgainA=imread(strcat('Stim',num2str(nsession),num2str(nstim(1)),letterA,'.bmp'));
firstpairgainB=imread(strcat('Stim',num2str(nsession),num2str(nstim(1)),letterB,'.bmp'));
secondpairgainA=imread(strcat('Stim',num2str(nsession),num2str(nstim(2)),letterA,'.bmp'));
secondpairgainB=imread(strcat('Stim',num2str(nsession),num2str(nstim(2)),letterB,'.bmp'));
% pairlossA=imread(strcat('Stim',num2str(nsession),num2str(nstim(3)),letterA,'.bmp'));
% pairlossB=imread(strcat('Stim',num2str(nsession),num2str(nstim(3)),letterB,'.bmp'));
% 

% generator reset
rand('state',sum(100*clock));


% create trial vectors
totaltrial=96;
totaltrial2=totaltrial/2;
totaltrial4=totaltrial/4;
totaltrial8=totaltrial/8;

% create left-or-right vectors
gainup=[];
for i=1:totaltrial4
    gainup=[gainup randperm(2)];
end
gainup(gainup==2)=-1;


% create feedback vectors
gainfirst=[];
for i=1:totaltrial8
    gainfirst=[gainfirst randperm(4)];
end
gainfirst(gainfirst>1)=-1; 

gainafter=[];
for i=1:totaltrial8
    gainafter=[gainafter randperm(4)];
end
gainafter(gainafter>1)=-1;



% variables for iteration
ngainfirst=0;
ngainafter=0;
% nloss=0;

% data to save
session(1:totaltrial)=nsession;
trial=[1:totaltrial];
choice=zeros(1,totaltrial);
response=zeros(1,totaltrial);
feedback=zeros(1,totaltrial);
% resptime=zeros(1,totaltrial+1);
starttrialtime=zeros(1,totaltrial);
startresponse=zeros(1,totaltrial);
data=zeros(8,totaltrial);
vectordata=zeros(4,48);

% time parameters
readytime=1;
fixationtime=3; %here jitter

choicetime=0.5;
feedbacktime=2;
trialtime=zeros(1,totaltrial);
leftkey=strcat('LeftArrow');
rightkey=strcat('RightArrow');
resptime=zeros(1,totaltrial+1);

DrawFormattedText(Window, 'Ready','center','center',355);
Screen('Flip',Window);
waitSecs(1)

for n=1:totaltrial
    
    % fixation
    starttrialtime(n)=GetSecs;  
    Screen('TextSize',Window,72);
    DrawFormattedText(Window,'+','center','center',255);
    Screen('Flip',Window);
    waitSecs(fixationtime+resptime(n))
    
     % firstgain-associated pair (+£1)
        if n<=48
            ngainfirst=ngainfirst+1;
            % stimuli
            A=Screen('MakeTexture',Window, firstpairgainA);
            B=Screen('MakeTexture',Window, firstpairgainB);

            if gainup(ngainfirst)==1
                firstpairgainBRec=[xcenter-220 ycenter-60 xcenter-80 ycenter+60]; %left
                firstpairgainARec=[xcenter+80 ycenter-60 xcenter+220 ycenter+60]; %right
            else
                firstpairgainBRec=[xcenter+80 ycenter-60 xcenter+220 ycenter+60]; %right
                firstpairgainARec=[xcenter-220 ycenter-60 xcenter-80 ycenter+60]; %left
            end
            
            Screen('TextSize',Window,72);
            DrawFormattedText(Window,'+','center','center',255);
            Screen('DrawTexture',Window,A,[],firstpairgainARec);
            Screen('DrawTexture',Window,B,[],firstpairgainBRec);
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
            Screen('DrawTexture',Window,A,[],firstpairgainARec);
            Screen('DrawTexture',Window,B,[],firstpairgainBRec);
            Screen('Flip',Window);
            waitSecs(choicetime)
       
            
            % feedback
             
            Gain=Screen('MakeTexture',Window, gainfeedback);
            Look=Screen('MakeTexture',Window, lookfeedback);
            
            gainfeedbackRec=[xcenter-210 ycenter-100 xcenter+210 ycenter+100];
            lookfeedbackRec=[xcenter-210 ycenter-100 xcenter+210 ycenter+100];
            
            response(n)=gainup(ngainfirst)*choice(n);
            feedback(n)=-response(n)*gainfirst(ngainfirst);
            
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
            
        else % switch probabilities

            ngainafter=ngainafter+1;

            % stimuli
            A=Screen('MakeTexture',Window, secondpairgainA);
            B=Screen('MakeTexture',Window, secondpairgainB);

            if gainup(ngainafter)==1
                secondpairgainBRec=[xcenter-220 ycenter-60 xcenter-80 ycenter+60]; %left
                secondpairgainARec=[xcenter+80 ycenter-60 xcenter+220 ycenter+60]; %right
            else
                secondpairgainBRec=[xcenter+80 ycenter-60 xcenter+220 ycenter+60]; %right
                secondpairgainARec=[xcenter-220 ycenter-60 xcenter-80 ycenter+60]; %left
            end

            
            Screen('TextSize',Window,72);
            DrawFormattedText(Window,'+','center','center',255)
            Screen('DrawTexture',Window,A,[],secondpairgainARec);
            Screen('DrawTexture',Window,B,[],secondpairgainBRec);
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
            Screen('DrawTexture',Window,A,[],secondpairgainARec);
            Screen('DrawTexture',Window,B,[],secondpairgainBRec);
            Screen('Flip',Window);
            waitSecs(choicetime)
            
            % feedback
       
            Gain=Screen('MakeTexture',Window,gainfeedback);
            Look=Screen('MakeTexture',Window, lookfeedback);
            gainfeedbackRec=[xcenter-210 ycenter-100 xcenter+210 ycenter+100];
            lookfeedbackRec=[xcenter-210 ycenter-100 xcenter+210 ycenter+100];
            
            response(n)=gainup(ngainafter)*choice(n);
            feedback(n)=-response(n)*gainafter(ngainafter);
            
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
data=[session' trial' starttrialtime' resptime(2:97)' trialtime' choice' response' feedback'];
vectordata=[gainup; gainfirst; gainafter].';
save(resultname,'data','vectordata');

clear screen

