function [errorFlag, connection] = test_server()
% Helper function to start serving an ip connection and test that connection with a
% a client. The server is agnostic to the client IP. It listens in intervals of
% 10s by default, this can be changed with 'Timeout',nSec during the call to
% tcpip(). It will pause Matlab functionality and keep listening for a total of
% N seconds determined by the 3rd argument to WaitForInput
%
% Returns an errorFlag (0=success; 1=failure) and the connection object

    thisIP = char(java.net.InetAddress.getLocalHost.getHostAddress);
    fprintf(['Current IP Address: ' thisIP '\n'])
    connection = tcpip('0.0.0.0',30000,'NetworkRole','server');
    connection.InputBufferSize = 1024;
    connection.OutputBufferSize = 1024;
    fprintf('Waiting for client to connect...\n');
    fopen(connection);
    % This print will trigger only if the client connects
    fprintf('Client connected!\n');
    WaitSecs(1);
    % Test the connection
    fprintf('Waiting for client to send test data....\n');
    testData = WaitForInput(connection,[1,1],10);
    if ~isempty(testData)
        fprintf('Successfully received information from client!\n');
        WaitSecs(.2);
        fprintf('Sending callback...\n');
        fwrite(connection,1,'double');
        errorFlag = 0;
    else
        errorFlag = 1;
    end     
end