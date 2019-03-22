function samplingperiod = readsamplingperiod(RSK)

% readsamplingperiod - Returns the sampling period information.
%
% Syntax:  [samplingperiod] = readsamplingperiod(RSK)
%
% Returns the sampling period of the file.
%
% Inputs:
%    RSK - Structure containing the logger metadata.
%
% Output:
%    samplingperiod - In seconds.
%
% See also: readfirmwarever, returnversion.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-09-14

mode = RSK.schedules.mode;

if strcmpi(mode, 'ddsampling')
    samplingperiod.fastThreshold = RSK.directional.fastThreshold/1000;
    samplingperiod.slowThreshold = RSK.directional.slowThreshold/1000;
elseif strcmpi(mode, 'fetching')
    error('"Fetching" files do not have a sampling period');
else 
    try
        samplingperiod = RSK.(mode).samplingPeriod/1000;
    catch
        samplingperiod = RSK.schedules.samplingPeriod/1000;
    end
end

end