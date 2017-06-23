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
resultname=strcat('ILtestVersion4Sub',num2str(nsub),'Session',num2str(nsession));


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
% lookfeedback=imread('nothing_.bmp');
lossfeedback=imread('loss_.bmp');

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

pairgainA=imread(strcat('Stim',num2str(nsession),num2str(nstim(1)),letterA,'.bmp'));
pairgainB=imread(strcat('Stim',num2str(nsession),num2str(nstim(1)),letterB,'.bmp'));
% pairlookA=imread(strcat('Stim',num2str(nsession),num2str(nstim(2)),letterA,'.bmp'));
% pairlookB=imread(strcat('Stim',num2str(nsession),num2str(nstim(2)),letterB,'.bmp'));
pairlossA=imread(strcat('Stim',num2str(nsession),num2str(nstim(2)),letterA,'.bmp'));
pairlossB=imread(strcat('Stim',num2str(nsession),num2str(nstim(2)),letterB,'.bmp'));
% 

% generator reset
rand('state',sum(100*clock));


% create trial vectors
totaltrial=64;
totaltrial2=totaltrial/2;
totaltrial4=totaltrial/4;
totaltrial8=totaltrial/8;

pair=       [];
for i=1:totaltrial2
    pair=[pair randperm(2)];
end


% create left-or-right vectors
gainup=[];
for i=1:totaltrial4
    gainup=[gainup randperm(2)];
end
gainup(gainup==2)=-1;

lossup=[];
for i=1:totaltrial4
    lossup=[lossup randperm(2)];
end
lossup(lossup==2)=-1;


% create feedback vectors
gain=[];
for i=1:totaltrial8
    gain=[gain randperm(4)];
end
gain(gain>1)=-1; % 24 x -1; 8 x 1


% look=[];
% for i=1:totaltrial10
%     look=[look randperm(5)];
% end
% look(look>1)=-1;

loss=[];
for i=1:totaltrial8
    loss=[loss randperm(4)];
end
loss(loss>1)=-1;

%jitter rand
jitterA=[];
for i=1:totaltrial8
    jitterA=[jitterA randperm(4)];
end
    jitterA(jitterA==1)=2; %16x2ms
    jitterA(jitterA==3)=3; %8x3ms
    idx4=find(jitterA==4); 
    idx3=randperm(2);

    idx3(idx3>1)=8;
    jitterA(idx4(idx3(1)))=3; %9th 3ms either within first 4 or last 4
    
    idx51=randperm(3);
    idx51(idx51==2)=4;
    idx51(idx51==1)=2;
    
    idx52=randperm(3);
    idx52(idx52==1)=5;
    idx52(idx52==2)=6;
    idx52(idx52==3)=7;
    
    jitterA(idx4(idx51(1)))=5;% 2nd, 3rd or 4th of 4 is 5
    
    if idx51(1)==4 && idx52(1)==5
        jitterA(idx4(idx52(2)))=5; %6th or 7th of 4 is 5
    else
        jitterA(idx4(idx52(1)))=5; %2nd, 3rd, 4th, 6th, 7th of 4 is 5
    end
    
    firstfour=sum(jitterA(1:16)==4);
    if firstfour>2;
       posfirst5=find(jitterA(1:16)==5);
       posfirst4=find(jitterA(1:16)==4);
       diff1=posfirst5(1)-posfirst4(2);
       diff2=posfirst5(1)-posfirst4(3);
        if abs(diff1)>abs(diff2)
            jitterA(posfirst4(2))=6;
        else
            jitterA(posfirst4(3))=6;
        end
    else
       possecond5=find(jitterA(17:32)==5);
       possecond4=find(jitterA(17:32)==4);
       diff1=possecond5(1)-possecond4(2);
       diff2=possecond5(1)-possecond4(3);
        if abs(diff1)>abs(diff2)
            jitterA(possecond4(2)+16)=6;
        else
            jitterA(possecond4(3)+16)=6;
        end 
    end
    
