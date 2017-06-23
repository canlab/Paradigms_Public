% Estimates choice probabilities with mean goup parameters

clear all;
close all;


nsub=1;
bestalphagroup=1;
bestbetagroup=4;
allproba=zeros(120,6);
allerror=zeros(120,6);

for sub=[1 2 5 7 12]
    fprintf('subject %d\n',sub);
    nsub=nsub+1;

    if sub==1
        proba=zeros(90,2);
        error=zeros(90,2);

        i=1;
        j=90;

        for nsession=1:2
            resultname=strcat('ILtestSub',num2str(sub),'Session',num2str(nsession));
            load (resultname);
            q=zeros(3,2);

            for n=1:90
                pair=data(n,3);
                response=zeros(1,2);
                response((data(n,7)~=1)+1)=1;
                reward=(pair==1&data(n,8)==1)+(pair==2&data(n,8)==1)-(pair==3&data(n,8)==-1);
                proba(n)=1/(1+exp(-diff(response)*diff(q(pair,:))/(bestbetagroup*0.1)));
                error(n)=reward-q(pair,:)*response';
                q(pair,:)=q(pair,:)+0.1*bestalphagroup*response*error(n);

            end

            proba(:,2)=data(:,3);
            error(:,2)=data(:,3);
            proba=sortrows(proba,2);
            error=sortrows(error,2);
            allproba(i:j,sub)=proba(:,1);
            allerror(i:j,sub)=error(:,1);
            i=i+90;
            j=j+90;

        end

    else

        proba=zeros(60,2);
        error=zeros(60,2);

        i=1;
        j=60;

        for nsession=1:2
            resultname=strcat('ILtestSub',num2str(sub),'Session',num2str(nsession));
            load (resultname);
            q=zeros(2,2);

            for n=1:60
                pair=data(n,3);
                response=zeros(1,2);
                response((data(n,8)~=1)+1)=1;
                reward=(pair==1&data(n,9)==1)+(pair==2&data(n,9)==1);
                proba(n,1)=1/(1+exp(-diff(response)*diff(q(pair,:))/(bestbetagroup*0.1)));
                error(n,1)=reward-q(pair,:)*response';
                q(pair,:)=q(pair,:)+0.1*bestalphagroup*response*error(n);

            end

            proba(:,2)=data(:,3);
            error(:,2)=data(:,3);
            proba=sortrows(proba,2);
            error=sortrows(error,2);
            allproba(i:j,sub)=proba(:,1);
            allerror(i:j,sub)=error(:,1);
            i=i+60;
            j=j+60;

        end
    end
end

     
   

