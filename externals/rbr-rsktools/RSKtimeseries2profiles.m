function RSK = RSKtimeseries2profiles(RSK, varargin)

% RSKtimeseries2profiles - Detect profiles in existing time series data in
% RSK structure (RSK.data) and organize it into profiles.
%
% Syntax:  [RSK] = RSKtimeseries2profiles(RSK, [OPTIONS])
% 
% Call RSKfindprofiles to detect up and down casts using the same algorithm
% that logger/Ruskin uses. Reorganize the time series data based on the
% redetected profile information. Must be used for time series data only.
%
% Note: By contrast, RSKreadprofiles directly read profile data from the
% RSK file (i.e. from disk), while RSKtimeseries2profiles convert current 
% RSK structure time series data (i.e. from memory) into profiles.
%
% Inputs: 
%    [Required] - RSK - Structure containing the logger time series data 
%                       read from the RSK file.
%
%    [Optional] - pressureThreshold - Minimum pressure difference 
%                       required to detect a profile. The default is
%                       3 dbar, which is the same as the logger. 
%                       Consider reducing the pressure difference for
%                       very shallow profiles.  
%
%                 conductivityThreshold - Threshold value that indicates
%                       whether the sensor is out of water. Default is 
%                       0.05 mS/cm.  In very fresh water it may help to
%                       reduce this value.    
% Outputs:
%    RSK - RSK structure containing individual casts as each element in the
%          data field.
%
% Examples:
%    rsk = RSKopen('profiles.rsk');
%    rsk = RSKreaddata(rsk);
%    rsk = RSKtimeseries2profiles(rsk,'pressureThreshold',5);
%
% See also: RSKreadprofiles, RSKfindprofiles.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-10-30


p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'pressureThreshold', 3, @isnumeric);
addParameter(p, 'conductivityThreshold', 0.05, @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
pressureThreshold = p.Results.pressureThreshold;
conductivityThreshold = p.Results.conductivityThreshold;


if ~isfield(RSK,'data')
    error('No data field found, use RSKreaddata...');
end

if length(RSK.data) ~= 1 || isfield(RSK.data,'direction') || isfield(RSK.data,'profilenumber')
    error('RSK structure already has profiles.')
end

RSK = RSKfindprofiles(RSK,'pressureThreshold',pressureThreshold,'conductivityThreshold',conductivityThreshold);

direction = RSK.profiles.order;
hasDescription = isfield(RSK.region,'description');
ProfileRegionID = strcmpi({RSK.region.type},'PROFILE') == 1;

alltstart = [];
alltend = [];
for dir = direction
    castdir = [dir{1} 'cast'];
    alltstart = [alltstart; RSK.profiles.(castdir).tstart];
    alltend = [alltend; RSK.profiles.(castdir).tend];
end
alltstart = sort(alltstart);
alltend = sort(alltend);

castidx = 1:length(alltstart);
RSK.profiles.originalindex = castidx;

dir2fill = cell(length(castidx),1); % append data.direction to each cast
if size(RSK.profiles.order, 2) == 1
    dir2fill(:) = direction;
    pronum2fill = castidx;
    if hasDescription
        description2fill(:) = {RSK.region(ProfileRegionID).description};
    end
else
    dir2fill(1:2:end) = RSK.profiles.order(1);
    dir2fill(2:2:end) = RSK.profiles.order(2);
    pronum2fill = reshape(repmat(castidx(1:length(castidx)/2), 2, 1),length(castidx),1);
    if hasDescription
        description2fill(:) = reshape(repmat({RSK.region(ProfileRegionID).description}, 2 ,1),length(castidx),1);
    end
end

data(length(castidx)).tstamp = [];
data(length(castidx)).values = [];
data(length(castidx)).direction = [];
data(length(castidx)).profilenumber = [];
if hasDescription, 
    data(length(castidx)).description = []; 
end

k = 1;
for ndx = castidx    
    ind_start = (find(RSK.data.tstamp == alltstart(ndx)));
    ind_end = (find(RSK.data.tstamp == alltend(ndx)));
    
    data(k).tstamp = RSK.data.tstamp(ind_start:ind_end);
    data(k).values = RSK.data.values(ind_start:ind_end,:);
    data(k).direction = dir2fill{k};
    data(k).profilenumber = pronum2fill(k);
    if hasDescription, 
        data(k).description = description2fill(k); 
    end    
    k = k + 1;  
end

data(cellfun(@isempty,{data.tstamp})) = [];
RSK.data = data;

end