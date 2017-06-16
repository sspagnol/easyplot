function profileIdx = checkprofiles(RSK, profileNum, direction)

% checkprofile - check if profiles are present and outputs the profiles
% if none are provided
%
% Syntax:  [profileIdx] = checkprofile(RSK, profileNum, direction)
% 
% A helper function used to check if the profiles field of the RSK
% structure contains data in the required direction and to establish the
% profile indexes if none are specified.
%
% Inputs:
%   RSK - the input RSK structure
%
%   profileNum - Optional profile number to calculate lag. Default is to
%      calculate the lag of all detected profiles
%            
%   direction - 'up' for upcast, 'down' for downcast, or 'both' for all.
%      Default is 'down'. 
%
% Outputs:
%    profileIdx - An array containing the index of the profiles with data.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-04-05

isDown = isfield(RSK.profiles.downcast, 'data');
isUp   = isfield(RSK.profiles.upcast, 'data');
switch direction
    case 'up'
        if ~isUp
            error('Structure does not contain upcasts data')
        elseif isempty(profileNum)
            profileIdx = 1:length(RSK.profiles.upcast.data);
        else
            profileIdx = profileNum;
        end
    case 'down'
        if ~isDown
            error('Structure does not contain downcasts data')
        elseif isempty(profileNum)
            profileIdx = 1:length(RSK.profiles.downcast.data);
        else
            profileIdx = profileNum;
        end
end