function thermodePrime(ip)
% This is a quick Matlab commandline program to trigger thermode stimulation to
% 4 sites in sequence for 10s each

%Input args:
% ip : ip of the Medoc laptop in External Control Mode

%Works by calling the main() program which takes 4 arguments:
%1) ip of the Medoc machine
%2) open port of the Medoc machine
%3) command code to issue; I believe 0 = get system status, 4 = start, 5 = stop
%4) program name to execute this is a decimal value that maps on to the 8-bit
%binary code of the program built in the pathway program (e.g. 100 below ==
%1100100), which is a program created to deliver pain at a constant temperature
%for 10s)

port = 20121; %use a constant variable cause this doesn't really change
sites = [1,2,3,4];
for i = 1:length(sites)
    fprintf(['Place the thermode on site: ' num2str(sites(i)) '\n']);
    fprintf('Press spacebar to begin stimulation\n');
    KbStrokeWait;
    main(ip,port,1,100);
    if checkStatus(ip,port)
        main(ip,port,4,100);
        sTime = GetSecs;
        while GetSecs - sTime <= 15
            %wait till pain finishes
        end
        main(ip,port,5,100);
    end
end