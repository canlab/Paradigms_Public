function ts = generate_ts_mpa2_continuous

% [ts, exp] = generate_ts_mpa1

rng('shuffle');

%% RUN 1-7
S1{1} = [reshape(repmat({'TP' 'PP' 'AU' 'VI', 'VI2'}, 4, 1), 20, 1) repmat({'LV1'; 'LV2'; 'LV3'; 'LV4'}, 5, 1) [repmat({'0010'},4,1); repmat({'0006'},16,1)]];
S1{2} = repmat({'cont_avoidance', 'overall_aversive_ornot'}, 20, 1);
S1{3} = repmat({'0'}, 20, 1);
S1{4} = repmat({'3', '7'}, 20, 1);

trial_n = 20;
run_n = 1;

for k = 1:numel(S1)
    for i = run_n
        temp = S1{k}(randperm(trial_n),:);
        switch k
            case 1
                for j = 1:trial_n
                    ts{i}{j}(1) = temp(j,1);
                    ts{i}{j}(2) = temp(j,2);
                    ts{i}{j}(3) = temp(j,3);
                end
            case 3
                for j = 1:trial_n
                    ts{i}{j}(5) = temp(j);
                end
            case 2
                for j = 1:trial_n
                    ts{i}{j}(4) = {temp(j,:)};
                end
            case 4
                for j = 1:trial_n
                    ts{i}{j}(6) = temp(j,1);
                    ts{i}{j}(7) = temp(j,2);
                end
        end
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