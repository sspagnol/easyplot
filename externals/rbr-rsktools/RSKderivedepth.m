function [RSK, depth] = RSKderivedepth(RSK, varargin)

% RSKderivedepth - Calculate depth from pressure and add it or replace it
% in the data table.
%
% Syntax:  [RSK, depth] = RSKderivedepth(RSK, latitude, [OPTIONS])
% 
% Calculate depth from pressure. If TEOS-10 toolbox is installed it will
% use it http://www.teos-10.org/software.htm#1. Otherwise it is calculated
% using the Saunders & Fofonoff method. 
%
% Inputs: 
%    [Required] - RSK - Structure containing the logger metadata and data
%
%    [Optional] - latitude - Latitude at the location of the pressure measurement in
%                    decimal degrees north. Default is 45. 
%             
%                 series - Specifies the series to be filtered. Either 'data'
%                     or 'profile'. Default is 'data'.
%            
%                 direction - 'up' for upcast, 'down' for downcast, or 'both' for
%                     all. Default is 'down'.
%
% Outputs:
%    RSK - RSK structure containing the salinity data.
%
%    depth - depth - a vector containing depths in meters.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-01


%% Check input and default arguments

validSeries = {'profile', 'data'};
checkSeriesName = @(x) any(validatestring(x,validSeries));

validDirections = {'down', 'up', 'both'};
checkDirection = @(x) any(validatestring(x,validDirections));

%% Parse Inputs

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addOptional(p, 'latitude', 45, @isnumeric);
addParameter(p, 'series', 'data', checkSeriesName);
addParameter(p, 'direction', 'down', checkDirection);
parse(p, RSK, varargin{:})

% Assign each input argument
RSK = p.Results.RSK;
latitude = p.Results.latitude;
series = p.Results.series;
direction = p.Results.direction;

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

%% Calculate Depth
RSK = addchannelmetadata(RSK, 'Depth', 'm');
Dcol = getchannelindex(RSK, 'Depth');

switch series
    case 'data'
        data = RSKsp.data;
        depth = calculatedepth(data.values(:,SPcol), latitude);
        RSK.data.values(:,Dcol) = depth;
    case 'profile'
        for dir = direction
            profileNum = [];
            profileIdx = checkprofiles(RSK, profileNum, dir{1});
            castdir = [dir{1} 'cast'];
            for ndx = profileIdx
RSK.                depth = calculatedepth(data.values(:,SPcol), latitude);
                RSK.profiles.(castdir).data(ndx).values(:,Dcol) = depth;
            end
        end
end

end