function RSK = RSKreaddata(RSK, varargin)

% RSKreaddata - Reads the data tables from an RBR RSK SQLite file.
%
% Syntax:  RSK = RSKreaddata(RSK, t1, t2)
% 
% Reads the actual data tables from the RSK file previously opened
% with RSKopen(). Will either read the entire data structre, or a
% specified subset. 
%
% Note: If the file type is 'skinny' the file will have to be opened with
% Ruskin before RSKtools can read the data because the data is stored in a
% raw bin file.
% 
% Inputs: 
%    RSK - Structure containing the logger metadata and thumbnails
%          returned by RSKopen. If provided as the only argument the
%          data for the entire file is read. Depending on the amount
%          of data in your dataset, and the amount of memory in your
%          computer, you can read bigger or smaller chunks before
%          Matlab will complain and run out of memory.
%     t1 - Optional start time for range of data to be read,
%          specified using the MATLAB datenum format.
%     t2 - Optional end time for range of data to be read,
%          specified using the MATLAB datenum format.
%
% Outputs:
%    RSK - Structure containing the logger metadata, along with the
%          added 'data' fields. Note that this replaces any
%          previous data that was read this way.
%
% Example: 
%    RSK = RSKopen('sample.rsk');  
%    RSK = RSKreaddata(RSK);
%
% See also: RSKopen, RSKreadevents, RSKreadburstdata
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-25

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

if strcmp(RSK.dbInfo(end).type, 'skinny')
    error('File must be opened in Ruskin before RSKtools can read the data.');
end


sql = ['select tstamp/1.0 as tstamp,* from data where tstamp between ' num2str(t1) ' and ' num2str(t2) ' order by tstamp'];
results = mksqlite(sql);
if isempty(results)
    disp('No data found in that interval')
    return
end

results = removeunuseddatacolumns(results);
results = arrangedata(results);

t=results.tstamp';
results.tstamp = RSKtime2datenum(t);

if ~strcmpi(RSK.dbInfo(end).type, 'EPdesktop')
    [~, isDerived] = removenonmarinechannels(RSK);
    results.values = results.values(:,~isDerived);
end

%% Put data into data field of RSK structure.
RSK.data=results;

%% Calculate Salinity  
% NOTE : We no longer automatically derive salinity when you read data from
% database. Use RSKderivesalinity(RSK) to calculate salinity.

end