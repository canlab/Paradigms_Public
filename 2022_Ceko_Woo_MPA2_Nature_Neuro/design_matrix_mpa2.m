function [X, r, vifs, XX] = design_matrix_mpa2(ts, doplot)

% addpath('design_testing');

[~, TRn] = TRn_calculation_mpa2(ts);
TR = .460;

% [X, r, vifs, XX] = design_matrix_mpa2(ts, doplot)
% 
% example:
% ts = generate_ts_mpa2_part1;
% [X, vifs] = design_matrix_mpa2(ts, 1);

% rating_dur = random between 2 and 7
rating_dur = randi(10000,1,100000);
rating_dur = rating_dur(rating_dur>2000 & rating_dur<=7000);
% clear onsets_*;
k = 0;
for i = 1:numel(ts) % run
    for j = 1:numel(ts{i}) % trial
        
        if j == 1
            ons = 2; % disdaq 17 images (= 8 seconds)
        end
        
        % CUE (actually we have no cues)
        if str2double(ts{i}{j}{5}) ~= 0 % cue
            onsets_cue{i}(j,1) = ons;
            ons = ons + str2double(ts{i}{j}{5});
            onsets_cue_dur{i}(j,1) = str2double(ts{i}{j}{5});
        end
        
        % STIM
        if strcmp(ts{i}{j}{1}, 'PP')
            onsets_stim.PP{i}(j,1) = ons;
            pmod_stim.PP{i}(j,1) = str2num(ts{i}{j}{3});
            ons = ons + 6 + str2double(ts{i}{j}{6}); % jitter1
        elseif strcmp(ts{i}{j}{1}, 'AU')
            onsets_stim.AU{i}(j,1) = ons;
            pmod_stim.AU{i}(j,1) = str2num(ts{i}{j}{3});
            ons = ons + 6 + str2double(ts{i}{j}{6}); % jitter1
        elseif strcmp(ts{i}{j}{1}, 'TP')
            onsets_stim.TP{i}(j,1) = ons;
            pmod_stim.TP{i}(j,1) = str2num(ts{i}{j}{3});
            ons = ons + 10 + str2double(ts{i}{j}{6}); % jitter1
        elseif strcmp(ts{i}{j}{1}, 'VI') 
            onsets_stim.VI{i}(j,1) = ons;
            pmod_stim.VI{i}(j,1) = str2num(ts{i}{j}{3});
            ons = ons + 6 + str2double(ts{i}{j}{6}); % jitter1
        end
        
        onsets_rating{i}(j,1) = ons;
        k = k + 1;
        ons = ons + str2double(ts{i}{j}{7}); % jitter2
        onsets_rating_dur{i}(j,1) = rating_dur(k)/1000;
        
    end
end

f = fields(onsets_stim);
for i = 1:numel(f)
    eval(['temp = onsets_stim.' f{i} ';']);
    for j = 1:numel(temp)
        temp{j}(temp{j}==0) = [];
    end
    eval(['onsets_stim.' f{i} '= temp;']);
end

f = fields(pmod_stim);
for i = 1:numel(f)
    eval(['temp = pmod_stim.' f{i} ';']);
    for j = 1:numel(temp)
        temp{j}(temp{j}==0) = [];
    end
    eval(['pmod_stim.' f{i} '= temp;']);
end

for i = 1:numel(onsets_rating)
    onsets_rating{i}(onsets_rating{i}==0) = [];
    onsets_rating_dur{i}(onsets_rating_dur{i}==0) = [];
end

for i = 1:numel(ts)
    X{i} = onsets2fmridesign_wani({[onsets_stim.PP{i} repmat(6,size(onsets_stim.PP{i}))] ...
        [onsets_stim.AU{i} repmat(6,size(onsets_stim.AU{i}))] ...
        [onsets_stim.VI{i} repmat(6,size(onsets_stim.VI{i}))] ...
        [onsets_stim.TP{i} repmat(10,size(onsets_stim.TP{i}))] ...
        [onsets_rating{i} onsets_rating_dur{i}]}, TR, (TRn-17).*TR, spm_hrf(1), []);
    r{i} = corr(X{i}(:,1:5));
end

XX = blkdiag(X{:});
XX = XX(:,[find(~any(XX==1)) find(any(XX==1))]);
%vifs = getvif(XX, 0);
%vifs = vifs(:,1:sum(~any(XX==1)));

if doplot
    % my version, but Tor's is much better
    %     figure('color', 'w');
    %     subplot(1,2,1);
    %     imagesc(XX);
    %     colormap gray;
    %     colorbar;
    %     title('design matrix', 'fontsize', 20);
    %     xlabel('regressors', 'fontsize', 20);
    %     ylabel('TRs', 'fontsize', 20);
    %
    %     subplot(1,2,2);
    %     plot(vifs, '-o');
    %     title('vifs', 'fontsize', 20);
    %     xlabel('regressors', 'fontsize', 20);
    %     ylabel('vifs', 'fontsize', 20);
    
    create_figure('VIFs', 1, 3);
    subplot(1, 3, 1);
    imagesc(zscore(XX)); 
    set(gca, 'YDir', 'Reverse');
    colormap gray
    title('Full Design Matrix (zscored)');
    axis tight
    drawnow
    
    wh_cols = 1:35;
    
    subplot(1, 3, 2)
    imagesc(zscore(XX(:,wh_cols))); 
    set(gca, 'YDir', 'Reverse');
    colormap gray
    title('Design Matrix: Of-interest (zscored)');
    axis tight
    drawnow
    
    vifs = getvif(XX(:, wh_cols));
    
    subplot(1, 3, 3);
    plot(vifs, 'ko', 'MarkerFaceColor', [1 .5 0]);
    ylabel('Variance inflation factor'); 
    xlabel('Predictor number');
    plot_horizontal_line(1, 'k');
    plot_horizontal_line(2, 'b--');
    plot_horizontal_line(4, 'r--');
    plot_horizontal_line(8, 'r-');
    title('VIFs for ONLY of-interest regs');
end

end