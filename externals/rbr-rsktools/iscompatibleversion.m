function   check = iscompatibleversion(RSK, minimumvsnMajor, minimumvsnMinor, minimumvsnPatch)

% iscompatibleversion - Checks that the RSK is equal to or later version
% than the minimum requiments
%
% Syntax:  [check] = iscompatibleversion(RSK, vsnMajor, vsnMinor, vsnPatch)
%
% compatibleversioncheck returns 1 if the RSK has a version that is equal
% to or greater than the specific minimum version required
%
% Inputs:
%    RSK - Structure containing the logger metadata and thumbnails
%          returned by RSKopen.
%
%    vsnMajor - The minimum requirement version number of category major.
%
%    vsnMinor - The minimum requirement version number of category minor.
%
%    vsnPatch - The minimum requirement version number of category patch.
%
% Output:
%    check - A logical index 1, version is compatible; 0, version is
%            not compatible
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-03-31

check = 0;

[~, vsnMajor, vsnMinor, vsnPatch] = RSKver(RSK);

if (vsnMajor > minimumvsnMajor) 
    check = 1;
elseif (vsnMajor == minimumvsnMajor)&&(vsnMinor > minimumvsnMinor)
    check = 1;
elseif (vsnMajor == minimumvsnMajor)&&(vsnMinor == minimumvsnMinor)&&(vsnPatch >= minimumvsnPatch)
    check = 1;
end
end