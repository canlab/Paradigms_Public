function y = exp_sample(mean_value,min_value,max_value,interval)
% produce a random sample from an exponential distribution within limits (min/max) given a mean. 
% round to nearest interval.
% this is useful for generating jittered time intervals

tmp=exprnd(mean_value);
tmp=tmp-mod(tmp,interval); % round to nearest interval
while (tmp < min_value || tmp > max_value)
   tmp=exprnd(mean_value);
   tmp=tmp-mod(tmp,interval); % round to nearest interval   
end
y=tmp;
