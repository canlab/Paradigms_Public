clear;
rng('shuffle');

ST    = {'AU' 'TP'}; %stim types
S    = [1 2]; % stim levels
C    = [1 2]; % cue levels 
cueM = [.35 .65]; % display social VAS cue means


N = 200; % n sub
R = 4;  % n rep
T = numel(ST) * numel(S) * numel(C) * R; % n trial
NC = 10; % how many social cue ratings to display

o  = ones(N,T);

r.dat.nstimlevel        = numel(S);
r.dat.ncuelevel         = numel(C);
r.dat.ntrials           = T;
r.dat.cuestd            = 0.08;

r.t.cue   = 3*o; % How long to display VAS social cue
r.t.stim  = 10*o; % How long to perform stimulation
r.t.rate  = 7*o; % How long allowed for rating

r.cuelab   = {'subj','trial','cue'};
r.cues     = NaN(N,T,NC);


% factorial combinations of stim and cue
F = [];
for j = 1:numel(S)
    for k = 1:numel(C)
        for m = 1:numel(ST)
            F  = [F [ST(m); S(j); C(k)]];
        end
    end
end


%%

% loop subjects
fprintf(1,'\nsubject    ');
for g = 1:N
    
    fprintf(1,'\b\b\b%3d',g);
    
    
    cond_id = repmat([1:(length(S) * length(ST) * length(C))],1,R);
    cond_id = cond_id(randperm(T));
%     xr = xcorr(cond_id,2,'coeff');
%     while any(abs( xr([1:2 4:5]) - 0.7) > 0.05)
%         cond_id = cond_id(randperm(T));
%         xr = xcorr(cond_id,2,'coeff');
%         if sum(cond_id==repmat(1:4,1,4))== T, xr(1)=1; end
%         if abs(mean(cond_id(1:T/2))-2.5)>.25, xr(1)=1; end
%     end
    
    r.dat.trial_conds(g,:) = cond_id;
    r.dat.stimtype(g,:) = F(1,cond_id);
    for m = 1:T
        if strcmp(r.dat.stimtype(g,m), 'AU') == 1
            r.t.stim(g,m) = 6;
        end
    end
    r.dat.stim(g,:)        = cell2mat(F(2,cond_id));
    r.dat.cue(g,:)         = cell2mat(F(3,cond_id));
    r.dat.cueM(g,:)        = cueM(r.dat.cue(g,:));
    
    % get cue distribution for each trial
    for t = 1:T
        
        ct = 0;
        m  = r.dat.cueM(g,t);
        
        % draw samples
        while (abs(mean(ct)-m) > 0.025) || abs(skewness(ct))>0.035 || min(ct)<0 || max(ct)>1 || min(diff(sort(ct)))<0.006
            ct = m + r.dat.cuestd*randn(1,NC); % normal dist
        end
        
        r.cues(g,t,:) = ct;
    end
    
    % timing
    r.t.d1(g,:)     = repmat([3 3 3:.5:5 6],1,(T/8));
    r.t.d1(g,:)     = r.t.d1(g,randperm(T));
    r.t.d2(g,:)     = repmat([3 3 3:.5:5 6],1,(T/8));
    r.t.d2(g,:)     = r.t.d2(g,randperm(T));
    r.t.iti(g,:)    = repmat([3 3 3:.5:5 6], 1, (T/8));
    r.t.iti(g,:)    = r.t.iti(g,randperm(T));
end

r.t.tot = r.t.d1 + r.t.d2 + r.t.iti + r.t.cue + r.t.stim + r.t.rate;

save('randmat_fmri_thumbpain_tester2.mat','r');
