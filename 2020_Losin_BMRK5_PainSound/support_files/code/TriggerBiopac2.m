function [t] = TriggerBiopac2(dur)
% USAGE: [time] = TriggerBiopac2(duration)
% this function made to work with io32 MEX/dll stuff downloaded from
% http://sunburst.usd.edu/~schieber/psyc770/IO32.html
% to work with parallel port on CINC machine where DAQ was giving us problems

global BIOPAC_PORT

outp(BIOPAC_PORT,2);
t = GetSecs;
WaitSecs(dur);
outp(BIOPAC_PORT,0);

end