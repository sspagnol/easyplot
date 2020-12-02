
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
goodFlags = getGoodFlags();

%% perform any extra instrument specific cleanup on sam structure
if exist([sam.meta.parser 'Cleanup'], 'file')
    parserCleanup = str2func([sam.meta.parser 'Cleanup']);
    sam = parserCleanup(sam);
end


%%
instrument_model = sam.meta.instrument_model;
instrument_make = sam.meta.instrument_make;
instrument_serial_no = sam.meta.instrument_serial_no;
instrument_serial_no = regexprep(instrument_serial_no, '[^ -~]', '%');
tokens = regexp(instrument_serial_no, '(\w+)-(\w+)$', 'tokens');
% In current aggregate files the model/make/serial need some tidying up.
if ~isempty(tokens)
    if strcmp(instrument_model, instrument_make) & ~isempty(tokens{1}{1})
        new_instrument_model = tokens{1}{1};
    elseif ~isempty(tokens{1}{1})
        new_instrument_model = [instrument_model ' - ' tokens{1}{1}];
    end
    new_instrument_serial = tokens{1}{2};
    
    sam.meta.instrument_model = new_instrument_model;
    sam.meta.instrument_serial_no = new_instrument_serial;
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

%% make all dimension names upper case
for ii=1:numel(sam.dimensions)
    sam.dimensions{ii}.name = upper(sam.dimensions{ii}.name);
end

idTime  = getVar(sam.dimensions, 'TIME');

% add offset/scale for all dimensions
for kk=1:numel(sam.dimensions)
    if ~isfield(sam.dimensions{kk}, 'EP_OFFSET')
        sam.dimensions{kk}.EP_OFFSET = 0.0;
        sam.dimensions{kk}.EP_SCALE = 1.0;
    end
end

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

%% add derived diagnositic variables, prefaces with 'EP_'
[sam, defaultLatitude]  = add_EP_vars(sam, defaultLatitude);

%% update EP_isPlottableVar, must be done last
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
sam = calc_EP_LIMITS(sam);

end
