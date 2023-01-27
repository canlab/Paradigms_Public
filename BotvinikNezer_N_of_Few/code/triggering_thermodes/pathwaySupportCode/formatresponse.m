function response = formatresponse(message,nBytes)
% FORMATRESPONSE decode the response from byte array (message) to readbile 
% string (as cell of strings). 
%
% Includes the following local functions: 
% 1. y = decode(x,B)
% 2. function hms = msec2hms(t)
% 
% Input:
% 1. message - message as recieved from socket
% 2. nBytes - length of message as recieved. optional, if not availalbe
%        length will be calculated. 
%
% Output:
% 1. response - formated response. If response is incomplete, response
% strings is empty
%
% Written by Yael Frankel
%
% Last updated:
% March, 25th, 2014
%---------------------------------------------------------------------

    % Segmentation points for decoding response
    LENGTH_OFFSET = 1:4;
    TIMESTAMP_OFFSET = 5:8;
    COMMAND_OFFSET = 9;
    SYSTEM_STATE_OFFSET = 10;
    TEST_STATE_OFFSET = 11;
    RESULT_OFFSET = 12:13;
    TEST_TIME_OFFSET = 14:17;
    ERROR_MESSAGE_OFFSET = 18;
    
    % length of recieved message (if not provided)
    if nargin < 2
        nBytes = length(message);
    end

    % response length
    responseLength = decode(message(LENGTH_OFFSET),8); % double

    % check that length of message recieved matches declared message length
    if (responseLength + length(LENGTH_OFFSET)) ~= nBytes
        res.responseLength = sprintf('Incomplete Response. Response Length: %d Bytes',...
            responseLength);
        response = '';
        return; % exit if response is incomplete
    else
        res.responseLength = sprintf('Response Length: %d Bytes',responseLength);
    end % end if

    % time stamp
    unixTime = decode(message(TIMESTAMP_OFFSET),8);
    dateNumTime = unixTimeToDateNum(unixTime);
    res.timeStamp = ['Time: ', datestr(dateNumTime,31)]; % string 'yyyy-mm-dd HH:MM:SS'
    %TODO: Add timestamp check to verify timestamp of message recieved matches
    %timestamp of message sent

    % command 
    commandId = Commands.commandid(decode(message(COMMAND_OFFSET),8)); %string
    res.commandId = ['Command Recieved: ',commandId];
    %TODO: Add commandId check to verify commandId of message recieved matches
    %commandId of message sent

    % Pathway State
    pathwayState = PathwayState.state(decode(message(SYSTEM_STATE_OFFSET),8)); %string
    res.pathwayState = ['Pathway State: ',pathwayState];


    % Test State
    testState = PathwayTestState.teststate(decode(message(TEST_STATE_OFFSET),8)); %string
    res.testState = ['Test State: ',testState];

    % Result Code
    temp = decode(message(RESULT_OFFSET),8);
    resultId = ResponseCode.responseid(temp); %string
    res.resultId = ['Response: ',resultId];

    % Test Time
    testTime = decode(message(TEST_TIME_OFFSET),8);
    res.testTime = ['Test Time: ',msec2hms(testTime)]; 

    % Error Message
    if responseLength > 13
        nativeCode = uint8(message(ERROR_MESSAGE_OFFSET:end));
        errorMsg = upper(native2unicode(nativeCode));
        res.errorMsg = ['Message: ',errorMsg];
    end % end if


    % format string as cell of strings
    response = struct2cell(res);

end % end function formatresponse

function y = decode(x,B)
    if numel(x) <= 0 
        y = 0;
        return;
    end % end if
    temp = flip(x);
    k = cell2mat(arrayfun(@(bit)bitget(temp,B+1-bit),1:B,'UniformOutput',0));
    k = reshape(k,[numel(k)/B,B])';
    k = reshape(k,[],1);
    y = (2.^(length(k)-1:-1:0))*k;
end % end function decode

function hms = msec2hms(t)
    hours = floor(t / 3600000);
    t = t - (hours * 3600000);
    mins = floor(t / 60000);
    t = t - (mins * 60000);
    secs = floor(t / 1000);
    msecs = t - (secs * 1000);
    hms = sprintf('%02d:%02d:%02d:%04d', hours, mins, secs, msecs);
end % end function msec2hms
    
    
    
