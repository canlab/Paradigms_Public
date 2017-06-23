fs=8000;
periode=0.4; %2.5 Hz
dutyCicle=0.5;
nMostres=fs*periode*dutyCicle;
load tonsBIRN.mat; % carrega el vector tons
totOut=zeros(periode*fs*dutyCicle,2);

%==========================================================================
base=(0:1/fs:(periode*fs*dutyCicle-1)/fs)';
for i=1:length(tons)
   out=0.95*sin(2*pi*tons(i)*base); %sinus, no hi ha clic inicial
   out(end-20:end)=out(end-20:end).*((21:-1:1)/22)'; %mato els "clics" finals
   out= [out out];
   sound(out,8000);
   disp(i);
   pause
   totOut=[totOut;out;zeros(periode*fs*dutyCicle,2)];
   wavwrite(out,8000,['to' num2str(i)]);
   
   
end

sound(totOut);