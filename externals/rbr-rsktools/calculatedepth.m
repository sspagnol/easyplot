function depth = calculatedepth(pressure, latitude)

% calculatedepth - Calculate depth from pressure
%
% Syntax:  depth = calculatedepth(pressure, latitude)
% 
% Calculate depth from pressure. If TEOS-10 toolbox is installed it will
% use it http://www.teos-10.org/software.htm#1. Otherwise it is calculated
% using the Saunders & Fofonoff method. 
%
% Inputs:
%    pressure - a vector of pressure values in dbar
%
%    latitude - Latitude at the location of the pressure measurement in
%        decimal degrees north. Default is 45.
%
% Outputs:
%    depth - a vector containing depths in meters
%
% Example: 
%    depth = calculatedepth(pressure, 52)
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-02

%% Check if user has the TEOS-10 GSW toolbox installed
hasTEOS = ~isempty(which('gsw_SP_from_C'));

%% Calculate depth
if hasTEOS
    depth = -gsw_z_from_p(pressure, latitude);  
    
else
    % Use Saunders and Fofonoff's method.
    x = (sin(latitude/57.29578)).^2;
    gr = 9.780318*(1.0 + (5.2788e-3 + 2.36e-5*x).*x) + 1.092e-6.*pressure;
    depth = (((-1.82e-15*pressure + 2.279e-10).*pressure - 2.2512e-5).*pressure + 9.72659).*pressure;
    depth = depth./gr;
end

end