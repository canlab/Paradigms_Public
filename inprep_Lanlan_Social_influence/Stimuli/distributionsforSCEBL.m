

% Distribution of pain ratings for SCEBL/BMRK5 experiment

%% Normal distribution

close all

normdist = ProbDistUnivParam('normal', [0.2 0.05])
normratings = random(normdist, 10,1)

figure1 = figure('Color',[0 0 0]);
axes1 = axes('Parent',figure1,...
    'Color',[0 0 0]);
hold(axes1,'all');



line([0,1], [0 0], 'Color', 'w', 'LineWidth', 2); hold on;
plot(normratings, 1, '.', 'MarkerSize', 10, 'Color',[0 0 0]); hold on;
errorbar(normratings, zeros(10,1), (ones(10,1)), 'w', 'LineWidth', 2); hold on;

xlim([0 1])
ylim([-0.5 0.5])

box off




% %% extreme value distribution
% 
% evdist = ProbDistUnivParam('ev', [0.7 0.05])
% evratings = random(evdist, 20,1)
% 
% figure2 = figure('Color',[1 1 1]);
% plot(evratings, 1, 'o', 'MarkerSize', 10)
% xlim([0 1])
