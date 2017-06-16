function RSK = RSKreadthumbnail(RSK)

% RSKreadthumbnail - Internal function to read thumbnail data from
%                    an opened RSK file.
%
% Syntax:  results = RSKreadthumbnail
% 
% Reads thumbnail data from an opened RSK SQLite file, called from
% within RSKopen.
%
% Inputs:
%    RSK - Structure containing the logger metadata and thumbnails
%          returned by RSKopen.
%
% Output:
%    RSK - Structure containing previously present logger metadata as well
%          as thumbnailData
%
% See also: RSKopen
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-25

sql = ['select tstamp/1.0 as tstamp,* from thumbnailData order by tstamp'];
results = mksqlite(sql);
if isempty(results)
    return
end

results = removeunuseddatacolumns(results);
results = arrangedata(results);

results.tstamp = RSKtime2datenum(results.tstamp');

if ~strcmpi(RSK.dbInfo(end).type, 'EPdesktop')
    [~, isDerived] = removenonmarinechannels(RSK);
    results.values = results.values(:,~isDerived);
end

RSK.thumbnailData = results;
end
