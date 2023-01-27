function ready = checkStatus(ip,port,cmd,protocolNum)
    %Poor man's callback to interact with Pathway system remotely
    %Because Pathway system states needs to go from IDLE -> PRETEST -> TEST
    %It's not possible to simply trigger a protocol from IDLE.
    %Additionally, PRETEST can take a variable amount of time and occasionally not run at all
    %This function polls the system state and returns a ready status when the pretest has successfully been executed so that a later command in an experiment script can reliably start a protocol
    %If the pretest has not started, it will re-call the command provided until the pretest has begun
    %
    %Inputs:
    %ip: ip of Pathway system
    %port: port of Pathway system
    %cmd: typically main(), written by Pathway folks
    %protocolNum: program to run on pathway machine, which will be passed to cmd()

    %Outputs:
    %ready: whether the system is ready to receive a trigger

    %Usage:
    %%Within a trial loop
    %if checkStatus(ip,port,@main,myProtocol);
    %   main(ip,port,4,myProtocol)
    %end

    ready = 0;
    while ~ready
        WaitSecs(1);
        resp = main(ip,port,0); %get system status
        systemState = resp{4}; testState = resp{5};
        %If pretest has been started return a ready code == 1
        if strcmp(systemState, 'Pathway State: TEST') && strcmp(testState,'Test State: RUNNING')
            ready = 1;
        %Other wise resend the command to start the pretest for the given protocol
        elseif strcmp(systemState, 'Pathway State: READY') && strcmp(testState,'Test State: IDLE')
            cmd(ip,port1,protocolNum)
        end
    end
end
