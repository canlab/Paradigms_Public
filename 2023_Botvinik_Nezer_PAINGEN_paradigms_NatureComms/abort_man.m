function abort_man

% ABORT OPTIONS: MANUAL (by "q")
% function abort_man

global t r; % pressure device udp channel

try
    fclose(t); fclose(r);
catch
end

ShowCursor; %unhide mouse
Screen('CloseAll'); %relinquish screen control
psychrethrow(psychlasterror);
disp('Experiment aborted by escape sequence'); %present this text in command window

end