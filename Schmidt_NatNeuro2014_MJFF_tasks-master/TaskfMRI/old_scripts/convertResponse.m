
% function subjAns = convertResponse(resp);
% Convert the subject input (resp) from whatever char was collected to the
% corresponding 1=left, 0=right, for later comparison to
% infoStruct.Response

function subjAns = convertResponse(resp)

if strcmp(resp,'1')  % this corresponds to 'Left'
    subjAns = 1;
elseif strcmp(resp,'2')  % this corresponds to 'Right'
    subjAns = 0;
elseif strcmp(resp,'n')
    subjAns = 8;  % this corresponds to 'noanswer' return from recordKeys
else
    subjAns = 9;  % this means the subj hit some other key
end



