function pAtm = getatmosphericpressure(RSK)

% getatmosphericpressure - Find the atmospheric pressure in RSK file or use
% default
%
% Syntax:   pAtm = getatmosphericpressure(RSK)
%
% Inputs:
%    RSK - Structure containing the logger metadata and data
%
% Outputs:
%    pAtm - Atmospheric pressure in dbar
%
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-24

pAtm = [];

if isfield(RSK, 'parameterKeys')
    atmrow = strcmpi({RSK.parameterKeys.key}, 'ATMOSPHERE');
    pAtm = str2double(RSK.parameterKeys(atmrow).value);
elseif isfield(RSK, 'parameters')
    pAtm = RSK.parameters.atmosphere;
end

if isempty(pAtm)
    pAtm = 10.1325;
end

end
    