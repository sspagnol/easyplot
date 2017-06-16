function RSK = addchannelmetadata(RSK, longName, units)

% addchannelmetadata - Add a the metadata for a new channel in the RSK.
%
% Syntax:  [RSK] = addchannelmetadata(RSK, longName, units)
% 
% A helper function that adds all the metadata associated with a new
% channel. Includes updating channels and instrumentsChannels.
%
% Inputs:
%   RSK - the input RSK structure.
%
%   longName - The name of the new channel.
%            
%   units - The units of the new channel. 
%
% Outputs:
%    RSK - the RSK structure containing new channel metadata
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-05

hasChan = any(strcmp({RSK.channels.longName}, longName));
if ~hasChan
    nchannels = length(RSK.channels);
    RSK.channels(nchannels+1).longName = longName;
    RSK.channels(nchannels+1).units = units;
    % update the instrumentChannels info for the new "channel"
    if isfield(RSK, 'instrumentChannels')
        if isfield(RSK.instrumentChannels, 'instrumentID')
            RSK.instrumentChannels(nchannels+1).instrumentID = RSK.instrumentChannels(1).instrumentID;
        end
        if isfield(RSK.instrumentChannels, 'channelStatus')
            RSK.instrumentChannels(nchannels+1).channelStatus = 0;
        end
        RSK.instrumentChannels(nchannels+1).channelID = RSK.instrumentChannels(nchannels).channelID+1;
        RSK.instrumentChannels(nchannels+1).channelOrder = RSK.instrumentChannels(nchannels).channelOrder+1;
    end
end

end