jitterB=[];
for i=1:totaltrial8
    jitterB=[jitterB randperm(4)];
end
    jitterB(jitterB==1)=2; %16x2ms
    jitterB(jitterB==3)=3; %8x3ms
    idx4=find(jitterB==4); 
    idx3=randperm(2);

    idx3(idx3>1)=8;
    jitterB(idx4(idx3(1)))=3; %9th 3ms either within first 4 or last 4
    
    idx51=randperm(3);
    idx51(idx51==2)=4;
    idx51(idx51==1)=2;
    
    idx52=randperm(3);
    idx52(idx52==1)=5;
    idx52(idx52==2)=6;
    idx52(idx52==3)=7;
    
    jitterB(idx4(idx51(1)))=5;% 2nd, 3rd or 4th of 4 is 5
    
    if idx51(1)==4 && idx52(1)==5
        jitterB(idx4(idx52(2)))=5; %6th or 7th of 4 is 5
    else
        jitterB(idx4(idx52(1)))=5; %2nd, 3rd, 4th, 6th, 7th of 4 is 5
    end
    
    firstfour=sum(jitterB(1:16)==4);
    if firstfour>2;
       posfirst5=find(jitterB(1:16)==5);
       posfirst4=find(jitterB(1:16)==4);
       diff1=posfirst5(1)-posfirst4(2);
       diff2=posfirst5(1)-posfirst4(3);
        if abs(diff1)>abs(diff2)
            jitterB(posfirst4(2))=6;
        else
            jitterB(posfirst4(3))=6;
        end
    else
       possecond5=find(jitterB(17:32)==5);
       possecond4=find(jitterB(17:32)==4);
       diff1=possecond5(1)-possecond4(2);
       diff2=possecond5(1)-possecond4(3);
        if abs(diff1)>abs(diff2)
            jitterB(possecond4(2)+16)=6;
        else
            jitterB(possecond4(3)+16)=6;
        end 
    end
   

% variables for iteration
ngain=0;
nloss=0;

% data to save
session(1:totaltrial)=nsession;
trial=[1:totaltrial];
choice=zeros(1,totaltrial);
response=zeros(1,totaltrial);
feedback=zeros(1,totaltrial);
trialtime=zeros(1,totaltrial);
starttrialtime=zeros(1,totaltrial);
startresponse=zeros(1,totaltrial);
data=zeros(11,totaltrial);
vectordata=zeros(4,32);
resptime=zeros(1,totaltrial+1);
jitter=zeros(1,totaltrial);

% time parameters
readytime=1;
%fixationtime is jittered
stimulitime=3;
choicetime=0.5;
feedbacktime=2;

leftkey=strcat('LeftArrow');
rightkey=strcat('RightArrow');


DrawFormattedText(Window, 'Ready','center','center',355);
Screen('Flip',Window);
waitSecs(1)

