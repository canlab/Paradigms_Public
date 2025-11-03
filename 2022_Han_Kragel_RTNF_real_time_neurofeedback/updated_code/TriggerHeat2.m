function [t] = TriggerHeat2(code)
% this function made to work with io32 MEX/dll stuff downloaded from
% http://sunburst.usd.edu/~schieber/psyc770/IO32.html
% to work with parallel port on CINC machine where DAQ was giving us problems

global THERMODE_PORT

outp(THERMODE_PORT,code);
t = GetSecs;
WaitSecs(.1);
outp(THERMODE_PORT,0);

end