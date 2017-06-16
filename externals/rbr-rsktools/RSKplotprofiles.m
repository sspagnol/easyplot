function hdls = RSKplotprofiles(RSK, varargin)

% RSKplotprofiles - Plot profiles from an RSK structure output by 
%                   RSKreadprofiles.
%
% Syntax:  RSKplotprofiles(RSK, profileNum, channel, direction)
% 
% Plots profiles from automatically detected casts. If called with one
% argument, will default to plotting downcasts of temperature for all
% profiles in the structure.  Optionally outputs an array of handles
% to the line objects.
%
% Inputs: 
%    [Required] - RSK - Structure containing the logger metadata and data
%
%    [Optional] - profileNum - Optional profile number to plot. Default is to plot 
%                          all detected profiles.
%
%                 channel - Variable to plot (e.g. temperature, salinity, etc).
%            
%                 direction - 'up' for upcast, 'down' for downcast, or
%                          'both' for all. Default is 'down'. 
%
% Output:
%     hdls - The line object of the plot.
%
% Examples:
%    rsk = RSKopen('profiles.rsk');
%    rsk = RSKreadprofiles(rsk);
%    % plot selective downcasts and output handles
%      for customization
%    hdls = RSKplotprofiles(rsk, [1 5 10], 'conductivity');
%
% See also: RSKreadprofiles, RSKreaddata.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-08

validDirections = {'down', 'up', 'both'};
checkDirection = @(x) any(validatestring(x,validDirections));

%% Parse Inputs
p = inputParser;
addRequired(p, 'RSK', @isstruct);
addOptional(p, 'profileNum', [], @isnumeric);
addOptional(p, 'channel', 'Temperature', @ischar)
addOptional(p, 'direction', 'down', checkDirection)
parse(p, RSK, varargin{:})

% Assign each input argument
RSK = p.Results.RSK;
profileNum = p.Results.profileNum;
channel = p.Results.channel;
direction = p.Results.direction;

try 
    spCol = getchannelindex(RSK, 'Sea Pressure');
catch
    pCol = getchannelindex(RSK, 'Pressure');
end

chanCol = getchannelindex(RSK, channel);

if strcmpi(direction, 'both')
    direction = {'down', 'up'};
else
    direction = {direction};
end

pmax = 0;
ii = 1;
for dir = direction
    ax = gca; 
    ax.ColorOrderIndex = 1; 
    profileIdx = checkprofiles(RSK, profileNum, dir{1});
    castdir = [dir{1} 'cast']; 
    for ndx=profileIdx
        if exist('spCol','var')
            pressure = RSK.profiles.(castdir).data(ndx).values(:, spCol);
        else
            pressure = RSK.profiles.(castdir).data(ndx).values(:, pCol) - 10.1325;
        end
        hdls(ii) = plot(RSK.profiles.(castdir).data(ndx).values(:, chanCol), pressure);
        hold on
        pmax = max([pmax; pressure]);
        ii = ii+1;
    end
end

grid
xlab = [RSK.channels(chanCol).longName ' [' RSK.channels(chanCol).units, ']'];
ylim([0 pmax])
set(gca, 'ydir', 'reverse')
ylabel('Sea pressure [dbar]')
xlabel(xlab)
if strcmpi(direction, 'down')
    title('Downcasts')
elseif strcmpi(direction, 'up')
    title('Upcasts')
elseif size(direction,2)
    title('Downcasts and Upcasts')
end
hold off

end
