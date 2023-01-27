function connection = test_client(serverIP)
% Helper function to establish an ip connection with a server
% a client. Requires the server's ip address
%
% Returns the connection object

    connection = tcpip(serverIP,30000,'NetworkRole','client');
    connection.InputBufferSize = 1024;
    connection.OutputBufferSize = 1024;
    fopen(connection);
    WaitSecs(1);
    % Test the connection
    fprintf('Sending test data to server....\n');
    fwrite(connection,[100],'double');
    WaitSecs(1);
    testReply = [];
    while isempty(testReply)
        testReply = WaitForInput(connection,[1,1],.5);
    end
    fprintf('Successfully received reply from server!\n');   
end