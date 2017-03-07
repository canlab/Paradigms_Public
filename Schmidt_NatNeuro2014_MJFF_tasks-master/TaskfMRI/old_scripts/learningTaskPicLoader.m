% learningTaskPicLoader

% Loads the pictures from the stim folder into a pair of cell arrays

function stimPics =  learningTaskPicLoader(loc)

cd(loc);

% Initializes the vectors that will hold the scenes and faces
learningTaskPics={};


% Loads the 16 faces and scenes
for i=1:6
    num=num2str(i);
    % Re-creates the filename (this approach is tailored to the name of the
    % files--you can pass whatever you want as the filenames)
    
    stimName=['LTStim0' num '.jpg'];
    % Loads the pictures into an array, so MATLAB can get to them
    stimPics{i}=imread(stimName,'jpg');
end