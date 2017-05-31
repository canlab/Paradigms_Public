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
resultname=strcat('ILtestJoySub',num2str(nsub),'Session',num2str(nsession));


%Prepares the screen
[Window,Rect] = initializeScreen;

%config screen
screenWidth=Rect(3);
screenHeight=Rect(4);
xcenter=screenWidth/2;
ycenter=screenHeight/2;

%%%%%get Gamepadindex%%%%%%%%%%
padnumber=0;
if padnumber == 0
    ds=PsychHID('Devices'); 
    yy = zeros(1,length(ds));
    yy(strmatch('Joystick',str2mat(ds.usageName))) = yy(strmatch('Joystick',str2mat(ds.usageName)))+1;
    yy(strmatch('932',str2mat(ds.product))) = yy(strmatch('932',str2mat(ds.product))) + 1; %Joystick

    if ~any(yy==2)
        beep,beep,beep
        error('Cannot Find Xkeys Keyboard device!');
        Screen('CloseAll');
    else
        padnumber =find(yy==2);
    end
end

gamepadIndex=padnumber;

%%%other joystick variables
triggerRefract=0.25;
lastTrigger=0; % will get reset when trigger pulled

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

%loads jitters for fixatttion
jittername=strcat('Jitter',num2str(nsession));
load(jittername)
midjittername=strcat('midjitter',num2str(nsession));
load(midjittername)

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

% variables for iteration
ngain=0;
nloss=0;
starttrial=0;
endtrial=0;
leftkey=strcat('LeftArrow');
rightkey=strcat('RightArrow');

% data to save
data=zeros(9,totaltrial);
vectordata=zeros(4,32);
timedata=zeros(12,totaltrial);

session(1:totaltrial)=nsession;
trial=[1:totaltrial];
choice=zeros(1,totaltrial);
response=zeros(1,totaltrial);
feedback=zeros(1,totaltrial);

%timedata

starttrial=zeros(1,totaltrial); %onset trial loop
startfix=zeros(1,totaltrial); %onset fixation
endfix=zeros(1,totaltrial); %end fixation
checktime1=zeros(1,totaltrial); %onset response screen
endresp=zeros(1,totaltrial); %end response screen
startchoic=zeros(1,totaltrial); %onset choice screen
endchoic=zeros(1,totaltrial); %end choice screen
checktime2=zeros(1,totaltrial); %onset feedback screen
endfeed=zeros(1,totaltrial); %end feedback screen
endtrial=zeros(1,totaltrial); %end trial loop
resptime=zeros(1,totaltrial);
bonus=zeros(1,totaltrial);
times=[];

% other time parameters
feedbacktime=2;

% ready to start
DrawFormattedText(Window, 'Ready','center','center',355);
readytime=Screen('Flip',Window);

%get devnumbers: internal keyboard
devnumberlap=0;
if devnumberlap == 0
    ds=PsychHID('Devices'); 
    xx = zeros(1,length(ds));
    xx(strmatch('Keyboard',str2mat(ds.usageName))) = xx(strmatch('Keyboard',str2mat(ds.usageName)))+1;
    xx(strmatch('Apple Internal Keyboard / Trackpad',str2mat(ds.product))) = xx(strmatch('Apple Internal Keyboard / Trackpad',str2mat(ds.product))) + 1; %labtop

    if ~any(xx==2)
        beep,beep,beep
        error('Cannot Find Xkeys Keyboard device!');
        Screen('CloseAll');
    else
        devnumberlap =find(xx==2);
    end
end

%%% wait for key  %%%

starttask=0;
key='s';
keyChar =0;
Ts=[];

% key
while starttask==0
    [keyIsDown,secs,keyCode]=KbCheck(devnumberlap);
    if keyIsDown==1
        keyChar = KbName(keyCode);
        hit=strcmp(lower(keyChar),key);
        if hit==1
            keytime=secs;
            starttask=1;
        end
    end
end

%wait_trigger from first TR and pause for 6 sec
[devnumber T0] = psych_WaitFor('t',0,0);

pause(6)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% behavioral task%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


starttrialloop=GetSecs;

