function [ts, exp, post_q] = generate_ts_pain_cond_prodicaine

% [ts, exp] = generate_ts_mpa2_part1

exp.instructions = {'overall_expect', 'overall_int'};
rng('shuffle');

%% RUN 1-7
% trial_sequence{run_number}{trial_number} = ...
%          { type, intensity(four digits:string), duration(four digits:string),
%           repetition_number, rating_scale_type, cue_duration,
%           post-stim jitter, inter_stim_interval (from the rating to the 
%           next trial), cue_message, during_stim_message};
levels = {'LV0', 'LV1', 'LV2', 'LV3', 'LV4', 'LV5', 'LV6', 'LV7'};
n_stim = 8;
idx = ones(1,n_stim) + [1 1 1 1 2 2 2 2]; %enforce equal numbers of elem by permuting idx
%AU is a standin for a dummy trial (no stim) used for expectancy rating
S1{1} = [reshape(repmat({ 'WA'; 'TP'}, n_stim, 1), n_stim*2, 1) ...
    levels( ...
        reshape( ...
            [ones(1,n_stim); ...
            idx(randperm(n_stim))], ...
            n_stim*2,1) ...
        )' ...
    repmat({'0001'; '0012'},n_stim,1)];
%S1{2} = repmat({''; 'overall_int'}, 6, 1);
S1{2} = repmat({'', ''; 'overall_int', 'overall_unpleasant'}, n_stim, 1);

% pre-warning fixation
dur1a = [4,2]';
dur1a = mat2cell(int2str(repmat(dur1a,n_stim/length(dur1a),1)),ones(n_stim,1),1);

% pre-stim fixation
dur1b = [3,1]';
dur1b = mat2cell(int2str(repmat(dur1b,n_stim/length(dur1b),1)),ones(n_stim,1),1);

dur2a = [0 0]'; %post-warning fixation, this is redundant with dur1b, so zero it
dur2a = repmat(dur2a,n_stim/length(dur2a),1);
[x1 y1] = size(dur2a);
dur2a = reshape(mat2cell(num2str(reshape(dur2a,x1*y1,1)),ones(x1*y1,1),1),x1,y1);

dur2b = [6 2]'; %post-stim fixation
dur2b = repmat(dur2b,n_stim/length(dur2b),1);
[x1 y1] = size(dur2b);
dur2b = reshape(mat2cell(num2str(reshape(dur2b,x1*y1,1)),ones(x1*y1,1),1),x1,y1);

dur3 = [0 11]'; % stim rating durations (zero for warning "stim")
dur3 = repmat(dur3,n_stim,1);
[x1 y1] = size(dur3);
dur3 = reshape(mat2cell(num2str(reshape(dur3,x1*y1,1)),ones(x1*y1,1),2),x1,y1);

rand_idx = randperm(n_stim);
dur1a = dur1a(rand_idx);
dur1b = dur1b(rand_idx);
dur2a = dur2a(rand_idx);
dur2b = dur2b(rand_idx);

dur1 = [dur1a(:),dur1b(:)]';
S1{3} = dur1(:); %pre stimulus fixation
dur2b = [dur2a(:), dur2b(:)]';
S1{4} = dur2b(:);

S1{5} = dur3(:);

trial_n = n_stim*2;
run_n = 1;

for k = 1:numel(S1)
    for i = run_n
        temp = S1{k}(1:trial_n,:);
        switch k
            case 1
                for j = 1:trial_n
                    ts{i}{j}(1) = temp(j,1);
                    ts{i}{j}(2) = temp(j,2);
                    ts{i}{j}(3) = temp(j,3);
                end
            case 2
                % randomize order of rating prompts
                prompt_order = [repmat([1,2],ceil(trial_n/2),1); ...
                    repmat([2,1],ceil(trial_n/2),1)];
                prompt_order = prompt_order(randperm(size(prompt_order,1)),:);
                
                for j = 1:trial_n
                    ts{i}{j}(4) = {temp(j,prompt_order(j,:))};
                end
            case 3
                for j = 1:trial_n
                    ts{i}{j}(5) = temp(j);
                end
            case 4
                for j = 1:trial_n
                    ts{i}{j}(6) = temp(j);
                end
            case 5
                for j = 1:trial_n
                    ts{i}{j}(7) = temp(j);
                end
        end
    end
end


post_intunp_battery = {};

for i = run_n
    
    rand_post_intunp_battery = post_intunp_battery(randperm(numel(post_intunp_battery)));
    for j = 1:numel(rand_post_intunp_battery)
        rand_post_intunp_battery{j} = rand_post_intunp_battery{j}(randperm(numel(post_intunp_battery{j})));
    end
    
    if i == 1 || i == 3 || i == 6
        post_q{i} = {};
        for j = 1:numel(rand_post_intunp_battery)
            post_q{i} = [post_q{i} rand_post_intunp_battery{j}];
        end

    else
        post_q{i} = {};
    end
end

end