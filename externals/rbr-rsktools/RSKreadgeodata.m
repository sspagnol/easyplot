function RSK = RSKreadgeodata(RSK, varargin)

% RSKreadgeodata - Reads the geodata of a rsk file
%
% Syntax:  RSK = RSKreadgeodata(RSK)
%
% RSKreadgeodata will return the geodata of a file
%
% Inputs:
%    RSK - Structure containing the logger metadata and thumbnails
%          returned by RSKopen.
%
%    UTCdelta - The offset of the timestamp. If a value is entered it will
%          be used. Otherwise it will use the one given in the epochs
%          table, if there is none it will use 0.
%
% Output:
%    RSK - Structure containing previously present logger metadata as well
%          as geodata.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-01-18

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'UTCdelta', 0);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
UTCdelta = p.Results.UTCdelta;



RSK.geodata = mksqlite('select tstamp/1.0 as tstamp, latitude, longitude, accuracy, accuracyType from geodata');
if isempty(RSK.geodata)
    RSK = rmfield(RSK, 'geodata');
    return;
elseif strcmpi(p.UsingDefaults, 'UTCdelta')
    try
        tmp = mksqlite('select UTCdelta/1.0 as UTCdelta from epoch');
        UTCdelta = tmp.UTCdelta;
        RSK.epochs.UTCdelta = UTCdelta;
    catch
        disp('No UTCdelta value, the timestamps in geodata cannot be adjust to the logger time, will use 0');
        UTCdelta = 0;
    end
end  
for ndx = 1:length(RSK.geodata)
    RSK.geodata(ndx).tstamp = RSKtime2datenum(RSK.geodata(ndx).tstamp + UTCdelta);
end

end
