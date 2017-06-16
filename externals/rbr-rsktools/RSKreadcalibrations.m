function RSK = RSKreadcalibrations(RSK)

% RSKreadcalibrations - Reads the calibrations table of a rsk file
%
% Syntax:  RSK = RSKreadcalibrations(RSK)
%
% RSKreadcalibrations will return the calibrations table of a file including
% the coefficients. In version 1.13.4 of the RSK schema the coefficients
% table was seperated from the calibrations table. Here we recombine them
% into one table or simple open the calibrations table and adjust the time
% stamps if it was create before 1.13.4
%
% Inputs:
%    RSK - Structure containing the logger metadata and thumbnails
%          returned by RSKopen.
%
% Output:
%    RSK - Structure containing previously present logger metadata as well
%          as calibrations including coefficients
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-03-30

if ~strcmp(RSK.dbInfo(end).type, 'full')
    error('Only files of type "full" have a calibrations table');
end

% As of RSK v1.13.4 coefficients is it's own table. We add it back into calibration to be consistent with previous versions.
if iscompatibleversion(RSK, 1, 13, 4)
    RSK = coef2cal(RSK);
else
    RSK.calibrations = mksqlite('select * from calibrations');
    tstampstruct = mksqlite('select `tstamp`/1.0 as tstamp from calibrations');
    for ndx = 1:length(RSK.calibrations)
        RSK.calibrations(ndx).tstamp = RSKtime2datenum(tstampstruct(ndx).tstamp);

        for k=0:23
            n = sprintf('c%d', k);
            
            if(~isfield(RSK.calibrations, n))
                RSK.calibrations(ndx).(n) = [];
            end
        end
    end
    
    if isfield(RSK.calibrations, 'instrumentID')
        RSK.calibrations = rmfield(RSK.calibrations, 'instrumentID');
    end
end

end
