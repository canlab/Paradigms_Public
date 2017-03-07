
function k = getKeyboardNumber();

d=PsychHID('Devices');
k = 0;

%  xx = zeros(1,length(d));
%  xx(strmatch('Keyboard',str2mat(d.usageName))) = xx(strmatch('Keyboard',str2mat(d.usageName)))+1;
%  xx(strmatch('Apple Internal Keyboard / Trackpad',str2mat(d.product))) = xx(strmatch('Apple Internal Keyboard / Trackpad',str2mat(d.product))) + 1; 
%     
% if ~any(xx==2)
%         beep,beep,beep
%         error('Cannot Find Xkeys Keyboard device!'); 
%         Screen('CloseAll');
%     else
%         k = find(xx==2);
% end

for n = 1:length(d)
    if strcmp(d(n).usage.Name,'Keyboard');
        k=n;
        break
    end
end