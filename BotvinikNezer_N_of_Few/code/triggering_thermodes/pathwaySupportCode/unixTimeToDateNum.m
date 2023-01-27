function [dateNumTime] = unixTimeToDateNum( unixTime )
    % Convert unixTime to Matlab datenum format
    % (c) Oct - 2012 Arvind Pereira
    dateNumTime = repmat(datenum('1970-1-1 00:00:00'),size( unixTime ))+ ...
        unixTime./repmat(24*3600.0,size(unixTime));