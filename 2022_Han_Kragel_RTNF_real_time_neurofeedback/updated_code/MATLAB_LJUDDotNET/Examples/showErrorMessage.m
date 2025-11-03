function showErrorMessage(e)
% showErrorMessage Displays the UD or .NET error from a MATLAB exception.

if(isa(e, 'NET.NetException'))
    eNet = e.ExceptionObject;
    if(isa(eNet, 'LabJack.LabJackUD.LabJackUDException'))
        disp(['UD Error: ' char(eNet.ToString())])
    else
        disp(['.NET Error: ' char(eNet.ToString())])
    end
end
disp(getReport(e))
end