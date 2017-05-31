rand('state',sum(100*clock));
for i=1:100 
    clear all;
        jitter1=random('exp',2,32,1);
        for i=1:length(jitter1)
            if jitter1(i)<2
                jitter1(i)=jitter1(i)+2;
            elseif jitter1(i)>6
                delta1(i)=jitter1(i)-6;
                jitter1(i)=jitter1(i)-delta1(i);
            end
        end

%         if round(max(jitter1))<=6
%             break;
%         end
%     end
%     
%     
        jitter2=random('exp',2,32,1);
        for i=1:length(jitter2)
            if jitter2(i)<2
                jitter2(i)=jitter2(i)+2;
            elseif jitter2(i)>6
                delta2(i)=jitter2(i)-6;
                jitter2(i)=jitter2(i)-delta2(i);
            end
        end
% 
%         if round(max(jitter2))<=6
%             break;
%         end
%     end
%     
   

    jitter(1:32,1)=(jitter1);
    jitter(33:64,1)=(jitter2);
 

   
meanjitter=mean(jitter)
if meanjitter<=3
    

% return


plot((jitter),'b')
break;
end

end
% % 
% 
% 
%  