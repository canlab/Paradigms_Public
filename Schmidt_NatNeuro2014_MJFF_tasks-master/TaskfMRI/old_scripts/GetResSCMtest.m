clear all;
close all;


nsub=1;
session=3;
totaltrial=80;

choice=zeros(80,session);
reactime=zeros(80,session);
movtime=zeros(80,session);

h=1;
i=2;
j=3;
g=4;

idx=230;
var=0;
for sub=1
    for nsession=1:3
    if sub==1
        xcenter=640;
        ycenter=400;

    else
        xcenter=400;
        ycenter=300;
    end
    
    screenHeight=ycenter*2;
    screenWidth=xcenter*2;
    myrects(:,1)=[xcenter-35 0 xcenter+35 70];
    myrects(:,2)=[(xcenter+(ycenter*cos(pi/4)))-70 (ycenter-(ycenter*sin(pi/4))) xcenter+(ycenter*cos(pi/4)) ycenter-(ycenter*sin(pi/4))+70];
    myrects(:,3)=[(xcenter+ycenter)-70 ycenter-35 (xcenter+ycenter) ycenter+35];
    myrects(:,4)=[(xcenter+(ycenter*cos(pi/4)))-70 (ycenter+(ycenter*sin(pi/4)))-70 xcenter+(ycenter*cos(pi/4)) ycenter+(ycenter*sin(pi/4))];
    myrects(:,5)=[xcenter-35 screenHeight-70 xcenter+35 screenHeight];
    myrects(:,6)=[(xcenter-(ycenter*cos(pi/4))) (ycenter+(ycenter*sin(pi/4)))-70 xcenter-(ycenter*cos(pi/4))+70 ycenter+(ycenter*sin(pi/4))];
    myrects(:,7)=[(xcenter-ycenter) ycenter-35 (xcenter-ycenter)+70 ycenter+35];
    myrects(:,8)=[(xcenter-(ycenter*cos(pi/4))) (ycenter-(ycenter*sin(pi/4))) xcenter-(ycenter*cos(pi/4))+70 ycenter-(ycenter*sin(pi/4))+70];

    fprintf('subject %d\n',sub);
    resultname=strcat('SCMTtestPilotCalibSub',num2str(sub),'Session',num2str(nsession),'.mat');
    load (resultname);

    newdata(:,1)=data(:,3); %condition
    newdata(:,2)=data(:,4); %choice

    %reactiontime
    for trial=1:80
        alldata(trial,h)=trial;
        mX=find(lesPointsX(:,trial)~=xcenter);
        mY=find(lesPointsY(:,trial)~=ycenter);
        xydiff=length(mX)-length(mY);
        yxdiff=length(mY)-length(mX);
        if xydiff>0
            reactime(trial,nsession)=mX(1,1)*0.01;
        else
            reactime(trial,nsession)=mY(1,1)*0.01;
        end

    end



    alldata(:,h)=newdata(:,1);
    alldata(:,i)=newdata(:,2);
    alldata(:,j)=reactime(:,nsession);

    for trial=1:80
        for pos=1:8;
            a=find(lesPointsX(1:idx,trial)>=myrects(1,pos)-var & lesPointsX(1:idx,trial)<=myrects(3,pos)+var);
            b=find(lesPointsY(1:idx,trial)>=myrects(2,pos)-var & lesPointsY(1:idx,trial)<=myrects(4,pos)+var);

            if isempty(a) | isempty(b)
                continue;

            else

                if length(a)>length(b) && length(a)>3 && length(b)>3
                    x=lesPointsX(b(end-3,1),trial);
                    y=lesPointsY(b(end-3,1),trial);

                    if x>=myrects(1,pos)-var && x<=myrects(3,pos)+var && y>=myrects(2,pos)-var && y<=myrects(4,pos)+var
                        movtime(trial,nsession)=b(1,1)*0.01;
                        choice(trial,nsession)=pos;
                        break;
                    else
                        continue;
                    end
                elseif length(a)>length(b) && length(a)<3 && length(b)<3
                    x=lesPointsX(b(end,1),trial);
                    y=lesPointsY(b(end,1),trial);

                    if x>=myrects(1,pos)-var && x<=myrects(3,pos)+var && y>=myrects(2,pos)-var && y<=myrects(4,pos)+var
                        movtime(trial,nsession)=b(1,1)*0.01;
                        choice(trial,nsession)=pos;
                        break;
                    else
                        continue;
                    end
                    
                    
                    
                    
                else
                    x=lesPointsX(a(end-3,1),trial);
                    y=lesPointsY(a(end-3,1),trial);

                    if x>=myrects(1,pos)-var && x<=myrects(3,pos)+var && y>=myrects(2,pos)-var && y<=myrects(4,pos)+var
                        movtime(trial,nsession)=a(1,1)*0.01;
                        choice(trial,nsession)=pos;
                        break;
                    else
                        continue;
                    end
                end
            end
        end
    end
   
    tmp=find(choice(:,nsession)==0);
    nullchoices(1,nsession)=length(tmp);
    condition(:,nsession)=alldata(:,h);
    alldata(:,g)=movtime(:,sub);
    h=h+4;
    i=i+4;
    j=j+4;
    g=g+4;
 


