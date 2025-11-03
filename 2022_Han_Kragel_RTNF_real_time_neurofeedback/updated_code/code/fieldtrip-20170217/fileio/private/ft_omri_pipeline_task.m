function ft_omri_pipeline_task
% This code should be run on stimulus display computer to read MATLAB variable tOUT and display feedback

Screen('Preference', 'SkipSyncTests', 1);
KbName('UnifyKeyNames');
key.ttl = KbName('5%');
key.s = KbName('s');
TR=.46;
trial_times=[40 124 218 314 418 522 610]*TR; %fixed timings across participants (different stim orders though)
mousebuttons=[1 3]; % to get ratings
trial_start=9999; %initialize with implausible value
jit=9999; %initialize with implausible value

TRACKBALL_MULTIPLIER=1;
% get subject number
subject= str2double(input('What is the subject number?     ','s'));
% get run number
run= str2double(input('What is the run number?     ','s'));

% load in thermal stimulation onsets
stim_ints=dlmread(which(['order' num2str(rem(subject,4)+1) '.txt']));
stim_ints=[48 stim_ints(run,:)];

global ljudObj
ljasm = NET.addAssembly('LJUDDotNet');
ljudObj = LabJack.LabJackUD.LJUD;

AssertOpenGL;
[window, rect] = Screen('OpenWindow',0.5);
% paint black
% Screen('FillRect',window,0); %make gray
gray=GrayIndex(window,0.5);
Screen('FillRect',window,gray);
HideCursor;

%%% configure screen
dspl.screenWidth = rect(3);
dspl.screenHeight = rect(4);
dspl.xcenter = dspl.screenWidth/2;
dspl.ycenter = dspl.screenHeight/2;

%%% create screen for aversiveness ratings
% create SCALE screen for overall intensity rating
dspl.oscale(1).width = 964;
dspl.oscale(1).height = 252;
dspl.oscale(1).w = Screen('OpenOffscreenWindow',0);
% paint black
Screen('FillRect',dspl.oscale(1).w,gray);
% add scale image
dspl.oscale(1).imagefile = which('bartoshuk_scale_clear_experience_larger.bmp');
image = imread(dspl.oscale(1).imagefile);
dspl.oscale(1).texture = Screen('MakeTexture',window,image);
% placement
dspl.oscale(1).rect = [...
    [dspl.xcenter dspl.ycenter]-[0.5*dspl.oscale(1).width 0.5*dspl.oscale(1).height] ...
    [dspl.xcenter dspl.ycenter]+[0.5*dspl.oscale(1).width 0.5*dspl.oscale(1).height]];
% shiftdown = ceil(dspl.screenHeight*0);
% dspl.oscale(1).rect = dspl.oscale(1).rect + [0 shiftdown 0 shiftdown];
Screen('DrawTexture',dspl.oscale(1).w,dspl.oscale(1).texture,[],dspl.oscale(1).rect);
% add title
Screen('TextSize',dspl.oscale(1).w,50);
DrawFormattedText(dspl.oscale(1).w,...
    'AVERSIVENESS',...
    'center',dspl.ycenter-270,255);




cursor.xmin = dspl.oscale.rect(1) + 123;
cursor.width = 709;
cursor.xmax = cursor.xmin + cursor.width;
cursor.size = 8;
cursor.center = cursor.xmin+ ceil(cursor.width/2);
cursor.y = dspl.oscale.rect(4) - 41;
cursor.labels = cursor.xmin + [10 42 120 249 379];

%%% create FIXATION screen
dspl.fixation.w = Screen('OpenOffscreenWindow',0);
% paint black
Screen('FillRect',dspl.fixation.w,gray);
% add text
Screen('TextSize',dspl.fixation.w,60);
DrawFormattedText(dspl.fixation.w,'.','center','center',255);

% initialize
Screen('TextSize',window,72);
DrawFormattedText(window,'.','center','center',255);
timing.initialized = Screen('Flip',window);


% wait for experimenter to press "s" before listening for TTL pulse
keycode(key.s) = 0;
while keycode(key.s) == 0
    [presstime, keycode, delta] = KbWait;
end
timing.spress = presstime;

% ready screen
Screen('TextSize',window,72);
DrawFormattedText(window,'Ready','center','center',255);
timing.readyscreen = Screen('Flip',window);
% wait for TTL pulse to trigger beginning
keycode(key.ttl) = 0;
WaitSecs(.25);
while keycode(key.ttl) == 0
    [presstime, keycode, delta] = KbWait;
end
timing.ttl=presstime;

% fixation screen
Screen('TextSize',window,72);
DrawFormattedText(window,'+','center','center',255);
timing.fixation = Screen('Flip',window);

