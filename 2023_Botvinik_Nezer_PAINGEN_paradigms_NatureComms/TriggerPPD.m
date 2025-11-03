% message_1 is supposed to provide errors on the initialization command

function [timestamp, message_1] = TriggerPPD(pressure, time, varargin)
    global t r; % pressure device udp channel
    
    USE_BIOPAC = false;
    
    for i = 1:length(varargin)
        switch varargin{i}
            case 'USE_BIOPAC'
                USE_BIOPAC = varargin{i+1};
        end
    end
    
    %push pressure info to bio pac
    if USE_BIOPAC
        ljasm = NET.addAssembly('LJUDDotNet');
        ljudObj = LabJack.LabJackUD.LJUD;

        [~, ljhandle] = ljudObj.OpenLabJackS('LJ_dtU3', 'LJ_ctUSB', '0', true, 0);
        ljudObj.ePutS(ljhandle, 'LJ_ioPIN_CONFIGURATION_RESET', 0, 0, 0);
        
        bytecode=sprintf('%08.0f',str2double(dec2bin(pressure)))-'0';

        for i=0:7
            % Initiate CIO3 and EIO7 output (biopac)
            ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', i+8, bytecode(i+1), 0, 0);    
        end
        
        %biopac pulse width in ms (1000000ms = 1s)
        ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_WAIT', 0, 1000000, 0, 0);

        for i=0:7
              % Terminate CIO3 and EIO7 output (reset to 0)
              % Note: this sends a binary code to biopac channels (likely
              % D8-D15).
              ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, i+8,0, 0, 0);
        end
    end %end biopac push
        
    if pressure > 10 || pressure < 0 %change constraints as needed, but these seem sensible at the moment
        error('Pressure must be a positive integer between 0 and 10');
    end
    
    if ischar(time)
        timestr = time;
        time = str2num(time);
        warning(['Pressure duration supplied as string (' timestr ')\nConverting to numeric datatype: ' time]);
    end

    if time > 75 || time < 0 % change constraint if needed, but this seems like a sensible upper bound
        error('Time must be positive integer between 0 and 75');
    end
    pressure = sprintf('%04.0f',pressure);

    try
        timestamp = GetSecs;
        if USE_BIOPAC
            ljudObj.GoOne(ljhandle);
        end
        fwrite(t, [pressure ',t']); % start pressure
        message_1 = deblank(fscanf(r));
        pause(time);
        fwrite(t,[pressure ',s']);
    catch err
        % ERROR
        disp(err);
        disp(err.stack(1));
        disp(err.stack(2));
        disp(err.stack(end));
        fclose(t);
        fclose(r);
        abort_error;
    end
    
end