c=2;
subplot(2,3,nsession);plot(lesPointsX(1:idx,choice(:,nsession)==1&condition(:,nsession)==c),lesPointsY(1:idx,choice(:,nsession)==1&condition(:,nsession)==c),'r')
hold on
subplot(2,3,nsession);plot(lesPointsX(1:idx,choice(:,nsession)==2&condition(:,nsession)==c),lesPointsY(1:idx,choice(:,nsession)==2&condition(:,nsession)==c),'b')
hold on
subplot(2,3,nsession);plot(lesPointsX(1:idx,choice(:,nsession)==3&condition(:,nsession)==c),lesPointsY(1:idx,choice(:,nsession)==3&condition(:,nsession)==c),'g')
hold on
subplot(2,3,nsession);plot(lesPointsX(1:idx,choice(:,nsession)==4&condition(:,nsession)==c),lesPointsY(1:idx,choice(:,nsession)==4&condition(:,nsession)==c),'k')
hold on
subplot(2,3,nsession);plot(lesPointsX(1:idx,choice(:,nsession)==5&condition(:,nsession)==c),lesPointsY(1:idx,choice(:,nsession)==5&condition(:,nsession)==c),'y')
hold on
subplot(2,3,nsession);plot(lesPointsX(1:idx,choice(:,nsession)==6&condition(:,nsession)==c),lesPointsY(1:idx,choice(:,nsession)==6&condition(:,nsession)==c),'m')
hold on
subplot(2,3,nsession);plot(lesPointsX(1:idx,choice(:,nsession)==7&condition(:,nsession)==c),lesPointsY(1:idx,choice(:,nsession)==7&condition(:,nsession)==c),'c')
hold on
subplot(2,3,nsession);plot(lesPointsX(1:idx,choice(:,nsession)==8&condition(:,nsession)==c),lesPointsY(1:idx,choice(:,nsession)==8&condition(:,nsession)==c),'.')
hold on
subplot(2,3,nsession);plot(lesPointsX(1:idx,choice(:,nsession)==0&condition(:,nsession)==c),lesPointsY(1:idx,choice(:,nsession)==0&condition(:,nsession)==c),'--')
    


% subplot(2,3,nsession+1);plot(lesPointsX(1:idx,choice(:,nsession)==1&condition(:,nsession)==2),lesPointsY(1:idx,choice(:,nsession)==1&condition(:,nsession)==2),'r')
% hold on
% subplot(2,3,nsession+1);plot(lesPointsX(1:idx,choice(:,nsession)==2&condition(:,nsession)==2),lesPointsY(1:idx,choice(:,nsession)==2&condition(:,nsession)==2),'b')
% hold on
% subplot(2,3,nsession+1);plot(lesPointsX(1:idx,choice(:,nsession)==3&condition(:,nsession)==2),lesPointsY(1:idx,choice(:,nsession)==3&condition(:,nsession)==2),'g')
% hold on
% subplot(2,3,nsession+1);plot(lesPointsX(1:idx,choice(:,nsession)==4&condition(:,nsession)==2),lesPointsY(1:idx,choice(:,nsession)==4&condition(:,nsession)==2),'k')
% hold on
% subplot(2,3,nsession+1);plot(lesPointsX(1:idx,choice(:,nsession)==5&condition(:,nsession)==2),lesPointsY(1:idx,choice(:,nsession)==5&condition(:,nsession)==2),'y')
% hold on
% subplot(2,3,nsession+1);plot(lesPointsX(1:idx,choice(:,nsession)==6&condition(:,nsession)==2),lesPointsY(1:idx,choice(:,nsession)==6&condition(:,nsession)==2),'m')
% hold on
% subplot(2,3,nsession+1);plot(lesPointsX(1:idx,choice(:,nsession)==7&condition(:,nsession)==2),lesPointsY(1:idx,choice(:,nsession)==7&condition(:,nsession)==2),'c')
% hold on
% subplot(2,3,nsession+1);plot(lesPointsX(1:idx,choice(:,nsession)==8&condition(:,nsession)==2),lesPointsY(1:idx,choice(:,nsession)==8&condition(:,nsession)==2),'.')
% hold on
% subplot(2,3,nsession+1);plot(lesPointsX(1:idx,choice(:,nsession)==0&condition(:,nsession)==2),lesPointsY(1:idx,choice(:,nsession)==0&condition(:,nsession)==2),'--')
% 
    end
end








                  
    
    
    


    

    
    