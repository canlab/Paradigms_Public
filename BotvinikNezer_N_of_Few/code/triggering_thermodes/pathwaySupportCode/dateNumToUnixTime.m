function [unixTime] = dateNumToUnixTime( dateNumTime )
    % Convert Matlab datenum format time to Unix UTC time
    % (c) Oct - 2012 Arvind Pereira
    unixTime = (dateNumTime-repmat(datenum('1970-1-1 00:00:00'), ...
        size(dateNumTime))).*repmat(24*3600.0,size(dateNumTime));