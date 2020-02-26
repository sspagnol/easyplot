function [RSK] = RSKderiveBPR(RSK, varargin)

% RSKderiveBPR - convert bottom pressure recorder frequencies to
% temperature and pressure using calibration coefficients.
%
% Syntax:  [RSK] = RSKderiveBPR(RSK, [OPTION])
% 
% Loggers with bottom pressure recorder (BPR) channels are equipped
% with a Paroscientific, Inc. pressure transducer. The logger records
% the temperature and pressure output frequencies from the transducer.
% RSK files of type 'full' contain only the frequencies, whereas RSK
% files of type 'EPdesktop' contain the transducer frequencies for
% pressure and temperature, as well as the derived pressure and
% temperature.  RSKderiveBPR derives temperature and pressure from the
% transducer frequency channels for 'full' files.
% 
% RSKderiveBPR implements the calibration equations developed by
% Paroscientific, Inc. to derive pressure and temperature. The function 
% either uses input coefficients or calls RSKreadcalibrations to retrieve 
% the calibration table if has not been read previously.
%
% Note: When RSK data type is set to 'EPdesktop', Ruskin will import
% both the original signal and the derived pressure and temperature
% data.  However, the converted data can not achieve the highest
% resolution available.  Using the 'full' data type and deriving
% temperature and pressure with RSKtools will result in data with the
% full resolution.
%
% Inputs: 
%    [Required] - RSK - Structure containing the logger metadata and data
%
%    [Optional] - coef - coeffcients array of 1x14 which are
%                 [u0,y1,y2,y3,c1,c2,c3,d1,d2,t1,t2,t3,t4,t5]
%
% Outputs:
%    RSK - Structure containing the derived BPR pressure and temperature.
%
% See also: RSKderiveseapressure, RSKderivedepth.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-07-16


p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'coef', [], @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
coef = p.Results.coef;


checkDataField(RSK)

if ~strcmp(RSK.dbInfo(end).type, 'full')
    RSKerror('Only files of type "full" need derivation for BPR pressure and temperature');
end

PresPeriCol = strcmp({RSK.channels.shortName},'peri00') == 1;
TempPeriCol = strcmp({RSK.channels.shortName},'peri01') == 1;

if isempty(coef)
    [u0, y1, y2, y3, c1, c2, c3, d1, d2, t1, t2, t3, t4, t5] = getBPRcoef(RSK);
else
    coef = num2cell(coef);
    [u0, y1, y2, y3, c1, c2, c3, d1, d2, t1, t2, t3, t4, t5] = deal(coef{:});
end

RSK = addchannelmetadata(RSK, 'bpr_08', 'BPR pressure', 'dbar');
RSK = addchannelmetadata(RSK, 'bpr_09', 'BPR temperature', '°C');
[BPRPrescol,BPRTempcol] = getchannelindex(RSK, {'BPR pressure','BPR temperature'});

castidx = getdataindex(RSK);
for ndx = castidx
    temperature_period = RSK.data(ndx).values(:,TempPeriCol);
    pressure_period = RSK.data(ndx).values(:,PresPeriCol);
    [temperature, pressure] = BPRderive(temperature_period, pressure_period, u0, y1, y2, y3, c1, c2, c3, d1, d2, t1, t2, t3, t4, t5);
    RSK.data(ndx).values(:,BPRPrescol) = pressure;
    RSK.data(ndx).values(:,BPRTempcol) = temperature;
end

logentry = ('BPR temperature and pressure were derived from period data.');
RSK = RSKappendtolog(RSK, logentry);

    %% Nested Functions
    function [temperature, pressure] = BPRderive(temperature_period, pressure_period, u0, y1, y2, y3, c1, c2, c3, d1, d2, t1, t2, t3, t4, t5)
    % Equations for deriving BPR temperature and pressure, period unit convert from picoseconds to microseconds (/1e6)

    U = (temperature_period/(1e6)) - u0;
    temperature = y1 .* U + y2 .* U .*U + y3 .* U .* U .* U;

    C = c1 + c2 .* U + c3 .* U .* U;
    D = d1 + d2 .* U;
    T0 = t1 + t2 .* U + t3 .* U .* U + t4 .* U .* U .* U + t5 .* U .* U .* U .* U;
    Tsquare = (pressure_period/(1e6)) .* (pressure_period/(1e6));
    Pres = C .* (1 - ((T0 .* T0) ./ (Tsquare))) .* (1 - D .* (1 - ((T0 .* T0) ./ (Tsquare))));
    pressure = Pres* 0.689475; % convert from PSI to dbar
    
    end

    function [u0, y1, y2, y3, c1, c2, c3, d1, d2, t1, t2, t3, t4, t5] = getBPRcoef(RSK)

        if ~isfield(RSK,'calibrations') || ~isstruct(RSK.calibrations)
            RSK = RSKreadcalibrations(RSK);
        end

        PresCaliCol = find(strcmp({RSK.calibrations.equation},'deri_bprpres') == 1);
        TempCaliCol = find(strcmp({RSK.calibrations.equation},'deri_bprtemp') == 1);

        u0 = RSK.calibrations(TempCaliCol).x0;
        y1 = RSK.calibrations(TempCaliCol).x1;
        y2 = RSK.calibrations(TempCaliCol).x2;
        y3 = RSK.calibrations(TempCaliCol).x3;
        c1 = RSK.calibrations(PresCaliCol).x1;
        c2 = RSK.calibrations(PresCaliCol).x2;
        c3 = RSK.calibrations(PresCaliCol).x3;
        d1 = RSK.calibrations(PresCaliCol).x4;
        d2 = RSK.calibrations(PresCaliCol).x5;
        t1 = RSK.calibrations(PresCaliCol).x6;
        t2 = RSK.calibrations(PresCaliCol).x7;
        t3 = RSK.calibrations(PresCaliCol).x8;
        t4 = RSK.calibrations(PresCaliCol).x9;
        t5 = RSK.calibrations(PresCaliCol).x10;
    end

end
