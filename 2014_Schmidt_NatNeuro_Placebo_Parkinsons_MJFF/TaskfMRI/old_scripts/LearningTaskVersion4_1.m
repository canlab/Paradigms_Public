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

%config_mri scanner

% Loading images
gainfeedback=imread('win_.bmp');
lossfeedback=imread('loss_.bmp');
lookfeedback=imread('neutral_.bmp');


% counterbalances symbols across subjects
if nsub/2==floor(nsub/2)
    letterA='A';
    letterB='B';
else
    letterA='B';
    letterB='A';
end
nstim=[1 2];

pairgainA=imread(strcat('Stim',num2str(nsession),num2str(nstim(1)),letterA,'.bmp'));
pairgainB=imread(strcat('Stim',num2str(nsession),num2str(nstim(1)),letterB,'.bmp'));
pairlossA=imread(strcat('Stim',num2str(nsession),num2str(nstim(2)),letterA,'.bmp'));
pairlossB=imread(strcat('Stim',num2str(nsession),num2str(nstim(2)),letterB,'.bmp'));


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

loss=[];
for i=1:totaltrial8
    loss=[loss randperm(4)];
end
loss(loss>1)=-1;

%jitter random sample from exponential distribution (2 to 6ms mean 2.8 ms)


% variables for iteration
ngain=0;
nloss=0;


% data to save
session(1:totaltrial)=nsession;
trial=[1:totaltrial];
choice=zeros(1,totaltrial);
response=zeros(1,totaltrial);
feedback=zeros(1,totaltrial);

%timedata
time1=zeros(1,totaltrial); %beginning of loop
startfix=zeros(1,totaltrial); %onset fixation
endfix=zeros(1,totaltrial); %end fixation
checktime1=zeros(1,totaltrial); %onset response screen
endresp=zeros(1,totaltrial); %end response screen
startchoic=zeros(1,totaltrial); %onset choice screen
endchoic=zeros(1,totaltrial); %end choice screen
checktime2=zeros(1,totaltrial); %onset feedback screen
endfeed=zeros(1,totaltrial); %end feedback screen

jitter=zeros(1,totaltrial);
resptime=zeros(1,totaltrial+1);

data=zeros(9,totaltrial);
vectordata=zeros(4,32);
timedata=zeros(9,totaltrial);

% time parameters
readytime=1;
stimulitime=3;
choicetime=0.5;
feedbacktime=2;

%slicePerVolume=?;
%sliceToWait=3*slicePerVolume;
%sliceTime=TR/slicePerVolume;

leftkey=strcat('LeftArrow');
rightkey=strcat('RightArrow');


DrawFormattedText(Window, 'Ready','center','center',355);
Screen('Flip',Window);
waitSecs(1)

%wait_slice_cenir(defined by variables sclice_etc.); time0=GetSecs; OR nbVoltotrash=3; for
%i=1:nbVoltotrash+1; wait for TTL from scanner; if i==1 TO=GetSecs end end

[jitterA]=jitterdefA;
[jitterB]=jitterdefB;
%jittering random samle from exponential distribution
%jitter=random('exp',2,64,1); var=1;
%for i=1:length(jitter)
% if jitter(i)<=2
%jitter(i)=jitter(i)+2;
%elseif jitter(i)>=6;
%jitter(i)=jitter(i)-var;
% var=var+1;
% end; end
%behavioral task
a=1;
b=1;
for n=1:length(pair)
    if pair(n)==1;
        jitter(n)=jitterA(a);
        a=a+1;
    else
        jitter(n)=jitterB(b);
        b=b+1;
    end

    %wait slice from scanner
    time1(n)=GetSecs;
    
    % fixation
    Screen('TextSize',Window,72);
    DrawFormattedText(Window,'+','center','center',255);
    Screen('Flip',Window);
    startfix(n)=GetSecs;
    waitSecs(jitter(n)+resptime(n))
    endfix(n)=GetSecs;
    
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
            checktime1(n)=GetSecs;
            endtime=checktime1(n)+3;
            
            % response
           
            while (GetSecs<=endtime)
                [x,y,button]=GetMouse;
                if sum(button)>0
                    resptime(n+1)=GetSecs-checktime1(n);
                    break;
                end
            end

            %check buttons
            if button(1)==1 %left
                choice(n)=-1;
                var=175;
            elseif button(2)==1 %right
                choice(n)=1;
                var=125;
            else
                choice(n)=0;
                resptime(n+1)=3;
                var=0;
            end

                    
