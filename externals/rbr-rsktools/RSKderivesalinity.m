function [RSK, salinity] = RSKderivesalinity(RSK, varargin)

% RSKderivesalinity - Calculate salinity and add it or replace it in the data table
%
% Syntax:  [RSK] = RSKderivesalinty(RSK, [OPTIONS])
% 
% This function derives salinity using the TEOS-10 toolbox and fills the
% appropriate fields in channels field and data or profile field. If salinity is
% already calculated, it will recalculate it and overwrite that data
% column. 
% This function requires TEOS-10 to be downloaded and in the path
% (http://www.teos-10.org/software.htm)
%
%
% Inputs: 
%    [Required] - RSK - Structure containing the logger metadata and data
%
%                
%    [Optional] - series - Specifies the series to add channel data to.
%                     Either 'data' or 'profile'. Default is 'data'.  
%            
%                 direction - 'up' for upcast, 'down' for downcast, or 'both' for
%                     all. Default is 'down'.
%
% Outputs:
%    RSK - RSK structure containing the salinity data
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-18

validSeries = {'profile', 'data'};
checkSeriesName = @(x) any(validatestring(x,validSeries));

validDirections = {'down', 'up', 'both'};
checkDirection = @(x) any(validatestring(x,validDirections));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'series', 'data', checkSeriesName)
addParameter(p, 'direction', 'down', checkDirection);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
series = p.Results.series;
direction = p.Results.direction;

%% Check TEOS-10 and CTP data are available.
 
if isempty(which('gsw_SP_from_C'))
    error('RSKtools requires TEOS-10 toolbox to derive salinity. Download it here: http://www.teos-10.org/software.htm');
end
    
Ccol = getchannelindex(RSK, 'Conductivity');
Tcol = getchannelindex(RSK, 'Temperature');
try 
    SPcol = getchannelindex(RSK, 'Sea Pressure');
    RSKsp = RSK;
catch
    RSKsp = RSKderiveseapressure(RSK, 'series', series, 'direction', direction);
    SPcol = getchannelindex(RSKsp, 'Sea Pressure');
end

if strcmpi(series, 'profile')
    if strcmpi(direction, 'both')
        direction = {'down', 'up'};
    else
        direction = {direction};
    end
end
%% Calculate Salinity
RSK = addchannelmetadata(RSK, 'Salinity', 'mS/cm');
Scol = getchannelindex(RSK, 'Salinity');

switch series
    case 'data'
        data = RSKsp.data;
        salinity = gsw_SP_from_C(data.values(:, Ccol), data.values(:, Tcol), data.values(:, SPcol));
        RSK.data.values(:,Scol) = salinity;
    case 'profile'
        for dir = direction
            profileNum = [];
            profileIdx = checkprofiles(RSK, profileNum, dir{1});
            castdir = [dir{1} 'cast'];
            for ndx = profileIdx
                data = RSKsp.profiles.(castdir).data(ndx);
                salinity = gsw_SP_from_C(data.values(:, Ccol), data.values(:, Tcol), data.values(:, SPcol));
                RSK.profiles.(castdir).data(ndx).values(:,Scol) = salinity;
            end
        end
end

end



