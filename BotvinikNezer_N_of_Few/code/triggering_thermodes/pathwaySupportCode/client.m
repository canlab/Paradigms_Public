function [STATUS, readMessage, readBytes] = client(host, port,writeMessage,nBytes)
% CLIENT connect to a server using TCP socket communication
% send message and read response.
%
% Input:
% 1. host - host address (xxx.xxx.xxx.xxx or 'localhost')
% 2. port - port number
% 3. writeMessage - array of Unsigned Bytes (UINT8)
% 4. nBytes - size of message in Bytes. 
%
% Output:
% 1. STATUS - 0 if error occured, 1 if return message was recived
%             successfully
% 2. readMessage - return message in Bytes (double). 0 if error.
% 3. Number of bytes in return message. 0 if error. 
% 
% Written by Yael Frankel
% Code from client.m code found on Malab file exchange
% (Copyright (c) 2009, Rodney Thomson, All rights reserved)
% Last updated:
% October, 15, 2020
%---------------------------------------------------------------------

    import java.net.Socket
    import java.io.*

    number_of_retries = 10; % set to -1 for infinite
    
     
    retry        = 0;
    client_socket = [];
    
    % establish connection
    while true
        retry = retry + 1;
        if ((number_of_retries > 0) && (retry > number_of_retries))
            fprintf(1, 'Too many retries\n');
            if ~exist('readMessage','var')
                readMessage = 0;
                readBytes = 0;
                STATUS = 0; % ERROR
            end
            return; % if cant establish communication return to caller
        end       
        try
            fprintf(1, 'Try %d connecting to %s:%d\n', ...
                    retry, host, port);

            % throws if unable to connect
            client_socket = Socket(host, port);
            % set 5 sec timeout
            client_socket.setSoTimeout(5000);
            break; % if communication is successful, break loop and continue
        catch 
            if ~isempty(client_socket)
                client_socket.close;
            end
            fprintf(1,'Cant connect to server\n');
            pause(1); % pause before retrying
        end % end try-catch 
    end % end while
    
    % Connection is established
    fprintf(1, 'Connected to server\n');
        
    try 
        % write output stream to socket (in Bytes)
        output_stream = client_socket.getOutputStream;
        d_output_stream = DataOutputStream(output_stream);
        d_output_stream.write(writeMessage,0,nBytes);
        d_output_stream.flush;

        fprintf(1, 'Message sent\n');
        % get a buffered data input stream from the socket
        input_stream   = client_socket.getInputStream;
        d_input_stream = DataInputStream(input_stream);

        % read first byte of data, wait for 5 sec if not available
        firstByte = d_input_stream.readUnsignedByte;
        
        % read the rest of data from the socket
        readBytes = input_stream.available + 1;
        readMessage = zeros(1,readBytes);
        readMessage(1) = firstByte;
        
        fprintf(1, 'Reading %d bytes\n', readBytes); 
        for i = 2:readBytes
            readMessage(i) = d_input_stream.readUnsignedByte;
        end
        fprintf(1, 'Message recieved\n'); 
        % clean up
        client_socket.close;
        STATUS = 1;


    catch wr_err
        fprintf(1, 'Error caught trying to write/read message\n');
        getReport(wr_err,'extended')
        STATUS = 0;

        if ~isempty(client_socket)
            client_socket.close;
        end
        if ~exist('readMessage','var')
            readMessage = 0;
            readBytes = 0;
        end


    end % end try-catch wr_err

       
 
end % end function