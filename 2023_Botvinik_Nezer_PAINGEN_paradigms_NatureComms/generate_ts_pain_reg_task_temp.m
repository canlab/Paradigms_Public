function [ts, exp, post_q] = generate_ts_pain_reg_task

% [ts, exp] = generate_ts_mpa2_part1

exp.instructions = {'overall_expect', 'overall_int'};
rng('shuffle');

%% RUN 1-7
% trial_sequence{run_number}{trial_number} = ...
%          { type, intensity(four digits:string), duration(four digits:string),
%           repetition_number, rating_scale_type, cue_duration,
%           post-stim jitter, inter_stim_interval (from the rating to the 
%           next trial), cue_message, during_stim_message};
levels = {'up','neut','down','LV4','LV5'};  % 2 heat levels (47, 47.5)
stim = [1 1 1 2 2 2]; 
up = stim(randperm(6)); 
down = stim(randperm(6)); 
neut = stim(randperm(6));
reg = {'up','down','neut'};
blks = {up, down, neut}; 
task_idx = randperm(3);
blks = blks(task_idx);
reg{task_idx};
TPseq=cell2mat(blks)+3;
% idx = ones(1,18) + [6 6 6 6 6 6 6 6 6 7 7 7 7 7 7 7 7 7]; %enforce equal numbers of elem by permuting idx
%AU is a standin for a dummy trial (no stim) used for expectancy rating
S1{1} = [repmat([{'VI2'}; repmat({'TP'}, 6, 1)],3,1) ...  % 3 different pictures specified in main
    levels([ task_idx(1),TPseq(1:6),task_idx(2),TPseq(7:12),task_idx(3),TPseq(13:end)])' ...
    repmat( [{'0010'} ; repmat({'0013'},6,1)], 3, 1)];

%S1{2} = repmat({'overall_int'}, 32, 1);
S1{2} = repmat([{''}; repmat({'overall_int'}, 6, 1)],3,1);

% the timings below are all wrong, they need to be updated, but are
% currently not ready.

%randomize jitter order
dur1 = [10, 8]'; %[pre-expect fixation, post-expect fixation]
% dur1 = [0, 5, 13, 3]';
dur2 = [4, 6]; %[post-dummy stim fixation, expect rating; post-pain fixation, pain rating]
idx = {[1 2], [2 1]};
idx = cell2mat([idx(randperm(2)), ...
    idx(randperm(2)), ...
    idx(randperm(2)), ...
    idx(randperm(2)), ...
    idx(randperm(2))]);
idx = idx(1:18);
dur1 = mat2cell(int2str(dur1(idx)),ones(18,1),2);
dur2 = dur2(idx);
[x1 y1] = size(dur2);
dur2 = reshape(mat2cell(int2str(reshape(dur2,x1*y1,1)),ones(x1*y1,1),1),x1,y1);

% introduce timings for self regulation stimuli related fixations (we don't
% want any, so set them to 0
dur1 = {'0',dur1{1:6},'0',dur1{7:12},'0',dur1{13:18}};
dur2 = {'0',dur2{1:6},'0',dur2{7:12},'0',dur2{13:18}};

S1{3} = dur1'; %pre stimulus fixation
S1{4} = dur2';

trial_n = 18+3;
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
                for j = 1:trial_n
                    ts{i}{j}(4) = {temp(j)};
                end
            case 3
                for j = 1:trial_n
                    ts{i}{j}(5) = temp(j);
                end
            case 4
                for j = 1:trial_n
                    ts{i}{j}(6) = temp(j,1);
                    ts{i}{j}(7) = {'0'};
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