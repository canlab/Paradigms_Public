% -----------------------------------------------------------------
% Simple Stream Example
% In this example we will simply stream from two channels for a brief 
% period and do a single read. This process is looped ten times so as to get 
% more data. To get more or less data, change the number of loops.
% The data is read into a single array which has to be parsed for the two 
% channels. Every other data point belongs to the same channel.
% -----------------------------------------------------------------

clc %clear the MATLAB command window
clear global %Clears MATLAB global variables

ljud_LoadDriver; % Loads LabJack UD Function Library
ljud_Constants; % Loads LabJack UD constant file

% Variable list
Loops = 9;
num_channels = 4;
ScanRate = 1000; % Set scan rate
time = 0.5;
buffer = 5; % 5 second buffer time
Scans = (ScanRate/1000) * (time*1000)* 2;
global final_array;

% Returns ljHandle for open LabJack
[Error ljHandle] = ljud_OpenLabJack(LJ_dtU3,LJ_ctUSB,'1',1);
Error_Message(Error) % Check for and display any Errors

%Start by using the pin_configuration_reset IOType so that all
%pin assignments are in the factory default condition.
Error = ljud_ePut(ljHandle, LJ_ioPIN_CONFIGURATION_RESET, 0, 0, 0);
Error_Message(Error)

% Configure AIN0 to be an analog input
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_ANALOG_ENABLE_BIT,0,1,0,0);
Error_Message(Error)

% Configure AIN1 to be an analog input
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_ANALOG_ENABLE_BIT,1,1,0,0);
Error_Message(Error)

% Configure AIN0 to be an analog input
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_ANALOG_ENABLE_BIT,2,1,0,0);
Error_Message(Error)

% Configure AIN3 to be an analog input
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_ANALOG_ENABLE_BIT,3,1,0,0);
Error_Message(Error)

% Configure Scan Rate
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_CONFIG,LJ_chSTREAM_SCAN_FREQUENCY,ScanRate,0,0);
Error_Message(Error)
 
% Give the driver a 5 second buffer (ScanRate * 4 Channels * 5 Seconds)
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_CONFIG,LJ_chSTREAM_BUFFER_SIZE,ScanRate*num_channels*buffer,0,0);
Error_Message(Error)

% Configure reads to retrieve whatever data is available without waiting
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_CONFIG,LJ_chSTREAM_WAIT_MODE,LJ_swNONE,0,0);
Error_Message(Error)

% Clear stream channels
Error = ljud_AddRequest(ljHandle,LJ_ioCLEAR_STREAM_CHANNELS,0,0,0,0);
Error_Message(Error)

% Define the scan list as AIN0, AIN1, AIN2, and AIN3
Error = ljud_AddRequest(ljHandle,LJ_ioADD_STREAM_CHANNEL,0,0,0,0);
Error_Message(Error)

Error = ljud_AddRequest(ljHandle,LJ_ioADD_STREAM_CHANNEL,1,0,0,0);
Error_Message(Error)

Error = ljud_AddRequest(ljHandle,LJ_ioADD_STREAM_CHANNEL,2,0,0,0);
Error_Message(Error)

Error = ljud_AddRequest(ljHandle,LJ_ioADD_STREAM_CHANNEL,3,0,0,0);
Error_Message(Error)

% Execute list of above requests
Error = ljud_GoOne(ljHandle);
Error_Message(Error)

%--------------------------------------------------------------------------
% Get all results just to check for errors
Error = ljud_GetFirstResult(ljHandle,0,0,0,0,0);
Error_Message (Error)

% Run while loop until Error 1006 is returned to ensure that the device has
% fully configured its channels before continuing.
while (Error ~= 1006) % 1006 Equates to LJE_NO_MORE_DATA_AVAILABLE
    Error = ljud_GetNextResult(ljHandle,0,0,0,0,0);
    if ((Error ~= 0) && (Error ~= 1006))
        Error_Message (Error)
        break
    end
end 

%--------------------------------------------------------------------------
% Start the Stream
Error = ljud_ePut(ljHandle,LJ_ioSTART_STREAM,0,0,0);
Error_Message(Error)
    
for n = 0:Loops
    
    % Set the number of scans to read. We will request twice the number we
    % expect, to make sure we get everything that is available. Note the array
    % we pass must be sized to hold enough SAMPLES, and the Value we pass
    % specifies the number of SCANS to read.
    Scans = (ScanRate/1000) * (time*1000)* 2;
    
    % Initialize an array to store data
    array(Scans*num_channels) = double(0);

    % Wait a little then read however much data is available
    pause (time)

    % Get the Streamed Data. Here the special ljud_eGet_array function must be used
    % for array handling. The function ljud_eGet_array calls from a
    % different library where the eGet function has been modified to handle
    % arrays. The difference between the regular ljud_eGet and this modified
    % ljud_eGet_array is the last input argument data type. In the regular ljud_eGet it is
    % specified as an int32. In the modified ljud_eGet_array the last input
    % argument is specified as a doublePtr. This modified function returns
    % a single column array. If you have streamed from more than one
    % channel the data has to be parsed as in this sample.
    [Error Scans return_array] = ljud_eGet_array(ljHandle,LJ_ioGET_STREAM_DATA,LJ_chALL_CHANNELS,Scans,array);
    Error_Message(Error)

    final_array = horzcat(final_array,return_array(1:Scans*num_channels));

    clear return_array
    clear array

end



% Stop the stream
[Error] = ljud_ePut(ljHandle,LJ_ioSTOP_STREAM,0,0,0);
Error_Message(Error)
%--------------------------------------------------------------------------


array_length = length(final_array);

% Data for all channels is now in array return_array; separate data into four separate
% arrays by channel names.
i = 1;
for n=1:num_channels:array_length
    AIN0(1,i) = double(final_array(n));
    AIN1(1,i) = double(final_array(n+1));
    AIN2(1,i) = double(final_array(n+2));
    AIN3(1,i) = double(final_array(n+3));
    i = i + 1;
end

% Scans equals the number of data points per channel. The following for
% loop creates an array that is equal in lenth to the number of scans.
% This is only useful for displaying the data by line number.
for n=1:1:array_length/num_channels
    j(1,n) = n/ScanRate; 
end
    
% Display the data
disp ('Total Number of data points per Channel:') 
disp (array_length/num_channels)

clear table
table(:,1) = j';
table(:,2) = AIN0';
table(:,3) = AIN1';
table(:,4) = AIN2';
table(:,5) = AIN3';
disp('  Time(sec)   AIN0      AIN1      AIN2      AIN3')
disp(table)

