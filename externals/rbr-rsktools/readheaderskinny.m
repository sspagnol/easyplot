function RSK = readheaderskinny(RSK)

% readheaderskinny - read tables that are populated in an 'skinny' file.
%
% Syntax:  [RSK] = readheaderskinny(RSK)
%
% readheaderskinny is a RSKtools helper function that opens the
% non-standard populated tables of 'skinny' files. Only to be used by RSKopen.m.
% If data is available it will also open geodata.
%
% Note: The data is stored in raw bin file, this file type must be opened in
%     Ruskin in order to read the data.
%
% Inputs:
%    RSK - 'skinny' file opened using RSKopen.m
%
% Outputs:
%    RSK - Structure containing the logger metadata and thumbnails
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-29

tables = mksqlite('SELECT name FROM sqlite_master WHERE type="table"');

if any(strcmpi({tables.name}, 'geodata'))
    RSK = RSKreadgeodata(RSK);
end

end