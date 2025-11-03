function [t] = TriggerBiopac3(dur)
% USAGE: [time] = TriggerBiopac2(duration)
% this function made to work with io32 MEX/dll stuff downloaded from
% http://apps.usd.edu/coglab/psyc770/IO32.html
% to work with parallel port on CINC machine where DAQ was giving us problems

% Follow directions on website to get IO32 function, must run matlab as
% administrator (i.e., right click).

global BIOPAC_PORT

%initialize object
ioObj = io32;
err = io32(ioObj);
if err
    error('io32 aint workin, have fun fixin it!')
end

io32(ioObj, BIOPAC_PORT, 2); %send ttl to biopac
t = GetSecs;
WaitSecs(dur);
io32(ioObj, BIOPAC_PORT, 0) %reset biopac ttl


% outp(BIOPAC_PORT,2);
% t = GetSecs;
% WaitSecs(dur);
% outp(BIOPAC_PORT,0);

end