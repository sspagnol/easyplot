function RSK = RSKreadevents(RSK, varargin)

% RSKreadevents - Reads the events from an RBR RSK SQLite file.
%
% Syntax:  RSK = RSKreadevents(RSK, t1, t2)
% 
% Reads the events from the RSK file previously opened with
% RSKopen(). Will either read all the events or a specified subset.
% 
% Inputs: 
%    RSK - Structure containing the logger metadata and thumbnails
%          returned by RSKopen. If provided as the only argument
%          events for the entire file are read.
%     t1 - Optional start time for range of data to be read,
%          specified using the MATLAB datenum format.
%     t2 - Optional end time for range of data to be read,
%          specified using the MATLAB datenum format.
%
% Outputs:
%    RSK - Structure containing the logger metadata, along with the
%          added events fields. Note that this replaces any
%          previous events that were read this way.
%
% Example: 
%    RSK = RSKopen('sample.rsk');  
%    RSK = RSKreadevents(RSK);
%
% See also: RSKopen, RSKreaddata, RSKreadburstdata
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-16

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addOptional(p, 't1', [], @isnumeric);
addOptional(p, 't2', [], @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
t1 = p.Results.t1;
t2 = p.Results.t2;

if isempty(t1)
    t1 = RSK.epochs.startTime;
end
if isempty(t2)
    t2 = RSK.epochs.endTime;
end
t1 = datenum2RSKtime(t1);
t2 = datenum2RSKtime(t2);

sql = ['select tstamp/1.0 as tstamp, deploymentID, type, sampleIndex, channelIndex from events where tstamp/1.0 between ' num2str(t1) ' and ' num2str(t2) ' order by tstamp'];
results = mksqlite(sql);
if isempty(results)
    return
end

results = arrangedata(results);

t=results.tstamp';
results.tstamp = RSKtime2datenum(t);

RSK.events=results;

end