a=1;
b=1;
for n=1:length(pair)

    % fixation
    starttrialtime(n)=GetSecs;
    Screen('TextSize',Window,72);
    DrawFormattedText(Window,'+','center','center',255);
    Screen('Flip',Window);
    if pair(n)==1;
        jitter(n)=jitterA(a);
        a=a+1;
    else
        jitter(n)=jitterB(b);
        b=b+1;
    end
    waitSecs(jitter(n)+resptime(n))
    
    switch pair(n)

        case 1 % gain-associated pair (+£1)

            ngain=ngain+1;

            % stimuli

            A=Screen('MakeTexture',Window, pairgainA);
            B=Screen('MakeTexture',Window, pairgainB);

            if gainup(ngain)==1
                pairgainBRec=[xcenter-220 ycenter-60 xcenter-80 ycenter+60]; %left
                pairgainARec=[xcenter+80 ycenter-60 xcenter+220 ycenter+60]; %right
            else
                pairgainBRec=[xcenter+80 ycenter-60 xcenter+220 ycenter+60]; %right
                pairgainARec=[xcenter-220 ycenter-60 xcenter-80 ycenter+60]; %left
            end
            
            Screen('TextSize',Window,72);
            DrawFormattedText(Window,'+','center','center',255);
            Screen('DrawTexture',Window,A,[],pairgainARec);
            Screen('DrawTexture',Window,B,[],pairgainBRec);
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
            Screen('DrawTexture',Window,A,[],pairgainARec);
            Screen('DrawTexture',Window,B,[],pairgainBRec);
            Screen('Flip',Window);
            waitSecs(choicetime)
            
            
             
            
            % feedback
             
            Gain=Screen('MakeTexture',Window, gainfeedback);
            gainfeedbackRec=[xcenter-210 ycenter-100 xcenter+210 ycenter+100];
            
            response(n)=gainup(ngain)*choice(n);
            feedback(n)=-response(n)*gain(ngain);
            Screen('TextSize',Window,72);
            if feedback(n)==1
               Screen('DrawTexture',Window,Gain,[],gainfeedbackRec);
            elseif feedback(n)==-1
               DrawFormattedText(Window,'nothing','center','center',255)
            else
               DrawFormattedText(Window,'######','center','center',255)
            end
            
            Screen('Flip',Window);
            waitSecs(feedbacktime);
            trialtime(n)=(jitter(n)+resptime(n)+resptime(n+1)+choicetime+feedbacktime);

        case 2 % loss pair (-£10)

            nloss=nloss+1;

            % stimuli
            A=Screen('MakeTexture',Window, pairlossA);
            B=Screen('MakeTexture',Window, pairlossB);

            if lossup(nloss)==1
                pairlossBRec=[xcenter-220 ycenter-60 xcenter-80 ycenter+60]; %left
                pairlossARec=[xcenter+80 ycenter-60 xcenter+220 ycenter+60]; %right
            else
                pairlossBRec=[xcenter+80 ycenter-60 xcenter+220 ycenter+60]; %right
                pairlossARec=[xcenter-220 ycenter-60 xcenter-80 ycenter+60]; %left
            end

            
            Screen('TextSize',Window,72);
            DrawFormattedText(Window,'+','center','center',255)
            Screen('DrawTexture',Window,A,[],pairlossARec);
            Screen('DrawTexture',Window,B,[],pairlossBRec);
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
            Screen('DrawTexture',Window,A,[],pairlossARec);
            Screen('DrawTexture',Window,B,[],pairlossBRec);
            Screen('Flip',Window);
            waitSecs(choicetime)
            
            % feedback
       
            Loss=Screen('MakeTexture',Window,lossfeedback);
            lossfeedbackRec=[xcenter-210 ycenter-100 xcenter+210 ycenter+100];
            
            response(n)=lossup(nloss)*choice(n);
            feedback(n)=-response(n)*loss(nloss);
            Screen('TextSize',Window,72);
            if feedback(n)==-1
               Screen('DrawTexture',Window,Loss,[],lossfeedbackRec);
            elseif feedback(n)==1
               DrawFormattedText(Window,'nothing','center','center',255)
            else
               DrawFormattedText(Window,'######','center','center',255)
            end
            
            Screen('Flip',Window);
            waitSecs(feedbacktime);
            trialtime(n)=(jitter(n)+resptime(n)+resptime(n+1)+choicetime+feedbacktime);
            
       

    end

end

%end
Screen('TextSize',Window,72);
DrawFormattedText(Window,'END','center','center',255);
Screen('Flip',Window);
waitSecs(5);

% money=(sum(pair==1&feedback==1)-sum(pair==3&feedback==-1))*10;
data=[session' trial' pair' starttrialtime' jitter' startresponse' trialtime' resptime(2:65)' choice' response' feedback'];
vectordata=[gainup; gain; lossup; loss].';
save(resultname,'data','vectordata');

clear screen

