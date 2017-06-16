function hdls = RSKplotdata(RSK, varargin)

% RSKplotdata - Plot summaries of logger data
%
% Syntax:  [hdls] = RSKplotdata(RSK, [OPTIONS])
% 
% This generates a plot, similar to the thumbnail plot, only using the
% full 'data' that you read in.
% 
% Inputs:
%    [Required] - RSK - Structure containing the logger metadata and data
%
%    [Optional] - channel - channel to plots, can be multiple in a cell, if no value is
%                       given it will plot all channels.
%
% Output:
%     hdls - The line object of the plot.
%
% Example: 
%    RSK = RSKopen('sample.rsk');   
%    RSK = RSKreaddata(RSK);  
%    RSKplotdata(RSK);
%    -OR-
%    hdls = RSKplotdata(RSK, 'channel', {'Temperature', 'Conductivity'})
%
% See also: RSKplotprofiles, RSKplotburstdata
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-17

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'channel', 'all');
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
channel = p.Results.channel;

if ~isfield(RSK,'data')
    disp('You must read a section of data in first!');
    disp('Use RSKreaddata...')
    return
end

channels = cellchannelnames(RSK, channel);

chanCol = [];
for chan = channels
    chanCol = [chanCol getchannelindex(RSK, chan{1})];
end

hdls = channelsubplots(RSK, 'data', chanCol);

end

