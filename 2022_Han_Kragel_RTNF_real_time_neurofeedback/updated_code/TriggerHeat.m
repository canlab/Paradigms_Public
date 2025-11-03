function [t] = TriggerHeat(temp)
global ljudObj
% [ljerror, ljhandle] = ljudObj.OpenLabJack(LabJack.LabJackUD.DEVICE.U3, LabJack.LabJackUD.CONNECTION.USB, '0', true, 0);
[ljerror, ljhandle] = ljudObj.OpenLabJackS('LJ_dtU3', 'LJ_ctUSB', '', true, 0);
% calculate byte code
if(mod(temp,1))
    % note: this will treat any decimal value as .5
    temp=temp+128-mod(temp,1);
end
bytecode=fliplr(sprintf('%08.0f',str2double(dec2bin(temp))))-'0';

% % send trigger
% putvalue(THERMODE_PORT.Line, bytecode);
t=GetSecs;

% % flush buffer
% WaitSecs(0.5);
% putvalue (THERMODE_PORT.Line, [0 0 0 0 0 0 0 0]);


%Set FIO0 to FIO7 to output-high
for i=0:7
    
    
    % Set digital output FIO4 to output-high.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT',i, bytecode(i+1), 0, 0);
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', i+8, bytecode(i+1), 0, 0);
    
    
    % ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, i, bytecode(i+1), 0, 0);
    % ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, i+8, bytecode(i+1), 0, 0);
    
end

%Wait for 1 second. The delay is performed in the U3 hardware, and delay time is in microseconds.
%Valid delay values are 0 to 4194176 microseconds, and resolution is 128 microseconds.

ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_WAIT', 0, 1000000, 0, 0);
% ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_WAIT, 0, 1000000, 0, 0);

%Set CIO3 and EIO7 to output-low
for i=0:7
%     ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, i, 0, 0, 0);
%     ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, i+8,0, 0, 0);
    
      ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT',i, 0, 0, 0);
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', i+8, 0, 0, 0);
  
end

%Perform the operations/requests
ljudObj.GoOne(ljhandle);

end