function RSK = derivevoltage(RSK, varargin)

% derivevoltage - Calculate voltage ratio using pressure channel and
% specified calibration coefficients.
%
% Syntax:  [RSK] = derivevoltage(RSK, [OPTION])
%
% Inputs: 
%    [Required] - RSK - Structure containing the logger metadata and data
%
%    [Optional] - coefIdx - row number of RSK.calibrations that contains
%           pressure correction coefficients. Default is the most recent
%           coefficients.
%
% Outputs:
%    RSK - RSK structure containing the raw voltage data.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-04-24


p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'coefIdx', '', @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
coefIdx = p.Results.coefIdx;

if ~isfield(RSK,'calibrations') || ~isstruct(RSK.calibrations)
    RSK = RSKreadcalibrations(RSK);
end

if isempty(coefIdx)    
    coefIdx = find(strcmp('corr_pres2',{RSK.calibrations.equation}),1,'last');
else
    if coefIdx > length(RSK.calibrations)
        error('CoefIdx given is larger than max row of RSK.calibration table.')
    end   
end

[c0,c1,c2,c3,x0,x1,x2,x3,x4,x5] = getCoef(RSK, coefIdx);
RSK = addchannelmetadata(RSK, 'volt00', 'Voltage', 'V');
[Pcol,PGTcol,Vcol] = getchannelindex(RSK, {'Pressure','Pressure Gauge Temperature','Voltage'});

castidx = getdataindex(RSK);
for ndx = castidx
    P = RSK.data(ndx).values(:, Pcol);
    T = RSK.data(ndx).values(:, PGTcol);
    V = calculateVoltage(P,T,c0,c1,c2,c3,x0,x1,x2,x3,x4,x5);
    RSK.data(ndx).values(:,Vcol) = V;
end

logentry = ['Voltage calculated using calibration coefficients in calibration table row ' num2str(coefIdx)];
RSK = RSKappendtolog(RSK, logentry);


%% Nested functions
function [c0,c1,c2,c3,x0,x1,x2,x3,x4,x5] = getCoef(RSK, ind)
    c0 = RSK.calibrations(ind).c0;
    c1 = RSK.calibrations(ind).c1;
    c2 = RSK.calibrations(ind).c2;
    c3 = RSK.calibrations(ind).c3;
    x0 = RSK.calibrations(ind).x0;
    x1 = RSK.calibrations(ind).x1;
    x2 = RSK.calibrations(ind).x2;
    x3 = RSK.calibrations(ind).x3;
    x4 = RSK.calibrations(ind).x4;
    x5 = RSK.calibrations(ind).x5;
end

function V = calculateVoltage(P,T,c0,c1,c2,c3,x0,x1,x2,x3,x4,x5)
    PmeasCurrent = (P-x0).*(1 + x4*(T-x5)) + x0 + x1*(T-x5) + x2*(T-x5).^2 + x3*(T-x5).^3;
    V = zeros(size(PmeasCurrent));
    for j = 1:length(V)        
        r = roots([c3 c2 c1 c0-PmeasCurrent(j)]);
        V(j) = min(r(real(r)>-1 & imag(r)==0));
    end
end

end

