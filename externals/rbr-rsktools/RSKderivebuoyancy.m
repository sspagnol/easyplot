function [RSK] = RSKderivebuoyancy(RSK,varargin)

% RSKderivebuoyancy - Calculate buoyancy frequency N^2 and stability E.
%
% Syntax:  [RSK] = RSKderivebuoyancy(RSK,[OPTIONS])
% 
% Derives buoyancy frequency and stability using the TEOS-10 GSW toolbox
% (http://www.teos-10.org/software.htm). The result is added to the
% RSK data structure, and the channel list is updated. 
%
% Note: This function makes the assumption that the Absolute Salinity anomaly
%       is zero to simplify the calculation.  In other words, SA = SR.
%
% Inputs: 
%   [Required] - RSK - Structure containing the logger metadata and data
%
%   [Optional] - latitude - Latitude in decimal degrees north [-90 ... +90]
%                If latitude is not provided, a default gravitational
%                acceleration, 9.7963 m/s^2 will be used (see gsw_grav)
%
% Outputs:
%    RSK - Updated structure containing buoyancy frequency and stability.
%
% See also: RSKderivesalinity.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-08-31


p = inputParser;
addRequired(p, 'RSK', @isstruct);
addOptional(p, 'latitude', [], @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
latitude = p.Results.latitude;
 

hasTEOS = ~isempty(which('gsw_Nsquared'));
if ~hasTEOS
    error('Must install TEOS-10 toolbox. Download it from here: http://www.teos-10.org/software.htm');
end

[Tcol,Scol,SPcol] = getchannel_T_S_SP_index(RSK);

RSK = addchannelmetadata(RSK, 'buoy00', 'Buoyancy Frequency Squared', 's-2');
N2col = getchannelindex(RSK, 'Buoyancy Frequency Squared');
RSK = addchannelmetadata(RSK, 'stbl00', 'Stability', 'm-1');
STcol = getchannelindex(RSK, 'Stability');

castidx = getdataindex(RSK);
for ndx = castidx
    SP = RSK.data(ndx).values(:,SPcol);
    S = RSK.data(ndx).values(:,Scol);
    T = RSK.data(ndx).values(:,Tcol);
    SA = gsw_SR_from_SP(S); % Assume SA ~= SR
    CT = gsw_CT_from_t(SA, T,SP);
    [N2,ST] = derive_N2_ST(SA,CT,SP,latitude);    
    RSK.data(ndx).values(:,N2col) = N2;
    RSK.data(ndx).values(:,STcol) = ST;
end

logentry = ('Buoyancy frequency squared and stability derived using TEOS-10 GSW toolbox.');
RSK = RSKappendtolog(RSK, logentry);


%% Nested functions
function [Tcol,Scol,SPcol] = getchannel_T_S_SP_index(RSK)
    Tcol = getchannelindex(RSK, 'Temperature');
    try
        Scol = getchannelindex(RSK, 'Salinity');
    catch
        error('RSKderivebuoyancy requires practical salinity. Use RSKderivesalinity...');
    end
    try
        SPcol = getchannelindex(RSK, 'Sea Pressure');
    catch
        error('RSKderivebuoyancy requires sea pressure. Use RSKderiveseapressure...');
    end
end

function [N2,ST] = derive_N2_ST(SA,CT,SP,latitude)
    if isempty(latitude)
        [N2_mid,p_mid] = gsw_Nsquared(SA,CT,SP);
        grav = gsw_grav(SP);
    else
        [N2_mid,p_mid] = gsw_Nsquared(SA,CT,SP,latitude);
        grav = gsw_grav(latitude,SP);
    end
    N2 = interp1(p_mid,N2_mid,SP,'linear','extrap');
    ST = N2./grav;
end

end
