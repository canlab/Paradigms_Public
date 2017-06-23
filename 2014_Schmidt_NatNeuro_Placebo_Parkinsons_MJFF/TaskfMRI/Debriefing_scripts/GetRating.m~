2clear all; close all;
cd /Users/lianeschmidt/Documents/PD/TaskfMRI/Debriefing/originaldata
order=   [1 2 1 2 2 2 1 2  1  2  1  2  1  2  1  2  1  2  1 ];
for nsub=7;%[1 2 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21];
   
    
    % OFF side effects
    if nsub==1 || nsub==5 || nsub==9 || nsub==11 || nsub==13 || nsub==15 ||nsub==17 || nsub==19 || nsub==21
        resultname1=strcat('SideEffectsRatSub', num2str(nsub),'Session2.mat');
        
    elseif nsub==2 || nsub==6 || nsub==8 || nsub==10 || nsub==12 || nsub==14 || nsub==16 || nsub==18 || nsub==20
        resultname1=strcat('SideEffectsRatSub', num2str(nsub),'Session1.mat');
       
    end
    
    load (resultname1)
    
    for n=1:16
        offsideffect(n,nsub)=100*(((data(n,1)/2)+540)/1080);
    end
    
    % PLACEBO side effects
    if nsub==1 || nsub==5 || nsub==9 || nsub==11 || nsub==13 || nsub==15 ||nsub==17 || nsub==19 || nsub==21
        resultname2=strcat('SideEffectsRatSub', num2str(nsub),'Session1.mat');
        
    elseif nsub==2 || nsub==6 || nsub==7 || nsub==8 || nsub==10 || nsub==12 || nsub==14 || nsub==16 || nsub==18 || nsub==20
        resultname2=strcat('SideEffectsRatSub', num2str(nsub),'Session2.mat');
       
    end
     load (resultname2)
    
    for n=1:16
        placesideffect(n,nsub)=100*(((data(n,1)/2)+540)/1080);
    end
    
    % ON side effects
    if nsub==1 || nsub==5 || nsub==9 || nsub==11 || nsub==13 || nsub==15 ||nsub==17 || nsub==19 || nsub==21
        resultname3=strcat('SideEffectsRatSub', num2str(nsub),'Session3.mat');
        
    elseif nsub==2 || nsub==6 || nsub==7 || nsub==8 || nsub==10 || nsub==12 || nsub==14 || nsub==16 || nsub==18 || nsub==20
        resultname3=strcat('SideEffectsRatSub', num2str(nsub),'Session3.mat');
       
    end
     load (resultname3)
    
    for n=1:16
        onsideffect(n,nsub)=100*(((data(n,1)/2)+540)/1080);
    end
   
end


        