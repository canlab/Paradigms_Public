function [ts, exp, post_q] = generate_ts_pressure

% [ts, exp] = generate_ts_mpa2_part1

exp.instructions = {'overall_avoidance', 'cont_avoidance'};
rng('shuffle');

%% RUN 1-7
% trial_sequence{run_number}{trial_number} = ...
%          { type, intensity(four digits:string), duration(four digits:string),
%           repetition_number, rating_scale_type, cue_duration,
%           post-stim jitter, inter_stim_interval (from the rating to the 
%           next trial), cue_message, during_stim_message};
levels = {'LV0' 'LV1' 'LV2'};
idx = [1 1 1 1 2 2 2 2]; %enforce equal numbers of elem by permuting idx
%AU is a standin for a dummy trial (no stim) used for expectancy rating
S1{1} = [reshape(repmat({ 'PP'; 'PP'}, 8, 1), 16, 1) ...
    levels( ...
        reshape( ...
            [ones(1,8); ...
            idx(randperm(8)) + ...
                ones(1,8)], ...
            16,1) ...
        )' ...
    repmat({'0000'; '0010'},8,1)];
%S1{2} = repmat({'overall_int'}, 32, 1);
S1{2} = repmat({'overall_expect'; 'overall_avoidance'}, 8, 1);

% randomize jitter order
dur1 = [13, 5, ...
        13, 3]'; %[pre-expect fixation, post-expect fixation]
dur2 = [0 7; 3 7; ...
        0 7; 5 7]; %[post-dummy stim fixation, expect rating; post-pain fixation, pain rating]
idx = {[1 2 3 4], [1 4 3 2]};
idx = cell2mat([idx(randperm(2)), idx(randperm(2))]);
dur1 = mat2cell(int2str(dur1(idx)),ones(16,1),2);
dur2 = dur2(idx,:);
[x1 y1] = size(dur2);
dur2 = reshape(mat2cell(int2str(reshape(dur2,x1*y1,1)),ones(x1*y1,1),1),x1,y1);

S1{3} = dur1; %pre stimulus fixation
S1{4} = dur2;

trial_n = 16;
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
                    ts{i}{j}(7) = temp(j,2);
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

% %% RUN 5-8
% S2{1} = repmat({'PP'}, 12, 1);
% S2{2} = repmat({'LV3', 'overall_int', 'HOW MUCH PRESSURE?';
%     'LV4', 'overall_int', 'HOW MUCH PRESSURE?';
%     'LV3', 'overall_avoidance', 'HOW BAD?';
%     'LV4', 'overall_avoidance', 'HOW BAD?';
%     'LV3', 'none', 'NO RATING';
%     'LV4', 'none', 'NO RATING'}, 2, 1); %2, 4, 8
% S2{3} = repmat({'0010'}, 12, 1);
% S2{4} = repmat({'2'; '3.5'; '5'}, 4, 1);
% S2{5} = repmat({'3', '11'; '5', '9'; '7', '7'}, 4, 1);
% 
% trial_n = 12;
% 
% for k = 1:numel(S2)
%     for i = 5:8
%         temp = S2{k}(randperm(trial_n),:);
%         switch k
%             case 1
%                 for j = 1:trial_n
%                     ts{i}{j}(1) = temp(j);
%                 end
%             case 2
%                 for j = 1:trial_n
%                     ts{i}{j}(2) = temp(j,1);
%                     ts{i}{j}(4) = {temp(j,2)};
%                     ts{i}{j}(8) = temp(j,3);
%                 end
%             case 3
%                 for j = 1:trial_n
%                     ts{i}{j}(3) = temp(j);
%                 end
%             case 4
%                 for j = 1:trial_n
%                     ts{i}{j}(5) = temp(j);
%                 end
%             case 5
%                 for j = 1:trial_n
%                     ts{i}{j}(6) = temp(j,1);
%                     ts{i}{j}(7) = temp(j,2);
%                 end
%         end
%     end
% end
% 
% for i = 5:8
%     for j = 1:12
%         if strcmp(ts{i}{j}{8}, 'NO RATING')
%             ts{i}{j}{7} = '0';
%         end
%     end
% end

end