% -------------------------------------------------------------------------
% Simple Analog In
% This file calls the eGet function and returns the
% analog voltages AIN2 and AIN3-VREF from the U3. 
% -------------------------------------------------------------------------

clc % Clears the command window
clear global % Clears all global variables

ljud_LoadDriver; % Loads LabJack UD Function Library
ljud_Constants; % Loads LabJack UD constant file
[Error ljHandle] = ljud_OpenLabJack(LJ_dtU3,LJ_ctUSB,'1',1); % Returns ljHandle for open LabJack
Error_Message(Error) % Check for and display any Errros

%Start by using the pin_configuration_reset IOType so that all
%pin assignments are in the factory default condition.
[Error] = ljud_ePut(ljHandle, LJ_ioPIN_CONFIGURATION_RESET, 0, 0, 0);
Error_Message(Error)

%First some configuration commands.  These will be done with the ePut
%function which combines the add/go/get into a single call.

%Configure FIO2 and FIO3 as analog, all else as digital.  That means we
%will start from channel 0 and update all 16 flexible bits.  We will
%pass a value of b0000000000001100 or d12.
[Error] = ljud_ePut(ljHandle, LJ_ioPUT_ANALOG_ENABLE_PORT, 0, 12, 16);
Error_Message(Error)

% Call eGet function to get AIN2 single-ended voltage.
[Error AIN2] = ljud_eGet(ljHandle,LJ_ioGET_AIN,2,0,0);
Error_Message(Error)

% Call eGet function to get AIN3-VREF differential voltage.
[Error AIN3_VREF] = ljud_eGet(ljHandle,LJ_ioGET_AIN_DIFF,3,0,30);
Error_Message(Error)

AIN2 % Display AIN2 value
AIN3_VREF % Display AIN3_VREF value