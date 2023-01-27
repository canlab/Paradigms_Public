    function [painBar,prop] = updatepainBar(painBar,origLen,value,...
            endowments,endowment,multiplier,mode)
    % Helper function to compute pain duration as a function of endowment given
    % up and multiplier. Can be computer in two ways:
    %
    % proportional (prop): reduction is a function of the proportion of total possible 
    % endowment a participant is permitted to give up, e.g. if the max endowment is $10,
    % but a participant can only give up a max of $8, and chooses to give up $4 then
    % reduction: $4/$8 = 1 - 0.5*multiplier
    %
    % ratio (ratio): reduction is a function of the proportion of the max endowment a 
    % participant recieves, e.g. using the example above, then
    % reduction: $4/$8 = 1 - (0.5*multiplier*$8)/$10
   
        if strcmp(mode,'prop')
            prop = 1 - min((value/100)*multiplier,1);
        elseif strcmp(mode,'ratio')
            prop = 1- min(((value/100)*endowment*multiplier)/max(endowments),1);
        end
        painBar(3) = painBar(1) + origLen*prop;
    end