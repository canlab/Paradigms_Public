function abort_error

% ABORT OPTIONS: ERROR
% function abort_error

global t r; % pressure device udp channel

try
    fclose(t); fclose(r);
catch
end

ShowCursor; %unhide mouse
Screen('CloseAll'); %relinquish screen control
disp('Experiment aborted by error') %present this text in command window

end