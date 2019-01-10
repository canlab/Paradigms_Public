clear;
rng('shuffle');

S    = [1 2 3 4]; % stim levels


N = 300; % n sub
R = 5;  % n rep
T = numel(S) * R; % n trial

o  = ones(N,T);

r.dat.nstimlevel        = numel(S);
r.dat.ntrials           = T;

r.t.stim = 30*o;

r.t.rate  = 7*o;

%%

% loop subjects
fprintf(1,'\nsubject    ');
for g = 1:N
    
    fprintf(1,'\b\b\b%3d',g);
    
    
    cond_id = repmat([1:length(S)],1,R);
    cond_id = cond_id(randperm(T));
    xr = xcorr(cond_id,2,'coeff');
    
    r.dat.trial_conds(g,:) = cond_id;
    
    %% factorial combinations of stim and cue
    F = {[1 3 2 4] [1 4 2 3] [2 4 1 3] [3 1 4 2] [4 1 3 2] [4 2 3 1]};
    random = randi(6);
    K = F(random);
    F(random) = [];
    
    for j = 1:R-1
        random = randi(6-j);
        new = F(random);
        
        while K{end}(end) == new{1}(1)
            rng('shuffle');
            random = randi(6-j);
            new = F(random);
        end
        
        F(random) = [];
        K = [K new];

    end

    F = cell2mat(K);
    
    
    r.dat.stim(g,:)        = F;
    
    
end

r.t.tot = r.t.stim + r.t.rate; % total trial duration (rating and d1 are within stimulus presentation)
 
fname = 'backpain_trials_main.mat';
save(fname,'r');
