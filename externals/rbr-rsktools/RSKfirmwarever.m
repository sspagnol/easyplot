function [v, vsnMajor, vsnMinor]  = RSKfirmwarever(RSK)

% RSKfirmwarever - Returns the firmware version of the RSK file.
%
% Syntax:  [v, vsnMajor, vsnMinor] = RSKfirmwarever(RSK)
%
% RSKfirmwarever will return the most recent version of the firmware.
%
% Inputs:
%    RSK - Structure containing the logger metadata and thumbnails
%          returned by RSKopen.
%
% Output:
%    v - The lastest version of the firmware.
%    vsnMajor - The latest version number of category major.
%    vsnMinor - The latest version number of category minor.
%    vsnPatch - The latest version number of category patch.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-03-28

if iscompatibleversion(RSK, 1, 12, 2)
    v = RSK.instruments.firmwareVersion;
else
    v = RSK.deployments.firmwareVersion;
end

vsn = textscan(v,'%s','delimiter','.');
vsnMajor = str2double(vsn{1}{1});
vsnMinor = str2double(vsn{1}{2});


end