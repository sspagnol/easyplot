function [chanNames] = cellchannelnames(RSK, channel)

% cellchannelnames - Makes a cell containing the channel names
%
% Syntax:  [chanNames] = cellchannelnames(RSK, channel)
%
% cellchannelnames is used to set up channel names before iterating through
% many different channels of data fields in a for loop. If the channel
% entry is 'all', all the channel longNames in the structure are put into a
% cell. If there is only one channel name it simply puts it in a cell and
% if there is a few channel names they are kept in a cell.
%
% Inputs:
%    RSK - Structure containing some logger metadata.
%
%    channel - channel names or 'all' 
%
% Output:
%    chanNames - A cell containing the channel longName to be looped over.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-25

if strcmpi(channel, 'all')
    chanNames = {RSK.channels.longName};
elseif ~iscell(channel)
    chanNames = {channel};
else
    chanNames = channel;
end

end