%                 [keyIsDown, secs, keyCode] = KbCheck(k);
%                 if keyIsDown==1
%                     resptime(n+1)=GetSecs-checktime1(n);
%                     break;
%                 end
%             end
%             
%             tmp=KbName(find(keyCode));
%             
%             answleft=strcmp(tmp,leftkey);
%             answright=strcmp(tmp,rightkey);
%             
%             %check keys
%             if answleft==1
%                 choice(n)=-1;
%                 var=175;
%             elseif answright==1
%                 choice(n)=1;
%                 var=125;
%             else
%                 choice(n)=0;
%                 var=0;
%             end
            
            endresp(n)=GetSecs;
            DrawFormattedText(Window,'+','center','center',255);
            DrawFormattedText(Window,'^',xcenter+var*choice(n),ycenter+60,255);
            Screen('DrawTexture',Window,A,[],pairgainARec);
            Screen('DrawTexture',Window,B,[],pairgainBRec);
            Screen('Flip',Window);
            startchoic(n)=GetSecs;
            waitSecs(choicetime)
            endchoic(n)=GetSecs;
            
             
            
            % feedback
             
            Gain=Screen('MakeTexture',Window, gainfeedback);
            Look=Screen('MakeTexture',Window, lookfeedback);
            gainfeedbackRec=[xcenter-210 ycenter-100 xcenter+210 ycenter+100];
            lookfeedbackRec=[xcenter-210 ycenter-100 xcenter+210 ycenter+100];
            
            response(n)=gainup(ngain)*choice(n);
            feedback(n)=-response(n)*gain(ngain);
            Screen('TextSize',Window,72);
            if feedback(n)==1
               Screen('DrawTexture',Window,Gain,[],gainfeedbackRec);
            elseif feedback(n)==-1
               Screen('DrawTexture',Window,Look,[],lookfeedbackRec);
            else
               DrawFormattedText(Window,'######','center','center',255)
            end
            
            Screen('Flip',Window);
            checktime2(n)=GetSecs;
            waitSecs(feedbacktime);
            endfeed(n)=GetSecs;
            % sliceToWait = sliceToWait + ceil((feedbacktime)/sliceTime);
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
            checktime1(n)=GetSecs;
            endtime=checktime1(n)+3;
                      
            % response
        
           
            
            while (GetSecs<=endtime)
                [x,y,button]=GetMouse;
                if sum(button)>0
                    resptime(n+1)=GetSecs-checktime1(n);
                    break;
                end
            end

            %check buttons
            if button(1)==1 %left
                choice(n)=-1;
                var=175;
            elseif button(2)==1 %right
                choice(n)=1;
                var=125;
            else
                choice(n)=0;
                resptime(n+1)=3;
                var=0;
            end

                    
%             while (GetSecs<=endtime)
%                 [keyIsDown, secs, keyCode] = KbCheck(k);
%                 if keyIsDown==1
%                     resptime(n+1)=GetSecs-checktime1(n);
%                     
%                     break;
%                 end
%             end
%             
%             tmp=KbName(find(keyCode));
%             answleft=strcmp(tmp,leftkey);
%             answright=strcmp(tmp,rightkey);
%             
%             %check keys
%             if answleft==1
%                 choice(n)=-1;
%                 var=175;
%             elseif answright==1
%                 choice(n)=1;
%                 var=125;
%             else
%                 choice(n)=0;
%                 var=0;
%             end

            endresp(n)=GetSecs;
            DrawFormattedText(Window,'+','center','center',255);
            DrawFormattedText(Window,'^',xcenter+var*choice(n),ycenter+60,255);
            Screen('DrawTexture',Window,A,[],pairlossARec);
            Screen('DrawTexture',Window,B,[],pairlossBRec);
            Screen('Flip',Window);
            startchoic(n)=GetSecs;
            waitSecs(choicetime)
            endchoic(n)=GetSecs;
            
            
            % feedback
       
            Loss=Screen('MakeTexture',Window,lossfeedback);
            Look=Screen('MakeTexture',Window, lookfeedback);
            
            lossfeedbackRec=[xcenter-210 ycenter-100 xcenter+210 ycenter+100];
            lookfeedbackRec=[xcenter-210 ycenter-100 xcenter+210 ycenter+100];
            
            response(n)=lossup(nloss)*choice(n);
            feedback(n)=-response(n)*loss(nloss);
            Screen('TextSize',Window,72);
            if feedback(n)==-1
               Screen('DrawTexture',Window,Loss,[],lossfeedbackRec);
            elseif feedback(n)==1
               Screen('DrawTexture',Window,Look,[],lookfeedbackRec);
            else
               DrawFormattedText(Window,'######','center','center',255)
            end
            
            Screen('Flip',Window);
            checktime2(n)=GetSecs;
            waitSecs(feedbacktime);
            endfeed(n)=GetSecs;
            % sliceToWait = sliceToWait + ceil((feedbacktime)/sliceTime);
            trialtime(n)=(jitter(n)+resptime(n)+resptime(n+1)+choicetime+feedbacktime);
    end

end

%end
Screen('TextSize',Window,72);
DrawFormattedText(Window,'END','center','center',255);
Screen('Flip',Window);
waitSecs(5);
% times=[time0 time1] OR T0;
money=(sum(pair==1&feedback==1)-sum(pair==3&feedback==-1))*10;
data=[session' trial' pair' checktime1' checktime2' resptime(2:65)' choice' response' feedback'];
vectordata=[gainup; gain; lossup; loss].';
timedata=[time1' startfix' endfix' checktime1' endresp' startchoic' endchoic' checktime2' endfeed'];
save(resultname,'data','vectordata', 'money', 'timedata');

clear screen

