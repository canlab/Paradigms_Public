

function [Error, ljString] = ljud_DoubleToStringAddress(Number,HexDot)
String = '';
[Error, ljString] = calllib('labjackud','DoubleToStringAddress',Number,String,HexDot);