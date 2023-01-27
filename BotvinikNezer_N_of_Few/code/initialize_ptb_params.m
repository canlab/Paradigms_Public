function p = initialize_ptb_params(debugging_mode)
% This function initialize the parameters for psychtoolbox
% code by Rotem Botvinik-Nezer
% based on codes by Heejung Jung and Xiaochun Han
% Last updated January 2021
% Input:
% running_mode: should be 'debugging' for debugging mode (smaller screen).
% Otherwise, leave empty.

%% ------------------------ Psychtoolbox parameters -----------------------
% we want to skip tests and reduce verbosity of psychtoolbox during the
% experiment (but not during debugging mode)
if ~debugging_mode
    verbosity_new_level = 1; % a number between o (disable all output) to 4 (VERY verbose)
    % levels information is taken from here: https://github.com/Psychtoolbox-3/Psychtoolbox-3/wiki/FAQ%3A-Control-Verbosity-and-Debugging
    % 0 - Disable all output - Same as using the SuppressAllWarnings flag.
    % 1 - Only output critical errors.
    % 2 - Output warnings as well.
    % 3 - Output startup information and a bit of additional information. This is the default.
    % 4 - Be pretty verbose about information and hints to optimize your code and system.
    % 5 - Levels 5 and higher enable very verbose debugging output, mostly useful for debugging PTB itself, not generally useful for end-users.
    verbosity_old_level = Screen('Preference', 'Verbosity', verbosity_new_level);
    %%%Screen('Preference', 'SkipSyncTests', 1);
end
PsychDefaultSetup(2);
screens                                    = Screen('Screens'); % Get the screen numbers
p.ptb.screenNumber                         = max(screens); % Draw to the external screen if avaliable
p.ptb.white                                = WhiteIndex(p.ptb.screenNumber); % Define black and white
p.ptb.black                                = BlackIndex(p.ptb.screenNumber);
if debugging_mode
    PsychDebugWindowConfiguration;
    Screen('Preference', 'SkipSyncTests', 0);
    %[width, height]=Screen('WindowSize', p.ptb.screenNumber);
    %[p.ptb.window, p.ptb.rect] = PsychImaging('OpenWindow', p.ptb.screenNumber, p.ptb.black, [0, 0, width/2, height/2]);
%else
  %[p.ptb.window, p.ptb.rect]                 = PsychImaging('OpenWindow', p.ptb.screenNumber, p.ptb.black);  
end
[p.ptb.window, p.ptb.rect]                 = PsychImaging('OpenWindow', p.ptb.screenNumber, p.ptb.black);
[p.ptb.screenXpixels, p.ptb.screenYpixels] = Screen('WindowSize', p.ptb.window);
p.ptb.ifi                                  = Screen('GetFlipInterval', p.ptb.window);
Screen('BlendFunction', p.ptb.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines
Screen('TextFont', p.ptb.window, 'Arial');
Screen('TextSize', p.ptb.window, 36);
[p.ptb.xCenter, p.ptb.yCenter] = RectCenter(p.ptb.rect);
p.fix.sizePix                  = 20; % size of the arms of our fixation cross
p.fix.lineWidthPix             = 4; % Set the line width for our fixation cross
% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
p.fix.xCoords                  = [-p.fix.sizePix p.fix.sizePix 0 0];
p.fix.yCoords                  = [0 0 -p.fix.sizePix p.fix.sizePix];
p.fix.allCoords                = [p.fix.xCoords; p.fix.yCoords];

%% ------------------------- Keyboard information -------------------------
KbName('UnifyKeyNames');
p.keys.confirm                 = KbName('return');
p.keys.space                   = KbName('space');
p.keys.esc                     = KbName('ESCAPE');
p.keys.start                   = KbName('s');
p.keys.end                     = KbName('e');
p.keys.yes                     = KbName('y');
p.keys.no                      = KbName('n');
p.keys.right                   = KbName('p');
p.keys.left                    = KbName('q');
p.keys.continue                = KbName('c');

if ~debugging_mode
    % return to previous level of verbosity
    Screen('Preference', 'Verbosity', verbosity_old_level);
end

end % end function