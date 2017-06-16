function RSK = readchannels(RSK)

% readchannels - Populates the channels table in the RSK structure.
%
% Syntax:  [RSK] = readchannels(RSK)
%
% If available the instrumentChannels table is used to read the
% channels with matching channelID otherwise the channels are read directly
% from the table.
%
% Inputs:
%    RSK - A RSK structure
%
% Outputs:
%    RSK - Structure containing channels
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-29

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

end