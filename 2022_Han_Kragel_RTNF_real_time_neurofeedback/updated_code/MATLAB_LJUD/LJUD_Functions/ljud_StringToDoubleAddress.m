

function [Error ljNumber] = ljud_StringToDoubleAddress(String,HexDot)
Number = 0;
[Error String ljNumber] = calllib('labjackud','StringToDoubleAddress',String,Number,HexDot);