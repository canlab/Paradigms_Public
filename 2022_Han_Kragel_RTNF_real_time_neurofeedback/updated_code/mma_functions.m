function [W] = mkFixationScreen()
    W = Screen('OpenOffscreenWindow',0);
    Screen('FillRect',W,0);
    Screen('TextSize',W,72);
    DrawFormattedText(W,'+','center','center',255);
end