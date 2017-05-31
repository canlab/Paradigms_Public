
for sub=1:21
    if sub<10
        patientdir=strcat('/Users/lianeschmidt/Documents/PD/TaskfMRI/jitters/JittersPD0',num2str(sub));
    else
        patientdir=strcat('/Users/lianeschmidt/Documents/PD/TaskfMRI/jitters/JittersPD',num2str(sub));
    end
    
    cd(patientdir)
    for j=1:6
        resultname=strcat('Jitter',num2str(j),'.mat')
        load (resultname)
        data(j,sub)=mean(jitter);
    end
    
    for j=1:6
        resultname=strcat('midjitter',num2str(j),'.mat')
        load (resultname)
        middata(j,sub)=mean(midjitter);
    end
    
end

for sub=1:21
    for sess=1:6
        
        durdata(sess,sub)=((data(sess,sub)+3+middata(sess,sub)+2)*64)+6;
    end
end
% %
