temperature = [32 44 44.5 45.5 46 46.5 47.5 48];
lvs = {'LV0','LV1','LV2','LV3','LV4','LV5','LV6','LV7','LV8'};

fnames = dir('data');
sidList = {};
subj = struct('temp',[],'placebo',[],'expect',[],'vas',[],'test',[]);
subjects = {};

id = 0;
for i=3:length(fnames) %exclude '.' and '..' which are first two indices
    newSubj = 1; %initialize search flag
    name = fnames(i).name(~isspace(fnames(i).name)); %remove any whitespace
    for j = 1:length(sidList)
        if strcmp(name(2:4),sidList{j})
            newSubj = 0;
            id = j;
        end
    end
    if newSubj == 1 %if subject is new add to list and gen ID
        sidList{end + 1} = name(2:4);
        id = length(sidList) + 1;
        subjects{id} = subj;
    end
    
    data = importdata(fnames.name(i));
    data = data.dat{1}
    for j = 1:length(data)
        if ~strcmp(data{j}.intensity,'LV0')
            subjects{id}.temp(end) =  temperature(strcmp(data{j}.intensity,lvs));
            switch name(5) %
                case C %if conditioning phase
                    subjects{id}.test = 0;
                case T %if test phase
                    subjects{id}.test = 1;
                otherwise %if neither C nor T give -1 as an error flag
                    subjects{id}.test = -1;
            end
            run = str2num(name(strfind(name,'.mat')-1));
            if run == 2 || run == 3 || run == 6 || run == 7
                subjects{id}.placebo = 1;
            else
                subjects{id}.placebo = 0;
            end
    end
    
    