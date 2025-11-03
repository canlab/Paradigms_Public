% This script was provided to Bogdan for use with the Placebo Genetics
% study by Leonie Koban on 7/17/2018

% Distribution of pain ratings for SCEBL/BMRK5 experiment

% #2: with larger variance in ratings to increase credibility Oct 2013


%% Normal distribution

clear all;

% mkdir('SocialCueLow_gray')
% cd SocialCueLow_gray
% m = 0.30    % provide mean
% s = 0.15    % provide stdev

mkdir('SocialCueLV7_gray')
cd SocialCueLV7_gray
m = 0.8    % provide mean
s = 0.15    % provide stdev


set(0, 'defaultFigurePosition', [300 400 400 120], 'defaultFigureColor' , [.5 .5 .5], ...
    'defaultLineColor', [1 1 1])
set(0, 'DefaultFigureInvertHardcopy', 'off')

normdist = ProbDistUnivParam('normal', [m s]);  % creates normaldistribution with mean m and stdev s

fid = fopen('stimulilv7.txt','w');   % opens textfile to write stimulus parameters
fprintf(fid, '%s %d %s %d \n', 'mean = ', m, 'stdev = ', s)
fprintf(fid, '%s \t %s \t %s \t %s \t %s \t %s \t \n', 'Stimulusfile', 'Mean', 'StDev','Min', 'Max',  'IndivRatings') 


for f = 1:50   % creates and saves 50 figures as bmp

    close all
    
    stim(f).ratings = random(normdist, 10,1);  % draws 10 values from normal distribution as defined above
    while (min(stim(f).ratings) < 0 | max(stim(f).ratings) > 1)   % if outside of bounds [0 1] repeat until sample found
        stim(f).ratings = random(normdist, 10,1);
    end
    
    stim(f).ratingsmean = mean(stim(f).ratings);
    stim(f).ratingsstdev = std(stim(f).ratings);
    stim(f).min = min(stim(f).ratings);
    stim(f).max = max(stim(f).ratings);

    % draws figure
    figure1 = figure('Color',[.5 .5 .5], 'Position', [300 400 600 150]);
    axes1 = axes('Parent', figure1, 'Position', [0.025 0.025 0.95 0.95], ...
                 'Color', [.5 .5 .5], 'YColor', [.5 .5 .5],...
                 'XColor', [.5 .5 .5]);
    hold(axes1, 'all');

    line([0,1], [0 0], 'Color', 'w', 'LineWidth', 2); hold on;
    plot(stim(f).ratings, 1, '.', 'MarkerSize', 10, 'Color',[.5 .5 .5]); hold on;
    errorbar(stim(f).ratings, zeros(10,1), (ones(10,1)), 'w', 'LineWidth', 2); hold on;

    xlim([0 1])
    ylim([-0.5 0.5])
    box off
    
    % stuff for filename that includes m and s
    ms = num2str(stim(f).ratingsmean);
    ss = num2str(stim(f).ratingsstdev);
    stim(f).filename = ([num2str(f), '_M', ms(:,3:5), '_STD', ss(:, 3:5), '.bmp']);
      
    fprintf(fid, '%s \t %s \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t \n', stim(f).filename, stim(f).ratingsmean, stim(f).ratingsstdev, stim(f).min, stim(f).max, stim(f).ratings');
  
    set(gcf,'Units','pixels','Position',[200 200 600 150]);  %# Modify figure size

    frame = getframe(gcf);                   %# Capture the current window
    imwrite(frame.cdata, stim(f).filename);  %# Save the frame data
    
    
end  

fclose(fid);

save('stimulilv7', 'stim')  % saves the parameter structure as mat file