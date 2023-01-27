function responseStr = main(hostName, portNum, commandId, parameter)
% MAIN wrapper function to demonstrate the socket communication with
% PATHWAY.
% usage: type in command window with approriate input variables:
%        main(hostName, portNum, commandId, parameter)
%
% Input:
% 1. hostName - host address ('xxx.xxx.xxx.xxx' or 'localhost')
% 2. portNum - port number
% 3. commandId - the command code (as double) 
% 4. parameter - parameter for command (optional, depending on command Id)
%
% Written by Yael Frankel
%
% Last updated:
% March, 25th, 2014
%---------------------------------------------------------------------
    % format command
    if nargin == 4
        [outBuffer, outLength] = formatcommand(commandId,parameter);
    else
        [outBuffer, outLength] = formatcommand(commandId);
    end % end if

    % Send message (command) and read message (response)
    [STATUS,readBuffer,readBytes] = client(hostName, portNum,outBuffer,outLength);

    % Format response and display in command Window
    if STATUS == 0 
        responseStr = 'Error has occured, message not recieved';
    else 
        responseStr = formatresponse(readBuffer,readBytes);
    end
    celldisp(responseStr);
end
