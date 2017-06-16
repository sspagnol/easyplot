function channelIdx = getchannelindex(RSK, channel)

% getchannelindex - Check if channels longNames are in RSK channels field and
% return the index.
%
% Syntax:  [channelIdx] = getchannelindex(RSK, channel)
% 
% A helper function that outputs the channel index in the RSK. If the
% channel is not in the RSK it returns an error.
%
% Inputs:
%   RSK - the input RSK structure
%
%   channel - The channel longName to be check.
%
% Outputs:
%    profileIdx - An array containing the index of channels
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-05

if any(strcmpi(channel, {RSK.channels.longName}));
    chanCol = find(strcmpi(channel, {RSK.channels.longName}));
    channelIdx = chanCol(1);
else
    error(['The is no ' channel ' channel in this file.']);
end 
end