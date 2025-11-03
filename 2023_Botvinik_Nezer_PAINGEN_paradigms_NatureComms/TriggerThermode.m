function [t] = TriggerThermode(temp, varargin)
    USE_BIOPAC = false;
    
    for i = 1:length(varargin)
        switch varargin{i}
            case 'USE_BIOPAC'
                USE_BIOPAC = varargin{i+1};
        end
    end
    
    ljasm = NET.addAssembly('LJUDDotNet');
    ljudObj = LabJack.LabJackUD.LJUD;

    [~, ljhandle] = ljudObj.OpenLabJackS('LJ_dtU3', 'LJ_ctUSB', '0', true, 0);
    ljudObj.ePutS(ljhandle, 'LJ_ioPIN_CONFIGURATION_RESET', 0, 0, 0);

    % calculate byte code
    % Integer values are simply converted to binary, non integer values are
    % incremented by 128 and converted to binary. So 45 is bin(45) while
    % 45.5 is bin(45+128).
    if(mod(temp,1))
        % note: this will treat all decimal values the same. Specific
        % temperature mapping is determined in PATHWAY software
        temp = floor(temp) + 128;
    end
    bytecode=sprintf('%08.0f',str2double(dec2bin(temp)))-'0';

    for i=0:7
        % Initiate FIO0 to FIO7 output
        ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT',i, bytecode(i+1), 0, 0);

        if USE_BIOPAC
            % Initiate CIO3 and EIO7 output (biopac)
            ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', i+8, bytecode(i+1), 0, 0);    
        end
    end

    % Wait for 1 second. The delay is performed in the U3 hardware, and delay time is in microseconds.
    % Valid delay values are 0 to 4194176 microseconds, and resolution is 128 microseconds.
    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_WAIT', 0, 1000000, 0, 0);


    for i=0:7
          % Terminate FIO0 to FIO7 output (reset to 0)
          ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, i, 0, 0, 0);

          if USE_BIOPAC
              % Terminate CIO3 and EIO7 output (reset to 0)
              % Note: this sends a binary code to biopac channels (likely
              % D8-D15).
              ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, i+8,0, 0, 0);
          end
    end

    t = GetSecs;
    % Perform the operations/requests
    ljudObj.GoOne(ljhandle);
end