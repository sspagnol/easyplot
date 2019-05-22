
%%
function [sam, defaultLatitude] = finaliseDataEasyplot(sam, fileName, defaultLatitude)
%FINALISEDATA Adds new EP_TIMEDIFF var
%
% Inputs:
%   sam             - a struct containing sample data.
%
% Outputs:
%   sample_data - same as input, with fields added/modified

%% retrieve good flag values
qcSet     = str2double(readProperty('toolbox.qc_set'));
rawFlag   = imosQCFlag('raw', qcSet, 'flag');
goodFlag  = imosQCFlag('good', qcSet, 'flag');
goodFlags = [rawFlag, goodFlag];

%% perform any extra instrument specific cleanup on sam structure
if exist([sam.meta.parser 'Cleanup'], 'file')
    parserCleanup = str2func([sam.meta.parser 'Cleanup']);
    sam = parserCleanup(sam);
end

%% for display purposes create a shortened instrument model name
% if not already done so from cleanup stage
if ~isfield(sam.meta, 'EP_instrument_model_shortname')
    sam.meta.EP_instrument_model_shortname = sam.meta.instrument_model;
end

if isfield(sam, 'featureType')
    if strcmp(sam.featureType, 'timeSeriesProfile')
        sam.meta.EP_instrument_model_shortname = 'GRIDDED';
        sam.meta.instrument_serial_no = 'GRIDDED';
    end
end
%%
sam.meta.instrument_serial_no = regexprep(sam.meta.instrument_serial_no, '[^ -~]', '%');

%% make all dimension names upper case
for ii=1:numel(sam.dimensions)
    sam.dimensions{ii}.name = upper(sam.dimensions{ii}.name);
end

idTime  = getVar(sam.dimensions, 'TIME');

if isfield(sam,'toolbox_input_file')
    [PATHSTR,NAME,EXT] = fileparts(sam.toolbox_input_file);
    sam.EP_inputFilePath = PATHSTR;
    sam.EP_inputFile = NAME;
    sam.EP_inputFileExt = EXT;
    sam.EP_inputFullFilename = sam.toolbox_input_file;
else
    [PATHSTR,NAME,EXT] = fileparts(fileName);
    sam.EP_inputFilePath = PATHSTR;
    sam.EP_inputFile = NAME;
    sam.EP_inputFileExt = EXT;
    sam.EP_inputFullFilename = fileName;
    % for v2.5+ need toolbox_input_file
    sam.toolbox_input_file = fileName;
    
end

if ~isfield(sam, 'geospatial_lat_min')
sam.geospatial_lat_min = [];
end
if ~isfield(sam, 'geospatial_lat_max')
sam.geospatial_lat_max = [];
end
sam.time_coverage_start = sam.dimensions{idTime}.data(1);
sam.time_coverage_end = sam.dimensions{idTime}.data(end);
sam.dimensions{idTime}.comment = '';
sam.meta.site_id = sam.EP_inputFile;

% if ~isfield(sample_data,'utc_offset_hours')
%     sample_data.utc_offset_hours = 0;
% end

if isfield(sam.meta,'timezone')
    if isempty(sam.meta.timezone)
        sam.meta.timezone='UTC';
    end
else
    sam.meta.timezone='UTC';
end

% we don't know what the planned depth is in this application
sam.meta.depth = 0;

sam.history = '';

%%
for kk=1:numel(sam.dimensions)
    if ~isfield(sam.dimensions{kk}, 'EP_OFFSET')
        sam.dimensions{kk}.EP_OFFSET = 0.0;
        sam.dimensions{kk}.EP_SCALE = 1.0;
    end
end
for kk=1:numel(sam.variables)
    if ~isfield(sam.variables{kk}, 'EP_OFFSET')
        sam.variables{kk}.EP_OFFSET = 0.0;
        sam.variables{kk}.EP_SCALE = 1.0;
    end
end
%
for kk=1:numel(sam.variables)
    if ~isfield(sam.variables{kk}, 'EP_iSlice')
        sam.variables{kk}.EP_iSlice = 1;
    end
end

%% add derived diagnositic variables, prefaces with 'EP_'
sam = add_EP_TIMEDIFF(sam);
[sam, defaultLatitude] = add_EP_PSAL(sam, defaultLatitude);
[sam, defaultLatitude] = add_EP_DEPTH(sam, defaultLatitude);

% done after adding other variables
sam = add_EP_LPF(sam);

