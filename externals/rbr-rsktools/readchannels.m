function RSK = readchannels(RSK)

%READCHANNELS - Populate the channels table.
%
% Syntax:  [RSK] = READCHANNELS(RSK)
%
% If available, uses the instrumentChannels table to read the channels with
% matching channelID. Otherwise, directly reads the metadata from the
% channels table. Only returns non-marine channels, unless it is a
% EPdesktop file, and enumerates duplicate channel names.
%
% Inputs:
%    RSK - RSK structure.
%
% Outputs:
%    RSK - Structure containing channels.
%
% See also: readstandardtables, RSKopen.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-07-10

tables = mksqlite('SELECT name FROM sqlite_master WHERE type="table"');

if any(strcmpi({tables.name}, 'instrumentChannels'))
    RSK.instrumentChannels = mksqlite('select * from instrumentChannels');
    RSK.channels = mksqlite(['SELECT c.shortName as shortName,'...
                        'c.longName as longName,'...
                        'c.units as units '... 
                        'FROM instrumentChannels ic '... 
                        'JOIN channels c ON ic.channelID = c.channelID '...
                        'ORDER by ic.channelOrder']);
else
    RSK.channels = mksqlite('SELECT shortName, longName, units FROM channels ORDER by channels.channelID');
end

RSK = removenonmarinechannels(RSK);
RSK = renamechannels(RSK);

end