%%% configure screen
dspl.screenWidth = rect(3);
dspl.screenHeight = rect(4);
dspl.xcenter = dspl.screenWidth/2;
dspl.ycenter = dspl.screenHeight/2;

C=hsv(7);

numTrial = 0;

% Loop this forever (until user cancels)
ntrial=0;
while 1
    
    % Loop this as long as the experiment runs with the same protocol (= data keeps coming in)
    while 1
        
        if abs(GetSecs-trial_times(ntrial+1))<eps;
            % find this trial
            ntrial=ntrial+1;
            timing.onsets(ntrial)=GetSecs;
            % find this trial in stimulation order for this run
            
            trial_start=trial_times(ntrial);
            
            % deliver stimulation
            timing.stimulation(ntrial) = TriggerHeat(stim_ints(ntrial));
            
            
            % initialize rating
            cursor.x = cursor.xmin; %cursor.center - cursor.start(trial,ratingtype);
            jit=randi(5);
            
            
        elseif   abs(GetSecs-(trial_start+floor(14+jit)))<eps
            %             timing.rating_start(ntrial) =  WaitSecs('UntilTime',timing.stimulation(ntrial) + 14 +jit);
            timing.rating_start(ntrial) = GetSecs;
            
            SetMouse(dspl.xcenter,dspl.ycenter);
            
            
            
            % do animated sliding rating
            while 1
                % measure mouse movement
                [x, y, click] = GetMouse;
                % upon right click, record time, freeze for remainder of rating period
                if any(click(mousebuttons))
                    % record time of click
                    timing.response(ntrial) = GetSecs;
                    
                    % draw scale
                    Screen('CopyWindow',dspl.oscale(1).w,window);
                    % draw line to top of rating wedge
                    Screen('DrawLine',window,[0 0 0],...
                        cursor.x,cursor.y-(ceil(.107*(cursor.x-cursor.xmin)))-5,...
                        cursor.x,cursor.y+10,3);
                    Screen('Flip',window);
                    
                    % freeze screen
                    break
                end
                
                % if run out of time
                if GetSecs >=  timing.rating_start(ntrial) + 8
                    % draw scale
                    Screen('CopyWindow',dspl.oscale(1).w,window);
                    Screen('Flip',window);
                    
                    % freeze screen
                    break
                end
                
                % reset mouse position
                SetMouse(dspl.xcenter,dspl.ycenter);
                
                % calculate displacement
                cursor.x = (cursor.x + x-dspl.xcenter) * TRACKBALL_MULTIPLIER;
                % check bounds
                if cursor.x > cursor.xmax
                    cursor.x = cursor.xmax;
                elseif cursor.x < cursor.xmin
                    cursor.x = cursor.xmin;
                end
                
                % draw scale
                Screen('CopyWindow',dspl.oscale(1).w,window);
                % add cursor
                Screen('FillOval',window,[128 128 128],...
                    [[cursor.x cursor.y]-cursor.size [cursor.x cursor.y]+cursor.size]);
                Screen('Flip',window);
            end
            oratings(ntrial) = 100*((cursor.x-cursor.xmin)/cursor.width); %#ok
            
            
            % fixation
            %             Screen('CopyWindow',dspl.fixation.w,window);
            %             WaitSecs('UntilTime', timing.stimulation(ntrial) + 24);
            %             Screen('Flip',window);
            
            
            
            dt=GetSecs- timing.rating_start(ntrial);
        end
        
        
        %% load tOUT here
        load 'tOUT.mat'
        tOUT=tOUT(end);
        
        if run == 2 || run==3 || run==4
            radius=(min(tOUT,100));
            if radius<0;
                radius=0;
            end
            rect=[[dspl.xcenter dspl.ycenter]-[radius radius] [dspl.xcenter dspl.ycenter]+[radius radius]];
            gray=GrayIndex(window,0.5);
            Screen('FillRect',window,gray);
            Screen('FillOval', window,floor(255*C(2,:)),rect);
            
        else
            Screen('FillRect',window,gray);
            radius=randi(100); % perhaps change this based on actual feedback from other people
            
            if radius<0;
                radius=0;
            end
            
            rect=[[dspl.xcenter dspl.ycenter]-[radius radius] [dspl.xcenter dspl.ycenter]+[radius radius]];
            gray=GrayIndex(window,0.5);
            Screen('FillRect',window,gray);
            
            Screen('FillOval', window,[0 0 0],rect);
            
            
        end
        Screen('Flip',window);
    end
    % force Matlab to update the figure
    
    if (GetSecs-timing.ttl)>390
        timing.finish=GetSecs;
        break;
    end
    
    
end % while true

if (GetSecs-timing.ttl)>390
    timing.finish=GetSecs;
    return;
end
end

save(['behav_sub' num2str(subject) '_run' num2str(run)]);
Screen('CloseAll');
