function RSK = readheaderlive(RSK)

% readheaderlive - read tables that are populated in an 'live' file.
%
% Syntax:  [RSK] = readheaderlive(RSK)
%
% readheaderlive is a RSKtools helper function that opens the non-standars
% populated tables of RSK 'live' files.
% These tables are appSettings, instrumentsChannels and parameters.
% If data is available it will open parameterKeys and thumbnailData.  
%
% Note: Only marine channels will be displayed.
%
% Inputs:
%    RSK - 'live' file opened using RSKopen.m
%
% Outputs:
%    RSK - Structure containing the logger metadata and thumbnails
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-24


%% Tables that are definitely in 'live'
RSK.appSettings = mksqlite('select * from appSettings');

RSK = readparameters(RSK);

if iscompatibleversion(RSK, 1, 13, 8)
    RSK = readsamplingdetails(RSK);
end

[RSK, ~] = removenonmarinechannels(RSK);


%% Tables that may or may not be in 'live'
tables = mksqlite('SELECT name FROM sqlite_master WHERE type="table"');

if any(strcmpi({tables.name}, 'geodata'))
    RSK = RSKreadgeodata(RSK);
end

if any(strcmpi({tables.name}, 'thumbnailData'))
    RSK = RSKreadthumbnail(RSK);
end


end
