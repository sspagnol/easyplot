function samplingperiod = RSKsamplingperiod(RSK)

% RSKsamplingperiod - Returns the sampling period information
%
% Syntax:  samplingperiod = RSKsamplingperiod(RSK)
%
% RSKsamplingperiod will return the sampling period of the file
%
% Inputs:
%    RSK - Structure containing the logger metadata and thumbnails
%          returned by RSKopen.
%
% Output:
%    samplingperiod - the sampling period in seconds
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-06-07

mode = RSK.schedules.mode;
if iscompatibleversion(RSK, 1, 13, 8)
    if strcmpi(mode, 'ddsampling')
        samplingperiod.fastThreshold = RSK.directional.fastThreshold/1000;
        samplingperiod.slowThreshold = RSK.directional.slowThreshold/1000;
    elseif strcmpi(mode, 'fetching')
        error('"Fetching" files do not have a sampling period');
    else 
        samplingperiod = RSK.(mode).samplingPeriod/1000;
    end
else
    samplingperiod = RSK.schedules(end).samplingPeriod/1000;
end

end