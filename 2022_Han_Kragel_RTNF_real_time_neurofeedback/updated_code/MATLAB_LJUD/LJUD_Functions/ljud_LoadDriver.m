% Call ljud_LoadDriver from the command window or any mfile to load the
% LabJack driver. This needs to be done at the beginning of any file or
% before you can make any other calls to your LabJack.

if (libisloaded('labjackud') || (libisloaded('labjackud_doublePtr')))
    % Libraries already loaded
else
    clear all;
    header='C:\progra~1\LabJack\drivers\labjackud.h';
    loadlibrary('labjackud',header);
    loadlibrary labjackud labjackud_doublePtr.h alias labjackud_doublePtr
    
    % If you wish to view a list of the available LabJack UD functions
    % and their associated Output Values and Input Arguments, uncomment out
    % the appropriate line of code below. 
    %libfunctionsview labjackud % Use this in version 7.0 and newer
    %libfunctionsview labjackud_doublePtr % Use this in version 7.0+
    %libmethodsview labjackud % Use this in version 6.5
    %libmethodsview labjackud_doublePtr % Use this in version 6.5
end