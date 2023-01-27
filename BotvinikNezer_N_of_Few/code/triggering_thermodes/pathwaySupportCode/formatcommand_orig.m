function [command, commandLength] = formatcommand(commandId,parameter)
% FORMATCOMMAND format the command (message) fron sending to TCP socket.
%
% Input:
% 1. commandId - the command code (as double) 
% 2. parameter - parameter for command (optional, depending on command Id)
%
% Output:
% 1. command - formated command as byte array (ready as input to client)
% 2. commandLength - total command length (including length field for client)
% 
% Written by Yael Frankel
%
% Last updated:
% March, 25th, 2014
%---------------------------------------------------------------------

%% Collect required data from command 
    % initialize buffer and byte count  
    buffer = [];
    nBytes = 0;

    % add time stamp
    unixTime = uint32(dateNumToUnixTime(now));   
    buffer = [buffer,double(unixTime)];
    nBytes = nBytes + 4;

    % add command Id
    buffer = [buffer,commandId];
    nBytes = nBytes + 1;

    % add parameter depending on command Id
    switch commandId
        case 1 % Send Program (SELECT_TP)
            if nargin >= 2
                programCode = parameter;
            end
            buffer = [buffer,programCode];
            nBytes = nBytes + 4;
        otherwise
            % no other commands require additional parameters
    end % end switch

%% Convert buffer content to output byte array
    % conversion to bytes is based on the following: 
    % - length = 4 bytes, timestamp = 4 bytes, 
    % - command Id = 1 bytes, parameter = 4 bytes;

    % add length of command 
    buffer = [nBytes,buffer]; 
    nBytes = nBytes + 4;

    % initialize output buffer
    outBufferLut = 8.*[4,4,1,4,inf]; % see comment above
    outBuffer = []; 

    % convert from double to byte array
    for i = 1:length(buffer)
        K = cell2mat(arrayfun(@(bit)bitget(buffer(i),outBufferLut(i)+1-bit),...
            1:outBufferLut(i),'UniformOutput',0));
        K = reshape(K, [8, numel(K)/8])';
        U = K*(2.^(size(K,2)-1:-1:0))';
        outBuffer = [outBuffer;flip(uint8(U))]; %#ok<AGROW>
    end % end for

    command = outBuffer;
    commandLength = nBytes; 


end % end function
 
    
  
    


    
   