%
% Demonstrates the UD E-functions with the LabJack UE9, MATLAB, .NET and the
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

    % Open the first found LabJack UE9.
    [ljerror, ljhandle] = ljudObj.OpenLabJackS('LJ_dtUE9', 'LJ_ctUSB', '0', true, 0);

    % Take a single-ended measurement from AIN3, +/-5 V range.
    channelP = 3;
    channelN = 0;  % Not applicable for the the UE9
    voltage = 0.0;
    LJ_rgUNI5V = ljudObj.StringToConstant('LJ_rgUNI5V');
    range = LJ_rgUNI5V;
    resolution = 16;
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

    % Read state of FIO0.
    channel = 0;
    state = 0;
    [ljerror, state] = ljudObj.eDI(ljhandle, channel, state);
    disp(['FIO0 = ' num2str(state)])

    % Set the state of FIO3.
    channel = 3;
    state = 1;
    ljudObj.eDO(ljhandle, channel, state);
    disp(['FIO3 set to ' num2str(state)])

    % Timers and Counters example.

    % Create arrays and get constant values.
    aEnableTimers = NET.createArray('System.Int32', 6);
    aEnableCounters = NET.createArray('System.Int32', 2);
    aTimerModes = NET.createArray('System.Int32', 6);
    aEnableCounters = NET.createArray('System.Int32', 2);
    aReadTimers = NET.createArray('System.Int32', 6);
    aUpdateResetTimers = NET.createArray('System.Int32', 6);
    aReadCounters = NET.createArray('System.Int32', 2);
    aResetCounters = NET.createArray('System.Int32', 2);
    aTimerValues = NET.createArray('System.Double', 6);
    aCounterValues = NET.createArray('System.Double', 2);

    LJ_tc750KHZ = ljudObj.StringToConstant('LJ_tc750KHZ');
    LJ_tcSYS = ljudObj.StringToConstant('LJ_tcSYS');
    LJ_tmPWM8 = ljudObj.StringToConstant('LJ_tmPWM8');
    LJ_tmDUTYCYCLE = ljudObj.StringToConstant('LJ_tmDUTYCYCLE');

    % First, a call to eTCConfig.  Fill the arrays with the desired values,
    % then make the call.

    aEnableTimers(1) = 1;  % Enable Timer0 (uses FIO0).
    aEnableTimers(2) = 1;  % Enable Timer1 (uses FIO1).
    aEnableTimers(3) = 0;  % Disable Timer2.
    aEnableTimers(4) = 0;  % Disable Timer3.
    aEnableTimers(5) = 0;  % Disable Timer4.
    aEnableTimers(6) = 0;  % Disable Timer5.
    aEnableCounters(1) = 0;  % Disable Counter0.
    aEnableCounters(2) = 1;  % Enable Counter1 (uses FIO2).
    tcPinOffset = 0;  % Not applicable for the the UE9. Timers/counters start at FIO0.
    timerClockBaseIndex = LJ_tc750KHZ;  % Base clock is 750 kHz.
    timerClockDivisor = 1;  % Divide base clock by 1, thus timer clock is 750 kHz.
    aTimerModes(1) = LJ_tmPWM8;  % Timer0 is 8-bit PWM output. Frequency is 750K/256 = 2929 Hz.
    aTimerModes(2) = LJ_tmDUTYCYCLE;  % Timer1 is duty cyle input.
    aTimerModes(3) = 0;  % Timer2 not enabled.
    aTimerModes(4) = 0;  % Timer3 not enabled.
    aTimerModes(5) = 0;  % Timer4 not enabled.
    aTimerModes(6) = 0;  % Timer5 not enabled.
    aTimerValues(1) = 16384;  % Set PWM8 duty-cycle to 75%.
    aTimerValues(2) = 0;
    aTimerValues(3) = 0;
    aTimerValues(4) = 0;
    aTimerValues(5) = 0;
    aTimerValues(6) = 0;
    ljudObj.eTCConfig(ljhandle, aEnableTimers, aEnableCounters, tcPinOffset, timerClockBaseIndex, timerClockDivisor, aTimerModes, aTimerValues, 0, 0);
    disp(['Timers and Counters enabled.'])

    pause(1);  % Wait 1 second.

    % Now, a call to eTCValues.
    aReadTimers(1) = 0;  % Don't read Timer0 (output timer).
    aReadTimers(2) = 1;  % Read Timer1.
    aReadTimers(3) = 0;  % Timer2 not enabled.
    aReadTimers(4) = 0;  % Timer3 not enabled.
    aReadTimers(5) = 0;  % Timer4 not enabled.
    aReadTimers(6) = 0;  % Timer5 not enabled.
    aUpdateResetTimers(1) = 1;  % Update Timer0.
    aUpdateResetTimers(2) = 1;  % Reset Timer1.
    aUpdateResetTimers(3) = 0;
    aUpdateResetTimers(4) = 0;
    aUpdateResetTimers(5) = 0;
    aUpdateResetTimers(6) = 0;
    aReadCounters(1) = 0;
    aReadCounters(2) = 1;  % Read Counter1.
    aResetCounters(1) = 0;
    aResetCounters(2) = 1;  % Reset Counter1.
    aTimerValues(1) = 32768;  % Change Timer0 duty-cycle to 50%.
    aTimerValues(2) = 0;
    aTimerValues(3) = 0;
    aTimerValues(4) = 0;
    aTimerValues(5) = 0;
    aTimerValues(6) = 0;
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
    aEnableTimers(3) = 0;
    aEnableTimers(4) = 0;
    aEnableTimers(5) = 0;
    aEnableTimers(6) = 0;
    aEnableCounters(1) = 0;
    aEnableCounters(2) = 0;
    tcPinOffset = 0;
    timerClockBaseIndex = LJ_tcSYS;
    ljudObj.eTCConfig(ljhandle, aEnableTimers, aEnableCounters, tcPinOffset, timerClockBaseIndex, timerClockDivisor, aTimerModes, aTimerValues, 0, 0);

catch e
    showErrorMessage(e)
end
