function biopac_signal(signal_out)
% This function sends output to the Biopac system in the digital channels
% (channel D8-D15).
% these 8 channels are used to code up to 255 values.
% a table with the meaning of each value (and the binary string
% representing the status of all channels) can be found in the code
% directory.
% Make sure to manually start recording on Acknowledge before running
% this code, and to save the file with n appropriate filename (see SOP) at
% the end of the task.
%
% make sure parallel port number and dataout are correct, and that the port
% is connected to the biopac system
%
% input: signal_out: the digital signal to send. A decimel number representing the 8 bit string (with
% the desired status of each channel; e.g. '00000001', or the decimal value 1, turns on the first channel, D8, and turns off the rest, D9-D15). 

port = hex2dec('2FF8'); % Must find your computer's parallel port address via Device Manager -> COM/LPT -> Properties
ioObj = io64;  % initialize the interface to the inpoutx64 system driver
status = io64(ioObj); % the code doesn't work without this line
%signal_out_dec = bin2dec(signal_out_bin);
io64(ioObj, port, signal_out); % Output command to Acqknowledge

end