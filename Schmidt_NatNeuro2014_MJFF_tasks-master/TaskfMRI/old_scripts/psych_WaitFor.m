function [devnumber T0] = psych_WaitFor(mychar,devnumber, T0)

if devnumber == 0 && T0==0
    ds=PsychHID('Devices'); %str2mat(ds.product)
    %devnumber = input('Enter device number: ');
    
    xx = zeros(1,length(ds));
    xx(strmatch('Keyboard',str2mat(ds.usageName))) = xx(strmatch('Keyboard',str2mat(ds.usageName)))+1;
     xx(strmatch('USB Keyboard',str2mat(ds.product))) = xx(strmatch('USB Keyboard',str2mat(ds.product))) + 1; 
%      xx(strmatch('Apple Internal Keyboard / Trackpad',str2mat(ds.product))) = xx(strmatch('Apple Internal Keyboard / Trackpad',str2mat(ds.product))) + 1; 
    
    if ~any(xx==2)
        beep,beep,beep
        error('Cannot Find Xkeys Keyboard device!'); 
        Screen('CloseAll');
    else
        devnumber = find(xx==2);
    end
    
  
end
    
% wait for key
begin =0;
keyChar = 0;


while begin==0
    [secs,keyCode] = KbCheck(devnumber,3);
    if any(keyCode)
        keyChar = KbName(keyCode);
        trigger= strcmp(lower(keyChar),mychar);
        if trigger==1
            T0 = secs;
            begin=1;
        else
            keyChar = 'xxx';
        end
    end
end

return


    
    


