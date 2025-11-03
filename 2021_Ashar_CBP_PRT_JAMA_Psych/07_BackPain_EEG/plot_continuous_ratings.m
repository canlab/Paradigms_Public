% plot the continuous ratings collected at elig session
% pass in the full path to a file to plot a particular subj
% or pass in no arguments to plot all Ss found in the expected data dir
function plot_continuous_ratings(varargin)

% which computer am i on?
if ismac
    [~, hostname] = system('scutil --get ComputerName');
else
    [~, hostname] = system('hostname');
    hostname = deblank(hostname);
end

% if no params passed in, find all files and plot them all
if nargin == 0
    if strcmp(hostname, 'CANLab_Station1')
        repodir = 'C:\OLP4CBP';
    else
        repodir = '/Users/yoni/Repositories/OLP4CBP';
    end
    
    basedir = fullfile(repodir, 'MATLAB', '07_BackPain_EEG', 'data');
    fnames = filenames(fullfile(basedir, '*mat'), 'char');
    fnames = fnames(10:15, :); %random sample of 5 Ss
else
    fnames = varargin{1};
end

for i=1:size(fnames, 1)
    
    load(fnames(i,:));
    [~,sub] = fileparts(fnames(i,:));
    sub = sub(1:8);

    % set up the figure.  create_figure doesn't work well on 208 computer
    f1 = figure; subplot(1,3,1);
    set(f1, 'Tag', sub, 'Name', sub) 
    title(sub)
    hold on

    % avg pain rating for each trial by stim level
    scatter(participant.data.stimlevel, nanmean(participant.data.vasrate')); lsline
    set(gca, 'XTick', 1:4);
    xlabel('stim'); ylabel('avg pain for trial')
  
    % plot it all along one axis in time
    subplot(1,3,2)
    
    dat = participant.data.vasrate';
  %  dat = interp1(dat, 1:10:length(dat)); % downsample by a factor of 10
    
    ntrials = 20;
    a = [];
    for j=1:ntrials
        a = [a; dat(~isnan(dat(:, j)), j)];
    end
    
    plot(a); hold on
    
    % plot stimuluation
    dat2 = repmat(participant.data.stimlevel(1:ntrials)', 1, round(length(a) / ntrials));
    b = reshape(dat2', 1,[]);
    plot( (b-1) * 25) % for scaling to be roughly matched
    
    set(gca, 'XTick', []); xlabel('time')
    
    % continuous ratings
    subplot(1,3,3), hold on
    cm = gray;
    plot(dat(:, participant.data.stimlevel==1), 'color', cm(40,:))
    plot(dat(:, participant.data.stimlevel==2), 'color', cm(30,:))
    plot(dat(:, participant.data.stimlevel==3), 'color', cm(20,:))
    plot(dat(:, participant.data.stimlevel==4), 'color', cm(1,:))
    title('darker is higher inflation level')
    %legend({'1' '2' '3' '4'})
    
    set(gcf, 'Position', [104         294        1105         480])
end
