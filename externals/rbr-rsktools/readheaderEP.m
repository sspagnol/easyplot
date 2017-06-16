function RSK = readheaderEP(RSK)

% readheaderEP - read tables that might be populated in an 'EasyParse' file.
%
% Syntax:  [RSK] = readheaderEP(RSK)
%
% readheaderEP is a RSKtools helper function that opens the possibly
% populated tables in Easy Parse files.
%
% Inputs:
%    RSK - 'EasyParse' file opened using RSKopen.m
%
% Outputs:
%    RSK - Structure containing the logger metadata
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-29

%% Remove non marine channels
[RSK, ~] = removenonmarinechannels(RSK);

%% Tables that could be populated in 'EasyParse'
tables = mksqlite('SELECT name FROM sqlite_master WHERE type="table"');

if any(strcmpi({tables.name}, 'geodata'))
    RSK = RSKreadgeodata(RSK);
end

end

