%
% Demonstrates a few of different timer/counter features using MATLAB, .NET
% and the UD driver.
%
% support@labjack.com
%

clc  % Clear the MATLAB command window
clear  % Clear the MATLAB variables

% Make the UD .NET assembly visible in MATLAB.
ljasm = NET.addAssembly('LJUDDotNet');
ljudObj = LabJack.LabJackUD.LJUD;

try
    % Constant values we will use.
    LJ_ioGET_TIMER = ljudObj.StringToConstant('LJ_ioGET_TIMER');
    LJ_tc750KHZ = ljudObj.StringToConstant('LJ_tc750KHZ');
    LJ_tmPWM8 = ljudObj.StringToConstant('LJ_tmPWM8');
    LJ_tmRISINGEDGES32 = ljudObj.StringToConstant('LJ_tmRISINGEDGES32');
    LJ_tmDUTYCYCLE = ljudObj.StringToConstant('LJ_tmDUTYCYCLE');
    LJ_tmRISINGEDGES16 = ljudObj.StringToConstant('LJ_tmRISINGEDGES16');
    LJE_NO_MORE_DATA_AVAILABLE = ljudObj.StringToConstant('LJE_NO_MORE_DATA_AVAILABLE');

    % Read and display the UD version.
    disp(['UD Driver Version = ' num2str(ljudObj.GetDriverVersion())])

    % Open the first found LabJack UE9.
    [ljerror, ljhandle] = ljudObj.OpenLabJackS('LJ_dtUE9', 'LJ_ctUSB', '0', true, 0);

    % Disable all timers and counters to put everything in a known initial
    % state. Disable the timer and counter, and the FIO lines will return to
    % digital I/O.
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chNUMBER_TIMERS_ENABLED', 0, 0, 0);
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_COUNTER_ENABLE', 0, 0, 0, 0);
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_COUNTER_ENABLE', 1, 0, 0, 0);
    ljudObj.GoOne(ljhandle);

    % First we will output a square wave and count the number of pulses for
    % about 1 second. Connect a jumper on the UE9 from FIO0 (PWM output) to
    % FIO1 (Counter0 input).

    % Use the fixed 750kHz timer clock source.
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chTIMER_CLOCK_BASE', LJ_tc750KHZ, 0, 0);

    % Set the divisor to 3 so the actual timer clock is 250kHz.
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chTIMER_CLOCK_DIVISOR', 3, 0, 0);

    % Enable 1 timer. It will use FIO0.
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chNUMBER_TIMERS_ENABLED', 1, 0, 0);

    % Configure Timer0 as 8-bit PWM. Frequency will be 250k/256 = 977 Hz.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_TIMER_MODE', 0, LJ_tmPWM8, 0, 0);

    % Set the PWM duty cycle to 50%.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_TIMER_VALUE', 0, 32768, 0, 0);

    % Enable Counter0.  It will use FIO1 since 1 timer is enabled.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_COUNTER_ENABLE', 0, 1, 0, 0);

    % Execute the requests on a single LabJack.  The driver will use a single
    % low-level TimerCounter command to handle all the requests above.
    ljudObj.GoOne(ljhandle);

    % Get all the results just to check for errors.
    [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetFirstResult(ljhandle, 0, 0, 0, 0, 0);

    finished = false;
    while finished == false
        try
            [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetNextResult(ljhandle, 0, 0, 0, 0, 0);
        catch e
            if(isa(e, 'NET.NetException'))
                eNet = e.ExceptionObject;
                if(isa(eNet, 'LabJack.LabJackUD.LabJackUDException'))
                    % If we get an error, report it. If the error is
                    % LJE_NO_MORE_DATA_AVAILABLE we are done.
                    if(int32(eNet.LJUDError) == LJE_NO_MORE_DATA_AVAILABLE)
                        finished = true;
                    end
                end
            end
            % Report non LJE_NO_MORE_DATA_AVAILABLE error.
            if(finished == false)
                throw(e)
            end
        end
    end

    % Wait 1 second.
    pause(1);

    % Request a read from the counter.
    [ljerror, dblValue] = ljudObj.eGetS(ljhandle, 'LJ_ioGET_COUNTER', 0, 0, 0);

    % This should read roughly 977.
    disp(['Counter = ' num2str(dblValue)]);

    % Disable the timer and counter, and the FIO lines will return to
    % digital I/O.
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chNUMBER_TIMERS_ENABLED', 0, 0, 0);
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_COUNTER_ENABLE', 0, 0, 0, 0);
    ljudObj.GoOne(ljhandle);

    % Output a square wave and measure the period.
    % Connect a jumper on the UE9 from FIO0 (PWM8 output) to
    % FIO1 (RISINGEDGES32 input) and FIO2 (RISINGEDGES16).

    % Use the fixed 750kHz timer clock source.
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chTIMER_CLOCK_BASE', LJ_tc750KHZ, 0, 0);

    % Set the divisor to 3 so the actual timer clock is 250kHz.
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chTIMER_CLOCK_DIVISOR', 3, 0, 0);

    % Enable 3 timers.
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chNUMBER_TIMERS_ENABLED', 3, 0, 0);

    % Configure Timer0 as 8-bit PWM (LJ_tmPWM8).  Frequency will be 250k/256 = 977 Hz.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_TIMER_MODE', 0, LJ_tmPWM8, 0, 0);

    % Set the PWM duty cycle to 50%.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_TIMER_VALUE', 0, 32768, 0, 0);

    % Configure Timer1 as 32-bit period measurement.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_TIMER_MODE', 1, LJ_tmRISINGEDGES32, 0, 0);

    % Configure Timer2 as 16-bit period measurement.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_TIMER_MODE', 2, LJ_tmRISINGEDGES16, 0, 0);

    % Execute the requests on a single LabJack.  The driver will use a single
    % low-level TimerCounter command to handle all the requests above.
    ljudObj.GoOne(ljhandle);

    % Get all the results just to check for errors.
    [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetFirstResult(ljhandle, 0, 0, 0, 0, 0);

    finished = false;
    while finished == false
        try
            [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetNextResult(ljhandle, 0, 0, 0, 0, 0);
        catch e
            if(isa(e, 'NET.NetException'))
                eNet = e.ExceptionObject;
                if(isa(eNet, 'LabJack.LabJackUD.LabJackUDException'))
                    % If we get an error, report it. If the error is
                    % LJE_NO_MORE_DATA_AVAILABLE we are done.
                    if(int32(eNet.LJUDError) == LJE_NO_MORE_DATA_AVAILABLE)
                        finished = true;
                    end
                end
            end
            % Report non LJE_NO_MORE_DATA_AVAILABLE error.
            if(finished == false)
                throw(e)
            end
        end
    end

    % Wait 1 second.
    pause(1);

    % Now read the period measurements from the 2 timers.  We will use the
    % Add/Go/Get method so that both reads are done in a single low-level call.

    % Request a read from Timer1
    ljudObj.AddRequestS(ljhandle, 'LJ_ioGET_TIMER', 1, 0, 0, 0);

    % Request a read from Timer2
    ljudObj.AddRequestS(ljhandle, 'LJ_ioGET_TIMER', 2, 0, 0, 0);

    % Execute the requests on a single LabJack.  The driver will use a
    % single low-level TimerCounter command to handle all the requests above.
    ljudObj.GoOne(ljhandle);

    % Get the results of the two read requests.
    [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetFirstResult(ljhandle, 0, 0, 0, 0, 0);

    finished = false;
    while finished == false
        switch ioType
            case LJ_ioGET_TIMER
                switch int32(channel)
                    case 1
                        period32 = dblValue;
                    case 2
                        period16 = dblValue;
                end
        end

        try
            [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetNextResult(ljhandle, 0, 0, 0, 0, 0);
        catch e
            if(isa(e, 'NET.NetException'))
                eNet = e.ExceptionObject;
                if(isa(eNet, 'LabJack.LabJackUD.LabJackUDException'))
                    % If we get an error, report it. If the error is
                    % LJE_NO_MORE_DATA_AVAILABLE we are done.
                    if(int32(eNet.LJUDError) == LJE_NO_MORE_DATA_AVAILABLE)
                        finished = true;
                    end
                end
            end
            % Report non LJE_NO_MORE_DATA_AVAILABLE error.
            if(finished == false)
                throw(e)
            end
        end
    end

    % Both period measurements should read about 256.  The timer clock was set
    % to 250 kHz, so each tick equals 4 microseconds, so 256 ticks means a
    % period of 1024 microseconds which is a frequency of 977 Hz.
    disp(['Period32 = ' num2str(period32)]);
    disp(['Period16 = ' num2str(period16)]);

    % Disable the timer and counter, and the FIO lines will return to
    % digital I/O.
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chNUMBER_TIMERS_ENABLED', 0, 0, 0);
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_COUNTER_ENABLE', 0, 0, 0, 0);
    ljudObj.GoOne(ljhandle);

    % Now we will output a 25% duty-cycle PWM output on Timer0 (FIO0) and
    % measure the duty cycle on Timer1 FIO1.  Requires Control firmware V1.21
    % or higher.

    % Use the fixed 750kHz timer clock source (LJ_tc750KHZ).
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chTIMER_CLOCK_BASE', LJ_tc750KHZ, 0, 0);

    % Set the divisor to 3 so the actual timer clock is 250kHz.
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chTIMER_CLOCK_DIVISOR', 3, 0, 0);

    % Enable 2 timers.  They will use FIO0 and FIO1.
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chNUMBER_TIMERS_ENABLED', 2, 0, 0);

    % Configure Timer0 as 8-bit PWM (LJ_tmPWM8). Frequency will be
    % 250k/256 = 977 Hz.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_TIMER_MODE', 0, LJ_tmPWM8, 0, 0);

    % Set the PWM duty cycle to 25%. The passed value is the low time.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_TIMER_VALUE', 0, 49152, 0, 0);

    % Configure Timer1 as duty cycle measurement (LJ_tmDUTYCYCLE).
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_TIMER_MODE', 1, LJ_tmDUTYCYCLE, 0, 0);

    % Execute the requests on a single LabJack.  The driver will use a single
    % low-level TimerCounter command to handle all the requests above.
    ljudObj.GoOne(ljhandle);

    % Get all the results just to check for errors.
    [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetFirstResult(ljhandle, 0, 0, 0, 0, 0);

    finished = false;
    while finished == false
        try
            [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetNextResult(ljhandle, 0, 0, 0, 0, 0);
        catch e
            if(isa(e, 'NET.NetException'))
                eNet = e.ExceptionObject;
                if(isa(eNet, 'LabJack.LabJackUD.LabJackUDException'))
                    % If we get an error, report it. If the error is
                    % LJE_NO_MORE_DATA_AVAILABLE we are done.
                    if(int32(eNet.LJUDError) == LJE_NO_MORE_DATA_AVAILABLE)
                        finished = true;
                    end
                end
            end
            % Report non LJE_NO_MORE_DATA_AVAILABLE error.
            if(finished == false)
                throw(e)
            end
        end
    end

    pause(0.100)

    % Request a read from Timer1.
    [ljerror, dblValue] = ljudObj.eGetS(ljhandle, 'LJ_ioGET_TIMER', 1, 0, 0);

    % High time is LSW
    highTime = double(bitand(uint32(dblValue), 65535));
    % Low time is MSW
    lowTime = double(bitshift(uint32(dblValue), -16));

    disp(['High clicks = ' num2str(highTime)]);
    disp(['Low clicks = ' num2str(lowTime)]);
    disp(['Duty cycle = ' num2str((100*highTime/(highTime+lowTime)))]);

    % Disable the timers, and the FIO lines will return to digital I/O.
    ljudObj.AddRequestSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chNUMBER_TIMERS_ENABLED', 0, 0, 0);
    ljudObj.GoOne(ljhandle);

    % The PWM output sets FIO0 to output, so we do a read here to set FIO0 to
    % input.
    ljudObj.eGetS(ljhandle, 'LJ_ioGET_DIGITAL_BIT', 0, 0, 0);
catch e
    showErrorMessage(e)
end
