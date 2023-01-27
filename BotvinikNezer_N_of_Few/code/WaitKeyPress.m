function WaitKeyPress(kID)

while KbCheck(-3); end  % Wait until all keys are released.

while 1
    % Check the state of the keyboard.
    [ keyIsDown, ~, keyCode ] = KbCheck(-3);
    % If the user is pressing a key, then display its code number and name.
    if keyIsDown
        
        if keyCode(kID)
            break;
        end
        % make sure key's released
        while KbCheck(-3); end
    end
end
clear KbCheck;
end