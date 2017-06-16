function RSK = readheaderfull(RSK)

% readheaderfull - read tables that are populated in an 'full' file.
%
% Syntax:  [RSK] = readheaderfull(RSK)
%
% readheaderfull is a RSKtools helper function that opens the non-standard
% tables populated in RSK 'full' files. Only to be used by RSKopen.m 
% These tables are appSettings, instrumentsChannels, ranging,
% and parameters. If data is available it will open parameterKeys, geodata
% and thumbnail. 
%
% Note: Only marine channels will be displayed.
%
% Inputs:
%    RSK - 'full' file opened using RSKopen.m
%
% Outputs:
%    RSK - Structure containing the logger metadata and thumbnails
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-24

%% Tables that are definitely in 'full'

RSK.appSettings = mksqlite('select * from appSettings');

RSK.ranging = mksqlite('select * from ranging');

% RSK = RSKreadcalibrations(RSK);
% NOTE : We no longer automatically read the calibrations table when
% opening a file with RSKopen. Use RSKreadcalibrations(RSK) to load the
% calibrations data.

RSK = readparameters(RSK);

if iscompatibleversion(RSK, 1, 13, 8)
    RSK = readsamplingdetails(RSK);
end

[RSK, ~] = removenonmarinechannels(RSK);

%% Tables that could be populated in 'full'
tables = mksqlite('SELECT name FROM sqlite_master WHERE type="table"');

if any(strcmpi({tables.name}, 'geodata'))
    RSK = RSKreadgeodata(RSK);
end

if any(strcmpi({tables.name}, 'thumbnailData'))
    RSK = RSKreadthumbnail(RSK);
end

end

