% Call the ljud_eSPI function from the MATLAB command window or any other
% mfile. To call the function use the following notation:
%
% [Error] = ljud_eSPI(Parameters)

function [ljError SPIBuffer] = ljud_eSPI(Handle, NumSPIBytes, SPIAutoCS, SPIDisableDirConfig, SPIMode, SPIClockFactor, SPICSPinNum, SPICLKPinNum, SPIMISOPinNum, SPIMOSIPinNum, SPIBuffer)

[ljError ] = calllib('labjackud','eSPI',Handle, NumSPIBytes, SPIAutoCS, SPIDisableDirConfig, SPIMode, SPIClockFactor, SPICSPinNum, SPICLKPinNum, SPIMISOPinNum, SPIMOSIPinNum, SPIBuffer)

%LJ_ERROR _stdcall eSPI(LJ_HANDLE Handle, long NumSPIBytes, long SPIAutoCS, long SPIDisableDirConfig, long SPIMode, long SPIClockFactor, long SPICSPinNum, long SPICLKPinNum, long SPIMISOPinNum, long SPIMOSIPinNum, unsigned char *SPIBuffer);
