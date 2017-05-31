function [Window, Rect] = initializeScreen

screenNumber = 0; % 0 = main display
                           
[Window, Rect] = Screen('OpenWindow',screenNumber); % open the window

% Set fonts
%Screen('TextFont',Window,'Times');
Screen('TextSize',Window,48);
Screen('FillRect', Window, 0);  % 0 = black background

HideCursor; % Remember to type ShowCursor later

