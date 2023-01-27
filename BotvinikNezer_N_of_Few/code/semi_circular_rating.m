function [rating, trajectory, rating_onset, responseOnset, RT] = semi_circular_rating(rating_type, main_dir, p, duration)
%
% code by Rotem Botvinik-Nezer
% September 2020
%
% Edited based on Heejung Jung's and Xiaochun Han's spacetop code
% (which were based on Phil Kragel's code)
%
% This function runs the circular ratings parts for different types of ratings
%
% INPUT:
% rating_type: 'expectation_pain' / 'expectation_temp' / 'pain' / 'intensity' / 'unpleasantness' / 'confidence' and more  (default = 'pain') (string)
% '~main_dir/scale/' should contain an image with this name to load as the
% scale image.
% main_dir: path to the experiment's main directory, where there's a "scale" folder with the images of the scale (string)
% p: psychtoolbox window parameters (structure)
% duration: time (in secs) of the rating part. If self-paced, pass "self_paced" as a string or set value to inf (double)
%                 NOTE that the duration is filled with a fixation
%                 once the participant incidates a response.
%                 e.g. * experimenter fixes rating duration to 4 sec.
%                      * participant RT to respond to rating scale was 1.6 sec.
%                      * response will stay on screen for 0.5 sec
%                      * fixation cross will fill the the remainder of the duration
%                              i.e., 4-1.6-0.5 = 1.9 sec of fixation
% OUTPUT:
% rating: the rating of the participant, based on the angle of rating (double)
% trajectory: n samples x 2 matrix of cursor trajectory (x coord, y coord)
% rating_onset: the time when the rating started (double)
% responseOnset: the time when participant responded (double)
% RT: resopnse time in secs, from rating onset to response onset (double)

if nargin < 1
    rating_type = 'pain';
end

if ischar(duration) && strcmp(duration,'self_paced')
   duration = inf; 
end

% % define prompt based on rating type
% switch rating_type
%     case {'expectations'}
%         rating_prompt = 'How HOT do you expect the NEXT stimulus to be?';
%     case {'pain'}
%         rating_prompt = 'How PAINFUL was the LAST stimulus?';
%     case {'intensity'}
%         rating_prompt = 'How INTENSE was the LAST stimulus?';
%     case {'unpleasantness'}
%         rating_prompt = 'How UNPLEASANT was the LAST stimulus?';
%     case {'confidence'}
%         rating_prompt = 'How CONFIDENT are you in your LAST RATING?';
% end

%% load scale image
image_scale_dir = [main_dir filesep 'scale'];
image_scale = [image_scale_dir filesep rating_type '.png'];

%% initiate response parameters
RT = NaN;
responseOnset = NaN;
rating = NaN;
TRACKBALL_MULTIPLIER=1; % legacy - keep 1 if not needed
SAMPLERATE = .01; % used in continuous ratings

%HideCursor;

%% configure screen
dspl.screenWidth = p.ptb.rect(3);
dspl.screenHeight = p.ptb.rect(4);
dspl.xcenter = dspl.screenWidth/2;
dspl.ycenter = dspl.screenHeight/2;

% create SCALE screen for continuous rating
dspl.cscale.width = 720; % image scale width
dspl.cscale.height = 405; % image scale height
%dspl.cscale.xcenter = 483; % scale center (does not equal to screen center)
%dspl.cscale.ycenter = 407;
dspl.cscale.w = Screen('OpenOffscreenWindow',p.ptb.screenNumber);
% paint black
Screen('FillRect',dspl.cscale.w,0);
% prepare scale image
dspl.cscale.texture = Screen('MakeTexture',p.ptb.window, imread(image_scale));
% placement
dspl.cscale.rect = [...
    [dspl.xcenter dspl.ycenter]-[0.5*dspl.cscale.width 0.5*dspl.cscale.height] ...
    [dspl.xcenter dspl.ycenter]+[0.5*dspl.cscale.width 0.5*dspl.cscale.height]];
Screen('DrawTexture',dspl.cscale.w,dspl.cscale.texture,[],dspl.cscale.rect);
Screen('TextSize',dspl.cscale.w,40);

% determine cursor parameters for all scales
cursor.xmin = dspl.cscale.rect(1);
cursor.xmax = dspl.cscale.rect(3);
cursor.ymin = dspl.cscale.rect(2);
cursor.ymax = dspl.cscale.rect(4);

cursor.size = 8;
cursor.xcenter = ceil(dspl.cscale.rect(1) + (dspl.cscale.rect(3) - dspl.cscale.rect(1))*0.5);
cursor.ycenter = ceil(dspl.cscale.rect(2) + (dspl.cscale.rect(4)-dspl.cscale.rect(2))*0.847);

% initialize
%Screen('TextSize',p.ptb.window,72);
%DrawFormattedText(p.ptb.window,rating_prompt,'center',150,255); % uncomment if not included in scale image
timing.initialized = Screen('Flip',p.ptb.window);
rating_onset = timing.initialized;

cursor.x = cursor.xcenter;
cursor.y = cursor.ycenter;
sample = 1;
SetMouse(cursor.xcenter,cursor.ycenter);
nextsample = GetSecs;

buttonPressed  = false;
%Limit the cursor moving within the semi-circle scale
rlim_max = 240; % this is the radius to the uppoer side of the scale
rlim_min = 180; % TODO: TEST TO CHECK WHAT THIS NUMBER SHOULD BE. THIS SHOULD BE THE RADIUS FROM THE INITIAL POINT OF THE CURSOR TO THE BEGINNING (BOTTOM PART) OF THE SCALE
xlim = cursor.xcenter;
ylim = cursor.ycenter;
while (GetSecs-rating_onset) <  duration
    
    loopstart = GetSecs;
    
    % sample at SAMPLERATE
    if loopstart >= nextsample
        ctime(sample) = loopstart; %#ok
        trajectory(sample,1) = cursor.x; %#ok
        trajectory(sample,2) = cursor.y;
        nextsample = nextsample+SAMPLERATE;
        sample = sample+1;
    end
    
    if ~any(buttonPressed) || (any(buttonPressed) && ((cursor.x-cursor.xcenter)^2 + (cursor.y-cursor.ycenter)^2) <= rlim_min^2) % the 2nd part here is to avoid presses outside the scale
        % measure mouse movement
        [x, y, buttonPressed] = GetMouse;
        
        % calculate displacement
        cursor.x = x * TRACKBALL_MULTIPLIER;
        cursor.y = y * TRACKBALL_MULTIPLIER;
        
        % Limit the cursor moving within the semi-circle scale
        [cursor.x, cursor.y, xlim, ylim] = limit(cursor.x, cursor.y, cursor.xcenter, cursor.ycenter, rlim_max, xlim, ylim);
        
        % produce screen
        Screen('CopyWindow',dspl.cscale.w,p.ptb.window);
        %DrawFormattedText(p.ptb.window,rating_prompt,'center',150,255); % uncomment if not included in scale image
        % add rating indicator ball
        Screen('FillOval',p.ptb.window,[255 1 1],[[cursor.x cursor.y]-cursor.size [cursor.x cursor.y]+cursor.size]);
        SetMouse(cursor.x,cursor.y);
        Screen('Flip',p.ptb.window);
        
    elseif any(buttonPressed)
        responseOnset = GetSecs;
        RT = responseOnset - timing.initialized;
        buttonPressed = [0 0 0];
        Screen('CopyWindow',dspl.cscale.w,p.ptb.window);
        %DrawFormattedText(p.ptb.window,rating_prompt,'center',150,255); % uncomment if not included in scale image
         %Draw a line to indicate rating angle after clicking button
        rating = drawline(cursor.x, cursor.y, cursor.xcenter, cursor.ycenter, p.ptb.window, rlim_max);
        Screen('Flip',p.ptb.window);
        
        while any(buttonPressed) % if already down, wait for release
           [~,~,buttonPressed] = GetMouse;
        end 
        
        Screen('FillOval',p.ptb.window,[255 0 255],[[cursor.x cursor.y]-cursor.size [cursor.x cursor.y]+cursor.size]);
        Screen('Flip',p.ptb.window);
        WaitSecs(0.500);
        if ~isinf(duration) % if duration = inf, the rating is self-paced and should end now since the participant responded
            remainder_time = duration-0.5-RT;
            Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
                p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
            Screen('Flip',p.ptb.window);
            WaitSecs(remainder_time);
        else
            HideCursor;
            break
        end
    end
    
end


end % end main function


%-------------------------------------------------------------------------------
%                            function Limit cursor
%-------------------------------------------------------------------------------
% Function by Xiaochun Han
function [x, y, xlim, ylim] = limit(x, y, xcenter, ycenter, r, xlim,ylim)
if (y<=ycenter) && (((x-xcenter)^2 + (y-ycenter)^2) <= r^2)
    xlim = x;
    ylim = y;
elseif (y<=ycenter) && (((x-xcenter)^2 + (y-ycenter)^2) > r^2)
    x = xlim;
    y = ylim;
elseif y>ycenter && (((x-xcenter)^2 + (y-ycenter)^2) <= r^2)
    xlim = x;
    y = ycenter;
elseif y>ycenter && (((x-xcenter)^2 + (y-ycenter)^2) > r^2)
    x = xlim;
    y = ycenter;
end
end

%-------------------------------------------------------------------------------
%        Draw a line to indicate rating angle after clicking button
%-------------------------------------------------------------------------------
% Function by Xiaochun Han

function angle = drawline(x, y, xcenter, ycenter, win, r)
if x >= xcenter
   angle = atan((ycenter-y)/(x-xcenter));
   yaim = ycenter - r*sin(angle);
   xaim = xcenter + r*cos(angle);
   yaim2 = ycenter - (r-50)*sin(angle);
   xaim2 = xcenter + (r-50)*cos(angle);
   angle = pi - angle;
else
   angle = atan((ycenter-y)/(xcenter-x));
   yaim = ycenter - r*sin(angle);
   xaim = xcenter - r*cos(angle);
   yaim2 = ycenter - (r-50)*sin(angle);
   xaim2 = xcenter - (r-50)*cos(angle);
end
angle = 180*angle/pi;
Screen('DrawLines', win, [xaim, xcenter; yaim, ycenter], 4, [255 1 1]);
Screen('DrawLines', win, [xaim2, xcenter; yaim2, ycenter], 5, [0 0 0]);
end


