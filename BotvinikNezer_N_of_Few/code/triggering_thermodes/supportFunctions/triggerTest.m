function triggerTest(ip)
% This function runs a quick test of connectivity and triggering with both the
% labjack for psychophysical acquistion and the thermode for heat triggering
% Make sure the labjack is connected over USB and the thermode is connected to
% the same wifi as this laptop. Also make sure the thermode is ready to receive
% external control commands
%
% Enter ip address of thermode as string to begin test, e.g.
% triggerTest('10.0.1.17')

%Pain Variables
port = 20121;
% Initialize LabJack
lj = labJack('verbose',false);
WaitSecs(3);
% lj.timedTTL(7,200)
fprintf('Biopac initial acquistion signal sent! Did it start?\n');

% a) LabJack Trigger ON and OFF - port 20
try
    WaitSecs(2);
    lj.setDIOValue(1,[255 255 255])
    WaitSecs(5)
    lj.setDIOValue(0,[255 255 255])
    fprintf('Biopack trigger turned on/off for 5 seconds. Look at Wave 20 is this displayed?\n');
catch
    error('Problem triggering Labjack!');
end

% b) Trigger a thermode pre-test (for the 5s program)
main(ip,port,1,50); 
if checkStatus(ip,port)
    main(ip, port, 5, 50) %stop signal
    fprintf('Thermode successfully triggered! It should be finalizing a pre-test\n')
else
    error('Problem triggering thermode!')
end

end