for n=1:length(pair)

    starttrial(n)=GetSecs;

    % fixation
    Screen('TextSize',Window,72);
    DrawFormattedText(Window,'+','center','center',255);
    startfix(n)=Screen('Flip',Window);
    waitSecs(jitter(n))
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
            checktime1(n)=Screen('Flip',Window);
            endtime=checktime1(n)+3;
            
            % response
           
            while (GetSecs<=endtime)
                if Gamepad('GetButton',gamepadIndex,1) && GetSecs-lastTrigger>triggerRefract  
                resptime(n)=GetSecs-checktime1(n);
                lastTrigger=GetSecs;
                break;
                elseif Gamepad('GetButton',gamepadIndex,3) && GetSecs-lastTrigger>triggerRefract
                    resptime(n)=GetSecs-checktime1(n);
                    lastTrigger=GetSecs;
                break;
                end
            end

            % check buttons
            if Gamepad('GetButton',gamepadIndex,1)==1 %left
                choice(n)=-1;
                var=175;
            elseif Gamepad('GetButton',gamepadIndex,3)==1%right
                choice(n)=1;
                var=125;
            else
                choice(n)=0;
                resptime(n)=3;
                var=0;
            end


            bonus(n)=3-resptime(n);
            endresp(n)=GetSecs;
            if choice(n)==0
                DrawFormattedText(Window,'######','center','center',255);
                startchoic(n)=Screen('Flip',Window);
                waitSecs(midjitter(n)+bonus(n))
                endchoic(n)=GetSecs;
            else
                DrawFormattedText(Window,'+','center','center',255);
                DrawFormattedText(Window,'^',xcenter+var*choice(n),ycenter+60,255);
                Screen('DrawTexture',Window,A,[],pairgainARec);
                Screen('DrawTexture',Window,B,[],pairgainBRec);
                startchoic(n)=Screen('Flip',Window);
                waitSecs(midjitter(n)+bonus(n))
                endchoic(n)=GetSecs;
            end
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
            checktime2(n)=Screen('Flip',Window);         
            waitSecs(feedbacktime);
            endfeed(n)=GetSecs;
            

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
            checktime1(n)=Screen('Flip',Window);           
            endtime=checktime1(n)+3;
                      
            % response
           
            while (GetSecs<=endtime)
                if Gamepad('GetButton',gamepadIndex,1) && GetSecs-lastTrigger>triggerRefract  
                resptime(n)=GetSecs-checktime1(n);
                lastTrigger=GetSecs;
                break;
                elseif Gamepad('GetButton',gamepadIndex,3) && GetSecs-lastTrigger>triggerRefract
                    resptime(n)=GetSecs-checktime1(n);
                    lastTrigger=GetSecs;
                break;
                end
            end

            % check buttons
            if Gamepad('GetButton',gamepadIndex,1)==1 %left
                choice(n)=-1;
                var=175;
            elseif Gamepad('GetButton',gamepadIndex,3)==1%right
                choice(n)=1;
                var=125;
            else
                choice(n)=0;
                resptime(n)=3;
                var=0;
            end


            bonus(n)=3-resptime(n);
            endresp(n)=GetSecs;
            
            if choice(n)==0
                DrawFormattedText(Window,'######','center','center',255);
                startchoic(n)=Screen('Flip',Window);
                waitSecs(midjitter(n)+bonus(n))
                endchoic(n)=GetSecs;
            else
                DrawFormattedText(Window,'+','center','center',255);
                DrawFormattedText(Window,'^',xcenter+var*choice(n),ycenter+60,255);
                Screen('DrawTexture',Window,A,[],pairlossARec);
                Screen('DrawTexture',Window,B,[],pairlossBRec);
                startchoic(n)=Screen('Flip',Window);
                waitSecs(midjitter(n)+bonus(n))
                endchoic(n)=GetSecs;
            end
            
            
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
            checktime2(n)=Screen('Flip',Window);            
            waitSecs(feedbacktime);
            endfeed(n)=GetSecs;
    end
       
    endtrial(n)=GetSecs;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%save data and variables%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%variables%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

endtrialloop=GetSecs;
Screen('TextSize',Window,72);
DrawFormattedText(Window,'END','center','center',255);
Screen('Flip',Window);
waitSecs(5);

times=[readytime keytime T0 starttrialloop endtrialloop];
money=(sum(pair==1&feedback==1)-sum(pair==2&feedback==-1))*10;
data=[session' trial' pair' checktime1' checktime2' resptime' choice' response' feedback'];
vectordata=[gainup; gain; lossup; loss].';
timedata=[starttrial' startfix' jitter endfix' checktime1' endresp' startchoic' endchoic' checktime2' bonus' endfeed' endtrial'];
save(resultname,'data','vectordata', 'money', 'timedata','times', 'Ts');

clear screen

