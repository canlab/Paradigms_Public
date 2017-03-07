% Estimate best parameters for Q-learning with maximal log likelihood

clear all;
close all;


nsub=1;
bestpara=zeros(2,3);


for sub=[1 2 5 7 12]
    fprintf('subject %d\n',sub);
    nsub=nsub+1;
    logtotal=zeros(10,10);
    loggain=zeros(10,10);
    logneutral=zeros(10,10);

    if sub==1
        for alpha=1:10
            for beta=1:10

                probatotal=0;
                probagain=0;
                probaneutral=0;
                probaloss=0;
                proba=zeros(90,1);
                error=zeros(90,1);

                for nsession=1:2
                    resultname=strcat('ILtestSub1Session',num2str(nsession));
                    load (resultname);
                    q=zeros(3,2);


                    for n=1:90
                        pair=data(n,3);
                        response=zeros(1,2);
                        response((data(n,7)~=1)+1)=1;
                        reward=(pair==1&data(n,8)==1)+(pair==2&data(n,8)==1)-(pair==3&data(n,8)==-1);
                        proba(n)=1/(1+exp(-diff(response)*diff(q(pair,:))/(beta*0.1)));
                        error(n)=reward-q(pair,:)*response';
                        q(pair,:)=q(pair,:)+0.1*alpha*response*error(n);

                    end

                    probatotal=probatotal+mean(log(proba(data(:,3)==1 | data(:,3)==2 | data(:,3)==3)));
                    probagain=probagain+mean(log(proba(data(:,3)==1)));
                    probaneutral=probaneutral+mean(log(proba(data(:,3)==2)));
                    probaloss=probaloss+mean(log(proba(data(:,3)==3)));
                end

                logtotal(alpha,beta)=probatotal;
                loggain(alpha,beta)=probagain;
                logneutral(alpha,beta)=probaneutral;

            end
        end

    else

        for alpha=1:10
            for beta=1:10

                probatotal=0;
                probagain=0;
                probaneutral=0;
                proba=zeros(60,2);
                error=zeros(60,2);

                for nsession=1:2
                    resultname=strcat('ILtestSub',num2str(sub),'Session',num2str(nsession));
                    load (resultname);
                    q=zeros(2,2);


                    for n=1:60
                        pair=data(n,3);
                        response=zeros(1,2);
                        response((data(n,8)~=1)+1)=1;
                        reward=(pair==1&data(n,9)==1)+(pair==2&data(n,9)==1);
                        proba(n)=1/(1+exp(-diff(response)*diff(q(pair,:))/(beta*0.1)));
                        error(n)=reward-q(pair,:)*response';
                        q(pair,:)=q(pair,:)+0.1*alpha*response*error(n);

                    end

                    probatotal=probatotal+mean(log(proba(data(:,3)==1 | data(:,3)==2)));
                    probagain=probagain+mean(log(proba(data(:,3)==1)));
                    probaneutral=probaneutral+mean(log(proba(data(:,3)==2)));
                end

                logtotal(alpha,beta)=probatotal;
                loggain(alpha,beta)=probagain;
                logneutral(alpha,beta)=probaneutral;

            end
        end
    end

    logmaxtotal=[max(max(logtotal))];
    logmaxgain=[max(max(loggain))];
    logmaxneutral=[max(max(logneutral))];
    [bestalpha(1),bestbeta(1)]=find(logtotal==logmaxtotal(1));
    [bestalphagain(1),bestbetagain(1)]=find(loggain==logmaxgain(1));
    [bestalphaneutral(1),bestbetaneutral(1)]=find(logneutral==logmaxneutral(1));
    estim{sub}=[exp(logmaxtotal);0.1*bestalpha;0.1*bestbeta];
    estimgain{sub}=[exp(logmaxgain);0.1*bestalphagain;0.1*bestbetagain];
    estimneutral{sub}=[exp(logmaxneutral);0.1*bestalphaneutral;0.1*bestbetaneutral];
    bestpara(1,1)=bestalpha;
    bestpara(1,2)=bestbeta;

end

meanlogmax=[max(max(logtotal))];
[bestalpha(1),bestbeta(1)]=find(logtotal==meanlogmax(1));
bestestim=[0.1*bestalpha;0.1*bestbeta];
bestpara(1,1)=bestalpha;
bestpara(1,2)=bestbeta;

meanlogmaxgain=[max(max(loggain))];
[bestalphagain(1),bestbetagain(1)]=find(loggain==meanlogmaxgain(1));
bestestimgain=[0.1*bestalphagain;0.1*bestbetagain];
bestparagain(1,1)=bestalphagain;
bestparagain(1,2)=bestbetagain;

meanlogmaxneutral=[max(max(logneutral))];
[bestalphaneutral(1),bestbetaneutral(1)]=find(logneutral==meanlogmaxneutral(1));
bestestimneutral=[0.1*bestalphaneutral;0.1*bestbetaneutral];
bestparaneutral(1,1)=bestalphaneutral;
bestparaneutral(1,2)=bestbetaneutral;

