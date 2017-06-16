function [RSK, seapressure] = RSKderiveseapressure(RSK, varargin)

% RSKderiveseapressure - Calculate sea pressure and add or replace it in the data table
%
% Syntax:  [RSK, seapressure] = RSKderiveseapressure(RSK, [OPTIONS])
% 
% This function derives sea pressure and fills the appropriate fields in
% channels field and data or profile field. If sea pressure is already
% calculated, it will recalculate it and overwrite that data 
% column. 
%
% Inputs: 
%    [Required] - RSK - Structure containing the logger metadata and data
%
%               
%    [Optional] - series - Specifies the series to be filtered. Either 'data'
%                     or 'profile'. Default is 'data'.
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
% Last revision: 2017-05-12

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

if strcmpi(series, 'profile')
    if strcmpi(direction, 'both')
        direction = {'down', 'up'};
    else
        direction = {direction};
    end
end

pAtm = getatmosphericpressure(RSK);
Pcol = getchannelindex(RSK, 'Pressure');

%% Calculate Sea Pressure
RSK = addchannelmetadata(RSK, 'Sea Pressure', 'dbar');
SPcol = getchannelindex(RSK, 'Sea Pressure');

switch series
    case 'data'
        data = RSK.data;
        seapressure = data.values(:, Pcol) - pAtm;
        RSK.data.values(:,SPcol) = seapressure;
    case 'profile'
        for dir = direction
            profileNum = [];
            profileIdx = checkprofiles(RSK, profileNum, dir{1});
            castdir = [dir{1} 'cast'];
            for ndx = profileIdx
                data = RSK.profiles.(castdir).data(ndx);
                seapressure = data.values(:, Pcol) - pAtm;
                RSK.profiles.(castdir).data(ndx).values(:,SPcol) = seapressure;
            end
        end
end

end



