% -------------------------------------------------------------------
% Simple Logger Example:
% This example polls your UE9 and returns data from four analog inputs,
% and two digital I/O's. Call this file by typing Simple_logger(time,dt)
% into the command window. The parameter time specifies how long to poll 
% the UE9 for, and the parameter dt specifies the time between pollings.
%
% -------------------------------------------------------------------

clc %clear the MATLAB command window
clear global %Clears MATLAB global variables

dt = input('What would you like dt to be?  dt = ');
time = input('what would you like time to be? time = ');
ljud_LoadDriver; % Loads LabJack UD Function Library
ljud_Constants; % Loads LabJack UD constant file
[Error ljHandle] = ljud_OpenLabJack(LJ_dtUE9,LJ_ctUSB,'1',1); % Returns ljHandle for open LabJack
Error_Message(Error) % Check for and display any Errors

% Pre-initalize arrays
Error(1,1:time/dt)=0;
AIN0(1,1:time/dt)=-100;
AIN1(1,1:time/dt)=-100;
AIN2(1,1:time/dt)=-100;
AIN3(1,1:time/dt)=-100;
FIO0(1,1:time/dt)=-100;
FIO1(1,1:time/dt)=-100;

for n = 1:time/dt % For loop for time/dt iterations
    x(1,n) = n;
    % Call eGet function to get AIN value
    [Error(1,n) AIN0(1,n)] = ljud_eGet(ljHandle,LJ_ioGET_AIN,0,0,0); 
    Error_Message(Error)
    
    [Error(1,n) AIN1(1,n)] = ljud_eGet(ljHandle,LJ_ioGET_AIN,1,0,0);
    Error_Message(Error)
    
    [Error(1,n) AIN2(1,n)] = ljud_eGet(ljHandle,LJ_ioGET_AIN,2,0,0);
    Error_Message(Error)
    
    [Error(1,n) AIN3(1,n)] = ljud_eGet(ljHandle,LJ_ioGET_AIN,3,0,0);
    Error_Message(Error)
    
    % Call eGet functon to get digital state
    [Error(1,n) FIO0(1,n)] = ljud_eGet(ljHandle,LJ_ioGET_DIGITAL_BIT,0,0,0);
    Error_Message(Error)
  
    [Error(1,n) FIO1(1,n)] = ljud_eGet(ljHandle,LJ_ioGET_DIGITAL_BIT,1,0,0);
    Error_Message(Error)
    
    % plot data
    plot (x,AIN0(x),x,AIN1(x),'r',x,AIN2(x),'g',x,AIN3(x),'k')
    xlim([(n-(dt*10)),n])
    legend('AINO','AIN1','AIN2','AIN3')
    drawnow
    pause (dt) %pause dt before next iteration
    
end

% display data in tabular format
clear table
table(:,1) = x'*dt;
table(:,2) = AIN0';
table(:,3) = AIN1';
table(:,4) = AIN2';
table(:,5) = AIN3';
table(:,6) = FIO0';
table(:,7) = FIO1';
disp('    Time      AIN0      AIN1      AIN2      AIN3      FIO0      FIO1')
disp(table)
