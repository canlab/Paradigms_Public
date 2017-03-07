totaldur=[];
data=[];
for j=1:6
    jittername=strcat('Jitter',num2str(j),'.mat');
    midjittername=strcat('midjitter',num2str(j),'.mat');
    load (jittername)
    load (midjittername)
    
    data(1:64,1)=3;
    data(1:64,2)=2;
    data(:,3)=jitter;
    data(:,4)=midjitter;
    for i=1:64
        data(i,5)=sum(data(i,1:4));
    end
    
    totaldur(j,1)=sum(data(:,5))+6;
    totaldur(j,2)=totaldur(j,1)/60;
end