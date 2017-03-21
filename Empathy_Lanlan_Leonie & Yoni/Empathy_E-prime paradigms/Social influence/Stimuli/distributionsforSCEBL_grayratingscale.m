% Distribution of pain ratings for SCEBL/BMRK5 experiment

% here: just gray rating scale same size as conformity stimuli


%% Normal distribution


cd ('C:\Users\canlab\Documents\My Experiments\LEONIE_JAKE_SCEBL\fMRI_version\Learning\Stimuli\')


set(0, 'defaultFigurePosition', [300 400 400 120], 'defaultFigureColor' , [.5 .5 .5], ...
    'defaultLineColor', [1 1 1])
set(0, 'DefaultFigureInvertHardcopy', 'off')

close all
    
% draws figure
figure1 = figure('Color',[.5 .5 .5], 'Position', [300 400 600 150]);
axes1 = axes('Parent', figure1, 'Position', [0.025 0.025 0.95 0.95], ...
             'Color', [.5 .5 .5], 'YColor', [.5 .5 .5],...
             'XColor', [.5 .5 .5]);
hold(axes1, 'all');

line([0,1], [0 0], 'Color', 'w', 'LineWidth', 3); hold on;

xlim([0 1])
ylim([-0.5 0.5])
box off

set(gcf,'Units','pixels','Position',[200 200 600 150]);  %# Modify figure size

frame = getframe(gcf);                   %# Capture the current window
imwrite(frame.cdata, 'grayratingscale.bmp');  %# Save the frame data




