%
% Demonstrates the UD E-functions with the LabJack U3, MATLAB, .NET and the
% UD driver.
%
% support@labjack.com
%

clc  % Clear the MATLAB command window
clear  % Clear the MATLAB variables

% Make the UD .NET assembly visible in MATLAB.
ljasm = NET.addAssembly('LJUDDotNet');
ljudObj = LabJack.LabJackUD.LJUD;

try
    % Read and display the UD version.
    disp(['UD Driver Version = ' num2str(ljudObj.GetDriverVersion())])

    % Open the first found LabJack U3.
    [ljerror, ljhandle] = ljudObj.OpenLabJackS('LJ_dtU3', 'LJ_ctUSB', '0', true, 0);

    % Start by using the pin_configuration_reset IOType so that all pin
    % assignments are in the factory default condition.
    ljudObj.ePutS(ljhandle, 'LJ_ioPIN_CONFIGURATION_RESET', 0, 0, 0);

    % Take a single-ended measurement from AIN3.
    channelP = 3;
    channelN = 31;
    voltage = 0.0;
    range = 0;  % Not applicable for the the U3
    resolution = 0;
    settling = 0;
    binary = 0;
    [ljerror, voltage] = ljudObj.eAIN(ljhandle, channelP, channelN, voltage, range, resolution, settling, binary);
    disp(['AIN3 = ' num2str(voltage) ' V'])

    % Set DAC0 to 3.0 volts.
    channel = 0;
    voltage = 3.0;
    binary = 0;
    ljudObj.eDAC(ljhandle, 0, voltage, binary, 0, 0);
    disp(['DAC0 set to ' num2str(voltage) ' V'])

    % Read state of FIO4.
    channel = 4;
    state = 0;
    [ljerror, state] = ljudObj.eDI(ljhandle, channel, state);
    disp(['FIO4 = ' num2str(state)])

    % Set the state of FIO7.
    channel = 7;
    state = 1;
    ljudObj.eDO(ljhandle, channel, state);
    disp(['FIO7 set to ' num2str(state)])

    % Timers and Counters example.

    % Create arrays and get constant values.
    aEnableTimers = NET.createArray('System.Int32', 2);
    aEnableCounters = NET.createArray('System.Int32', 2);
    aTimerModes = NET.createArray('System.Int32', 2);
    aEnableCounters = NET.createArray('System.Int32', 2);
    aReadTimers = NET.createArray('System.Int32', 2);
    aUpdateResetTimers = NET.createArray('System.Int32', 2);
    aReadCounters = NET.createArray('System.Int32', 2);
    aResetCounters = NET.createArray('System.Int32', 2);
    aTimerValues = NET.createArray('System.Double', 2);
    aCounterValues = NET.createArray('System.Double', 2);

    LJ_tc48MHZ_DIV = ljudObj.StringToConstant('LJ_tc48MHZ_DIV');
    LJ_tc48MHZ = ljudObj.StringToConstant('LJ_tc48MHZ');
    %LJ_tc24MHZ_DIV = ljudObj.StringToConstant('LJ_tc24MHZ_DIV');  % Use this line instead for old hardware rev 1.20.
    %LJ_tc24MHZ = ljudObj.StringToConstant('LJ_tc24MHZ');  % Use this line instead for old hardware rev 1.20.
    LJ_tmPWM8 = ljudObj.StringToConstant('LJ_tmPWM8');
    LJ_tmDUTYCYCLE = ljudObj.StringToConstant('LJ_tmDUTYCYCLE');

    % First, a call to eTCConfig.  Fill the arrays with the desired values,
    % then make the call.

    aEnableTimers(1) = 1;  % Enable Timer0 (uses FIO4).
    aEnableTimers(2) = 1;  % Enable Timer1 (uses FIO5).
    aEnableCounters(1) = 0;  % Disable Counter0.
    aEnableCounters(2) = 1;  % Enable Counter1 (uses FIO6).
    tcPinOffset = 4;  % Offset is 4, so timers/counters start at FIO4.
    timerClockBaseIndex = LJ_tc48MHZ_DIV;  % Base clock is 48 MHz with divisor support, so Counter0 is not available.
    % timerClockBaseIndex = LJ_tc24MHZ_DIV;  % Use this line instead for old hardware rev 1.20.
    timerClockDivisor = 48;  % Thus timer clock is 1 MHz.
    % timerClockDivisor = 24;  % Use this line instead for old hardware rev 1.20.
    aTimerModes(1) = LJ_tmPWM8;  % Timer0 is 8-bit PWM output. Frequency is 1M/256 = 3906 Hz.
    aTimerModes(2) = LJ_tmDUTYCYCLE;  % Timer1 is duty cyle input.
    aTimerValues(1) = 16384;  % Set PWM8 duty-cycle to 75%.
    aTimerValues(2) = 0;
    ljudObj.eTCConfig(ljhandle, aEnableTimers, aEnableCounters, tcPinOffset, timerClockBaseIndex, timerClockDivisor, aTimerModes, aTimerValues, 0, 0);
    disp(['Timers and Counters enabled.'])

    pause(1);  % Wait 1 second.

    % Now, a call to eTCValues.
    aReadTimers(1) = 0;  % Don't read Timer0 (output timer).
    aReadTimers(2) = 1;  % Read Timer1.
    aUpdateResetTimers(1) = 1;  % Update Timer0.
    aUpdateResetTimers(2) = 1;  % Reset Timer1.
    aReadCounters(1) = 0;
    aReadCounters(2) = 1;  % Read Counter1.
    aResetCounters(1) = 0;
    aResetCounters(2) = 1;  % Reset Counter1.
    aTimerValues(1) = 32768;  % Change Timer0 duty-cycle to 50%.
    aTimerValues(2) = 0;
    ljudObj.eTCValues(ljhandle, aReadTimers, aUpdateResetTimers, aReadCounters, aResetCounters, aTimerValues, aCounterValues, 0, 0);
    disp(['Timer1 value = ' num2str(aTimerValues(2))])
    disp(['Counter1 value = ' num2str(aCounterValues(2))])

    % Convert Timer1 value to duty-cycle percentage.
    % High time is LSW.
    highTime = mod(aTimerValues(2), 65536);
    % Low time is MSW.
    lowTime = aTimerValues(2) / 65536;
    % Calculate the duty cycle percentage.
    dutyCycle = 100*highTime/(highTime+lowTime);
    disp(['High clicks Timer1 = ' num2str(highTime)])
    disp(['Low clicks Timer1 = ' num2str(lowTime)])
    disp(['Duty cycle Timer1 = ' num2str(dutyCycle)])

    % Disable all timers and counters.
    aEnableTimers(1) = 0;
    aEnableTimers(2) = 0;
    aEnableCounters(1) = 0;
    aEnableCounters(2) = 0;
    tcPinOffset = 4;
    timerClockBaseIndex = LJ_tc48MHZ;
    %timerClockBaseIndex = LJ_tc24MHZ;  % Use this line instead for old hardware rev 1.20.
    ljudObj.eTCConfig(ljhandle, aEnableTimers, aEnableCounters, tcPinOffset, timerClockBaseIndex, timerClockDivisor, aTimerModes, aTimerValues, 0, 0);

catch e
    showErrorMessage(e)
end
