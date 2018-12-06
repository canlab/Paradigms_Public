clear;
rng('shuffle');

ST    = {'AU' 'TP'}; %stim types
S    = [1 2]; % stim levels


N = 300; % n sub
R = 5;  % n rep
T = numel(ST) * numel(S) * R; % n trial

o  = ones(N,T);

r.dat.nstimlevel        = numel(S);
r.dat.ntrials           = T;

r.t.stim  = 6*o; % How long to perform stimulation
r.t.rate  = 7*o; % How long allowed for rating

jitter1 = [3.61480452795113,1.80498694682128,2.47507004002649,1.79283544036067,3.61480452795113,1.79283544036067,3.05019494287904,1.61628409658948,6,3.05019494287904,2.48962416315278,1.79283544036067,2.88572526101211,2.27353025520101,1.70759895432910,2.88572526101211,1.72895459650334,5.39592586559085,1.61628409658948,2.4111];
jitter2 = [1.61200082040109,1.60200082040109,2.31029531352978,2.60937796244467,5.57023043261052,2.07381468493607,2.30029531352978,1.92060873122489,2.73520566065451,1.69614932566230,3.19981132391268,2.60937796244467,2.48612715776586,2.73520566065451,4.33323795283774,2.07381468493607,1.52436277568898,2.21695454971481,2.82149861347519,5.57023043261052];

% factorial combinations of stim and level
F = [];
for j = 1:numel(S)
    for m = 1:numel(ST)
        F  = [F [ST(m); S(j)]];
    end
end


%%

% loop subjects
fprintf(1,'\nsubject    ');
for g = 1:N
    
    fprintf(1,'\b\b\b%3d',g);
    
    
    cond_id = repmat([1:(length(S) * length(ST))],1,R);
    % randomize in 5 mini-blocks of 4 trials length each
    randOrder = [randperm(4) 4+randperm(4) 8+randperm(4) 12+randperm(4) 16+randperm(4)];
    cond_id = cond_id(randOrder);
    
    r.dat.trial_conds(g,:) = cond_id;
    r.dat.stimtype(g,:)    = F(1,cond_id);
    r.dat.stim(g,:)        = cell2mat(F(2,cond_id));
    
    
    % timing
    r.t.d1(g,:)     = jitter1;
    r.t.d1(g,:)     = r.t.d1(g,randperm(T));
    r.t.iti(g,:)    = jitter2;
    r.t.iti(g,:)    = r.t.iti(g,randperm(T));
end

r.t.tot = r.t.d1 + r.t.iti + r.t.stim + r.t.rate;

save('autp_trials_main.mat','r');
