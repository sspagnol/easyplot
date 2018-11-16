function RSK = readheaderEPdesktop(RSK)

%READHEADEREPDESKTOP - Read tables that are populated in a 'EPdesktop' file.
%
% Syntax:  [RSK] = READHEADEREPDESKTOP(RSK)
%
% Opens the non-standard populated tables of 'EPdesktop' files, including
% the appSettings, parameters, parameterKeys, geodata and downsample tables
% if exists.
%
% Inputs:
%    RSK - Structure of 'EPdesktop' file opened using RSKopen.m.
%
% Outputs:
%    RSK - Structure containing logger metadata and downsample, if exists.
%
% See also: RSKopen.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-08-22


tables = doSelect(RSK, 'SELECT name FROM sqlite_master WHERE type="table"');

if any(strcmpi({tables.name}, 'schedules'))
    RSK = readsamplingdetails(RSK);
end

if any(strcmpi({tables.name}, 'parameters'))
    RSK = readparameters(RSK);
end

if any(strcmpi({tables.name}, 'geodata'))
    RSK = readgeodata(RSK);
end

if any(strcmpi({tables.name}, 'appSettings'))
    RSK.appSettings = doSelect(RSK, 'select * from appSettings');  
end

if any(strcmpi({tables.name}, 'downsample_caches'))
    RSK = readdownsample(RSK);
end

end