% update EP_isPlottableVar, must be done last
sam.EP_isPlottableVar = false(1,numel(sam.variables));
% plot status, -1=delete, 0=not plotted, 1=plot
sam.EP_variablePlotStatus = zeros(1,numel(sam.variables));
for kk=1:numel(sam.variables)
    isEmptyDim = isempty(sam.variables{kk}.dimensions);
    isData = isfield(sam.variables{kk},'data') & any(~isnan(sam.variables{kk}.data(:)));
    if ~isEmptyDim && isData
        sam.EP_isPlottableVar(kk) = true;
        sam.EP_variablePlotStatus(kk) = 0;
    end
end
sam.EP_variablePlotStatus = sam.EP_variablePlotStatus(:);
sam.meta.latitude = defaultLatitude;

%%
% just in case
for kk=1:numel(sam.dimensions)
    if ~isfield(sam.dimensions{kk}, 'EP_OFFSET')
        sam.dimensions{kk}.EP_OFFSET = 0.0;
        sam.dimensions{kk}.EP_SCALE = 1.0;
    end
end
for kk=1:numel(sam.variables)
    if ~isfield(sam.variables{kk}, 'EP_OFFSET')
        sam.variables{kk}.EP_OFFSET = 0.0;
        sam.variables{kk}.EP_SCALE = 1.0;
    end
end
%
for kk=1:numel(sam.variables)
    if ~isfield(sam.variables{kk}, 'EP_iSlice')
        sam.variables{kk}.EP_iSlice = 1;
    end
end

% calculate data limits
for ii=1:numel(sam.variables)
    EP_LIMITS = struct;
    RAW = struct;
    QC = struct;
    
    eps=1e-1;
    RAW.xMin = NaN;
    RAW.xMax = NaN;
    QC.xMin = NaN;
    QC.xMax = NaN;
    RAW.yMin = NaN;
    RAW.yMax = NaN;
    QC.yMin = NaN;
    QC.yMax = NaN;
    % is this an imos nc file
    isIMOS = isfield(sam, 'Conventions') && ~isempty(strfind(sam.Conventions, 'IMOS')) &&...
        strcmp(sam.EP_inputFileExt, '.nc');
    
    %theVar = sam.variables{ii}.name;
    idTime  = getVar(sam.dimensions, 'TIME');
    theOffset = sam.dimensions{idTime}.EP_OFFSET;
    theScale = sam.dimensions{idTime}.EP_SCALE;
    RAW.xMin=min(sam.dimensions{idTime}.data(1)+theOffset, RAW.xMin);
    RAW.xMax=max(sam.dimensions{idTime}.data(end)+theOffset, RAW.xMax);
    if ~isfinite(RAW.xMin), RAW.xMin=floor(now); end
    if ~isfinite(RAW.xMax), RAW.xMax=floor(now)+1; end
    QC.xMin = RAW.xMin;
    QC.xMax = RAW.xMax;
    
    theOffset = sam.variables{ii}.EP_OFFSET;
    theScale = sam.variables{ii}.EP_SCALE;
    yData = theOffset + double(sam.variables{ii}.data).*theScale;
    RAW.yMin=min(min(yData), RAW.yMin);
    RAW.yMax=max(max(yData), RAW.yMax);
    
    if isIMOS
        if isfield(sam.variables{ii}, 'flags')
            varFlags = int8(sam.variables{ii}.flags);
            iGood = ismember(varFlags, goodFlags);
            yData(~iGood) = NaN;
        end
        QC.yMin=min(min(yData), QC.yMin);
        QC.yMax=max(max(yData), QC.yMax);
    else
        QC.yMin = RAW.yMin;
        QC.yMax = RAW.yMax;
    end
    
    if RAW.yMax - RAW.yMin < eps
        RAW.yMax = RAW.yMax*1.05;
        RAW.yMin = RAW.yMin*0.95;
    end
    if QC.yMax - QC.yMin < eps
        QC.yMax = QC.yMax*1.05;
        QC.yMin = QC.yMin*0.95;
    end
    
    if ~isfinite(RAW.yMin), RAW.yMin=0; end
    if ~isfinite(RAW.yMax), RAW.yMax=1; end
    
    if ~isfinite(QC.yMin), QC.yMin=0; end
    if ~isfinite(QC.yMax), QC.yMax=1; end
    
    EP_LIMITS.QC = QC;
    EP_LIMITS.RAW = RAW;
    sam.variables{ii}.EP_LIMITS = EP_LIMITS;
end

end
