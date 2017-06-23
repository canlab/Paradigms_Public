% Estimates choice probabilities with mean goup parameters

clear all;
close all;


nsub=1;
bestalphagroup=1;
bestbetagroup=8;
allproba=zeros(128,6);
allerror=zeros(128,6);

for sub=[1 2 3 5 6 7]
    fprintf('subject %d\n',sub);
    nsub=nsub+1;

    if sub==1
        proba=zeros(64,2);
        error=zeros(64,2);

        i=1;
        j=64;

        for nsession=1:2
            resultname=strcat('ILtestVersin4Sub',num2str(sub),'Session',num2str(nsession));
            load (resultname);
            q=zeros(3,2);

            for n=1:64
                pair=data(n,3);
                response=zeros(1,2);
                response((data(n,7)~=1)+1)=1;
                reward=(pair==1&data(n,8)==1)+(pair==2&data(n,8)==1);
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
            i=i+64;
            j=j+64;

        end
    end
%     else
% 
%         proba=zeros(64,2);
%         error=zeros(64,2);
% 
%         i=1;
%         j=60;
% 
%         for nsession=1:2
%             resultname=strcat('ILtestSub',num2str(sub),'Session',num2str(nsession));
%             load (resultname);
%             q=zeros(2,2);
% 
%             for n=1:60
%                 pair=data(n,3);
%                 response=zeros(1,2);
%                 response((data(n,8)~=1)+1)=1;
%                 reward=(pair==1&data(n,9)==1)+(pair==2&data(n,9)==1);
%                 proba(n,1)=1/(1+exp(-diff(response)*diff(q(pair,:))/(bestbetagroup*0.1)));
%                 error(n,1)=reward-q(pair,:)*response';
%                 q(pair,:)=q(pair,:)+0.1*bestalphagroup*response*error(n);
% 
%             end
% 
%             proba(:,2)=data(:,3);
%             error(:,2)=data(:,3);
%             proba=sortrows(proba,2);
%             error=sortrows(error,2);
%             allproba(i:j,sub)=proba(:,1);
%             allerror(i:j,sub)=error(:,1);
%             i=i+60;
%             j=j+60;
% 
%         end
%     end
% end

     
   

