function RSK = RSKreadburstdata(RSK, varargin)

%RSKreadburstdata - Read the burst data tables from events.
%
% Syntax:  [RSK] = RSKreadburstdata(RSK, [OPTIONS])
% 
% Reads the burst data tables from the RSK file previously opened with
% RSKopen(). Will either read the entire burst data structure, or a subset
% specified by 't1' and 't2'. Use in conjunction with readevents to
% separate bursts. 
% 
% Inputs: 
%    [Required] - RSK - Structure containing the logger metadata returned 
%                       by RSKopen. 
%
%    [Optional] - t1 - Start time for range of data to be read, specified
%                       using the MATLAB datenum format. 
%                 t2 - End time for range of data to be read, specified
%                       using the MATLAB datenum format. 
%
% Outputs:
%    RSK - Structure containing the logger metadata, along with the
%          added burstData fields. Note: any data previously in the
%          burstData field is replaced.
%
% Example: 
%    rsk = RSKreadburstdata(rsk);
%
% See also: RSKopen, RSKplotburstdata, readevents.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-06-21

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 't1', [], @isnumeric);
addParameter(p, 't2', [], @isnumeric);
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
t1 = datenum2rsktime(t1);
t2 = datenum2rsktime(t2);



sql = ['select tstamp/1.0 as tstamp,* from burstData where tstamp/1.0 between ' num2str(t1) ' and ' num2str(t2) ' order by tstamp'];
results = doSelect(RSK, sql);
if isempty(results)
    disp('No burstData found in that interval')
    return
end



results = removeunuseddatacolumns(results);
results = arrangedata(results);

t=results.tstamp';
results.tstamp = rsktime2datenum(t);
results.values(:,2:end) = [];
RSK.burstData=results;

end
