% USAGE: [time] = TriggerBiopac4(seconds)
%
% Delivers 255 in binary (1111 1111) to Labjack CI03-EI07 channels
%
% To recieve binary data in biopac use the acqknowledge software interface 
% and configure the acquisition channels to recieve on the digital channels 
% D8-D15
%
% version 4 
% Changelog:
%   - updated to use Labjack UD libraries instead of io32
%   - updated to only output on CI03-EI07, not also FI00-FI07. The former
%     connect to biopac, the latter connect to Medoc.
%   - eliminated fliplr() operation on bytecode and instead flipped index
%     order when loading bytecode onto stack (in AddRequestS() call).
%
% Updated to v4 by Bogdan Petre on 7/20/2018
function [t] = TriggerBiopac4(dur)
    delay = dur*1000000; % delay is communicated in microseconds, so lets scale

    ljasm = NET.addAssembly('LJUDDotNet');
    ljudObj = LabJack.LabJackUD.LJUD;

    [~, ljhandle] = ljudObj.OpenLabJackS('LJ_dtU3', 'LJ_ctUSB', '0', true, 0);
    ljudObj.ePutS(ljhandle, 'LJ_ioPIN_CONFIGURATION_RESET', 0, 0, 0);

    % calculate byte code
    bytecode=sprintf('%08.0f',str2double(dec2bin(255)))-'0';

    for i=0:7
        %Initiate CIO3-EIO7 output
        ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', i+8, bytecode(8-i), 0, 0);    
    end

    %Wait for 1 second. The delay is performed in the U3 hardware, and delay time is in microseconds.
    %Valid delay values are 0 to 4194176 microseconds, and resolution is 128 microseconds.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_WAIT', 0, delay, 0, 0);


    for i=0:7
          %Terminate CIO3-EIO7 output (reset to 0)
          ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, i+8,0, 0, 0);
    end

    t = GetSecs;
    %Perform the operations/requests
    ljudObj.GoOne(ljhandle);
end