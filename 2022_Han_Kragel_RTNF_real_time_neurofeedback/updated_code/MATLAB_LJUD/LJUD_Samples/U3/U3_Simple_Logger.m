% -------------------------------------------------------------------
% Simple Logger Example:
% This example polls your U3 and returns data from four analog inputs,
% and two digital I/O's. Call this file by typing Simple_logger(time,dt)
% into the command window. The parameter time specifies how long to poll 
% the UE9 for, and the parameter dt specifies the time between pollings.
%
% -------------------------------------------------------------------

clc %clear the MATLAB command window
%clear global %Clears MATLAB global variables

dt = input('What would you like dt to be?  dt = ');
time = input('what would you like time to be? time = ');

% Pre-initalize arrays
Error(1,1:time/dt)=0;
AIN0(1,1:time/dt)=-100;
AIN1(1,1:time/dt)=-100;
AIN2(1,1:time/dt)=-100;
AIN3(1,1:time/dt)=-100;
FIO0(1,1:time/dt)=-100;
FIO1(1,1:time/dt)=-100;

ljud_LoadDriver; % Loads LabJack UD Function Library
ljud_Constants; % Loads LabJack UD constant file
[Error ljHandle] = ljud_OpenLabJack(LJ_dtU3,LJ_ctUSB,'1',1); % Returns ljHandle for open LabJack
Error_Message(Error)% Check for and display any Errros

%Start by using the pin_configuration_reset IOType so that all
%pin assignments are in the factory default condition.
%First some configuration commands.  These will be done with the ePut
%function which combines the add/go/get into a single call.
Error = ljud_ePut (ljHandle, LJ_ioPIN_CONFIGURATION_RESET, 0, 0, 0);
Error_Message(Error)

%Configure FIO2 and FIO3 as analog, all else as digital.  That means we
%will start from channel 0 and update all 16 flexible bits.  We will
%pass a value of b0000000000001100 or d15.
Error = ljud_ePut (ljHandle, LJ_ioPUT_ANALOG_ENABLE_PORT, 0, 15, 16);
Error_Message(Error)

% For loop for time/dt iterations
for (n = 1:time/dt) 
    x(1,n) = n;
    %Call eGet function: Returns Error and Value
    [Error(1,n) AIN0(1,n)] = ljud_eGet(ljHandle,LJ_ioGET_AIN,0,0,0); 
    Error_Message(Error)
    [Error(1,n) AIN1(1,n)] = ljud_eGet(ljHandle,LJ_ioGET_AIN,1,0,0);
    Error_Message(Error)
    [Error(1,n) AIN2(1,n)] = ljud_eGet(ljHandle,LJ_ioGET_AIN,2,0,0);
    Error_Message(Error)
    [Error(1,n) AIN3(1,n)] = ljud_eGet(ljHandle,LJ_ioGET_AIN,3,0,0);
    Error_Message(Error)
    [Error(1,n) FIO0(1,n)] = ljud_eGet(ljHandle,LJ_ioGET_DIGITAL_BIT_STATE,0,0,0);
    %Error_Message(Error) when this error check is used it causes MATLAB to
    %complain
    [Error(1,n) FIO1(1,n)] = ljud_eGet(ljHandle,LJ_ioGET_DIGITAL_BIT_STATE,1,0,0);
    %Error_Message(Error) when this error check is used it causes MATLAB to
    %complain
    
        %plot AINx data
        plot (x,AIN0(x),x,AIN1(x),'r',x,AIN2(x),'g',x,AIN3(x),'k')
        xlim([(n-(dt*10)),n])
        legend('AINO','AIN1','AIN2','AIN3')
        drawnow
        pause (dt) %pause dt before next iteration 
end 
if (Error ~= 0) % If no error codes found display data in table format
    table(:,1) = x'*dt;
    table(:,2) = AIN0';
    table(:,3) = AIN1';
    table(:,4) = AIN2';
    table(:,5) = AIN3';
    table(:,6) = FIO0';
    table(:,7) = FIO1';
    disp('    Time      AIN0      AIN1      AIN2      AIN3      FIO0      FIO1')
    disp(table)
end