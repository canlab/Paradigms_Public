% Estimate best parameters for Q-learning with maximal log likelihood
% 3 symbol pairs: 1==gain pair; 2==neutral pair; 3== loss pair

clear all;
close all;

meanloggain=zeros(10,10);
nsub=0;


for sub=2:30
    fprintf('subject %d\n',nsub);
    nsub=nsub+1;
    loggain=zeros(10,10);



    for alpha=1:10

        for beta=1:10

            probagain=0;
            probalook=0;
            probaloss=0;


            for nsession=2:3
                resultname=strcat('ILtestSub',num2str(sub),'Session',num2str(nsession));
                load (resultname);
                q=zeros(3,2);
                proba=zeros(90,1);
                error=zeros(90,1);

                for n=1:90
                    pair=data(n,3);
                    response=zeros(1,2);
                    response((data(n,6)~=1)+1)=1;
                    reward=(pair==1&data(n,7)==1)+(pair==2&data(n,7)==1)-(pair==3&data(n,7)==-1);
                    proba(n)=1/(1+exp(-diff(response)*diff(q(pair,:))/(beta*0.1)));
                    error(n)=reward-q(pair,:)*response';
                    q(pair,:)=q(pair,:)+0.1*alpha*response*error(n);
                end

                probagain=probagain+mean(log(proba(data(:,3)==1 | data(:,3)==3)))/2;

            end

            loggain(alpha,beta)=probagain;
%            
        end
    end
   
    
    logmax=[max(max(loggain))];
    [bestalpha(1),bestbeta(1)]=find(loggain==logmax(1));

    estim{nsub}=[exp(logmax);0.1*bestalpha;0.1*bestbeta];
    

    
end

meanlogmax=[max(max(loggain))];
[bestalpha(1),bestbeta(1)]=find(loggain==meanlogmax(1));
bestestim=[0.1*bestalpha;0.1*bestbeta];

