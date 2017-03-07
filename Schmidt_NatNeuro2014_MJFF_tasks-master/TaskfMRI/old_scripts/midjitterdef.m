
     
        jitter1=exprv;
        for i=1:length(jitter1)
            if jitter1(i)<0.5
                jitter1(i)=jitter1(i)+0.5;
            elseif jitter1(i)>3
                delta1(i)=jitter1(i)-3;
                jitter1(i)=jitter1(i)-delta1(i);
            end
        end

%        
 

   
meanjitter=mean(jitter1)

figure
plot(jitter1,'r')
hold on
plot(sort(jitter1),'b')
midjitter=jitter1;

% 
% 
%  