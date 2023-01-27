function [key_pressed, response_time] = WaitKeyPressMultiple(kIDs)
% this code wait for the user to press one of the keys in kIDs, and outputs
% the key that was pressed and the response time

onset = GetSecs;
while KbCheck(-3); end  % Wait until all keys are released.

while 1
    % Check the state of the keyboard.
    [ keyIsDown, ~, keyCode ] = KbCheck(-3);
    % If the user is pressing a key, then display its code number and name.
    if keyIsDown
        
        if any(keyCode(kIDs)) && sum(keyCode(kIDs)) == 1
            response_time = GetSecs - onset;
            key_pressed = find(keyCode);
            key_pressed = key_pressed(ismember(key_pressed, kIDs));
            break;
        end
        % make sure key's released
        while KbCheck(-3); end
    end
end
clear KbCheck;
end