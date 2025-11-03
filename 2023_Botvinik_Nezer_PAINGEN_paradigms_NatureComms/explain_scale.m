function explain_scale(exp_scale, rating_types)

% EXPLAIN SCALE
% explain_scale(exp_scale)

global theWindow W H; % window property
global white red orange bgcolor; % color
global t r; % pressure device udp channel
global window_rect prompt_ex lb rb scale_W anchor_y anchor_y2 anchor promptW promptH; % rating scale

prompt_ex = prompt_setup;

%% Getting widths for prompts
prompt_ex_W = cell(numel(prompt_ex),1);
for i = 1:numel(prompt_ex)
    prompt_ex_W{i} = Screen(theWindow, 'DrawText', prompt_ex{i},0,0); 
end

%% parse the inputs
for i = 1:numel(exp_scale.inst)
    
    % first: START page
    if i == 1
        while (1)
            Screen('DrawText',theWindow, prompt_ex{6},W/2-prompt_ex_W{6}/2, 100, white);
            Screen('DrawText',theWindow, prompt_ex{7},W/2-prompt_ex_W{7}/2, 200, white);
            Screen('DrawText',theWindow, prompt_ex{8},W/2-prompt_ex_W{8}/2, 300, white);
            Screen('Flip', theWindow);
            
            [~,~,button] = GetMouse(theWindow);
            [~,~,keyCode] = KbCheck;
            
            if button(1)
                pause(0.5);
                break
            elseif keyCode(KbName('q'))==1
                abort_man;
            end
        end
    end
    
    if strcmp(exp_scale.inst{i},'overall_expect')
        barcolor = [255,255,0];
        textcolor = 1;
    else
        barcolor = white;
        textcolor = white;
    end
    
    prompt_n = strcmp(rating_types.alltypes, exp_scale.inst{i});
    
    % EXPLAIN
    %{
    while (1) % space
        draw_scale(exp_scale.inst{i}); % draw scale
        Screen('DrawText',theWindow, prompt_ex{1},W/2-prompt_ex_W{1}/2,100,orange);
        Screen('DrawText',theWindow, rating_types.prompts{prompt_n}, W/2-promptW{prompt_n}/2,H/2-promptH/2-150,textcolor);
        Screen('Flip', theWindow);
        
        [~,~,button] = GetMouse(theWindow);
        [~,~,keyCode] = KbCheck;
        %if keyCode(KbName('space'))==1
        if button(1)
            pause(0.5);
            break
        elseif keyCode(KbName('q'))==1
            abort_man;
        end
    end
    %}
    
    % PRACTICE
    % Screen(theWindow,'FillRect',bgcolor, window_rect);
    % Screen('Flip', theWindow);
    SetMouse(lb,H/2); % set mouse at the left
    while (1) % button
        
        [x,~,button] = GetMouse(theWindow);
        if x < lb
            x = lb;
        elseif x > rb
            x = rb;
        end
        
        draw_scale(exp_scale.inst{i}); % draw scale

        Screen('DrawText',theWindow, prompt_ex{1},W/2-prompt_ex_W{1}/2,50,orange);
        if strcmp(exp_scale.inst{i},'overall_expect')
            Screen('DrawText',theWindow, prompt_ex{3},W/2-prompt_ex_W{3}/2,100,orange);
        elseif strcmp(exp_scale.inst{i},'overall_int')
            Screen('DrawText',theWindow, prompt_ex{4},W/2-prompt_ex_W{4}/2,100,orange);
        end
        Screen('DrawText',theWindow, prompt_ex{2},W/2-prompt_ex_W{2}/2,150,orange);
            
        Screen('DrawText',theWindow, rating_types.prompts{prompt_n}, W/2-promptW{prompt_n}/2,H/2-promptH/2-150,white);
        if strncmp(exp_scale.inst{i}, 'cont_', 5)
            %Screen('DrawLine', theWindow, white, x, H/2, x, H/2+scale_W, 6);
            xy = [lb H/2; lb H/2+scale_W ; x H/2+scale_W; x H/2];
            Screen('FillPoly', theWindow, barcolor, xy, 1);
        else
            %Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
            xy = [lb H/2; lb H/2+scale_W ; x H/2+scale_W; x H/2];
            Screen('FillPoly', theWindow, barcolor, xy, 1);
        end
        Screen('Flip', theWindow);
        
        if button(1), break, end
    end
    
    % freeze the screen 1 second with red line
    draw_scale(exp_scale.inst{i}); % draw scale

    Screen('DrawText',theWindow, prompt_ex{1},W/2-prompt_ex_W{1}/2,50,orange);
    if strcmp(exp_scale.inst{i},'overall_expect')
        Screen('DrawText',theWindow, prompt_ex{3},W/2-prompt_ex_W{3}/2,100,orange);
    elseif strcmp(exp_scale.inst{i},'overall_int')
        Screen('DrawText',theWindow, prompt_ex{4},W/2-prompt_ex_W{4}/2,100,orange);
    end
    Screen('DrawText',theWindow, prompt_ex{2},W/2-prompt_ex_W{2}/2,150,orange);
    Screen('DrawText',theWindow, rating_types.prompts{prompt_n}, W/2-promptW{prompt_n}/2,H/2-promptH/2-150,white);
    
    %Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
    xy = [lb H/2; lb H/2+scale_W ; x H/2+scale_W; x H/2];
    Screen('FillPoly', theWindow, red, xy, 1);
    
    Screen('Flip', theWindow);
    WaitSecs(1);
    
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    
    % Move to next
    if i < numel(exp_scale.inst)
        while (1) % space
            Screen('DrawText',theWindow, prompt_ex{5},W/2-prompt_ex_W{5}/2,100,orange);
            if strncmp(exp_scale.inst{2}, 'cont_', 5)
                Screen('DrawText',theWindow, prompt_ex{9},W/2-prompt_ex_W{9}/2,200,orange);
                Screen('DrawText',theWindow, prompt_ex{10},W/2-prompt_ex_W{10}/2,250,orange);
            end
            Screen('Flip', theWindow);
            
            [~,~,button] = GetMouse(theWindow);
            [~,~,keyCode] = KbCheck;
            
            if button(1)
                pause(0.5);
                break
            elseif keyCode(KbName('q'))==1
                abort_man;
            end
        end
    else
        while (1)
            Screen('DrawText',theWindow, prompt_ex{11},W/2-prompt_ex_W{11}/2,100,orange);
            Screen('DrawText',theWindow, prompt_ex{12},W/2-prompt_ex_W{12}/2,150,orange);
            
            if strncmp(exp_scale.inst{i}, 'cont_', 5)
                Screen('DrawText',theWindow, prompt_ex{9},W/2-prompt_ex_W{9}/2,300,orange);
                Screen('DrawText',theWindow, prompt_ex{10},W/2-prompt_ex_W{10}/2,350,orange);
            end
            
            Screen('Flip', theWindow);
            
            [~,~,button] = GetMouse(theWindow);
            [~,~,keyCode] = KbCheck;
            
            if button(1)
                pause(0.5);
                break
            elseif keyCode(KbName('q'))==1
                abort_man;
            end
        end
    end
end

end


function prompt_ex = prompt_setup

% prompt = prompt_setup

%% Instructions
prompt_ex{1} = 'Take as long as you need to practice but rating periods will be limited to 5 seconds during experiment.';
prompt_ex{2} = 'Practice moving the rating bar. Click to submit rating, and notice how the bar turns RED.';
prompt_ex{3} = 'Expectations are rated using a YELLOW bar, and will normally be FOLLOWED by a stimulus (skipped here).';
prompt_ex{4} = 'Pain is rated using a WHITE bar, and will normally be PRECEDED by a stimulus (skipped here).';
prompt_ex{5} = 'Great job! If you are ready for the next step, please press a button.';

%% some additional instructions
prompt_ex{6} = 'Please practice using the track ball to control the rating scales. No stimuli will be delivered yet.';
prompt_ex{7} = 'When you are ready, press mouse button to begin practice.';
prompt_ex{8} = 'Remember not to move your head, and read instructions fully.';
prompt_ex{9} = 'Note that during the actual experiment, you don''t need to';
prompt_ex{10} = 'press a button for the continuous rating.';
prompt_ex{11} = 'Great! We''re done with the practice. The actual experiment will begin shortly.';
prompt_ex{12} = 'If you are ready for the next part, please press a button.';

end
