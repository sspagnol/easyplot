function [sam, defaultLatitude] = finaliseDataEasyplot(sam, defaultLatitude, fileName)
%FINALISEDATAEASYPLOT Finalize sample data structure
%
% Inputs:
%   sam - a struct containing sample data.
%
% Outputs:
%   sam - same as input, with fields added/modified

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
if ~isfield(sam.meta, 'EP_instrument_model_shortname') || isempty(sam.meta.EP_instrument_model_shortname)
    str = regexprep(sam.meta.instrument_model, '[^ -~]', '-'); %only printable ascii characters
    str = regexprep(str, ' ', '');
    sam.meta.EP_instrument_model_shortname = str;
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

for kk=1:numel(sam.variables)
    if ~isfield(sam.variables{kk}, 'comment')
        sam.variables{kk}.comment = '';
    end
    if ~isfield(sam.variables{kk}, 'coordinates')
        sam.variables{kk}.coordinates = '';
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
if ~isfield(sam, 'geospatial_lon_min')
sam.geospatial_lon_min = 152;
end
if ~isfield(sam, 'geospatial_lon_max')
sam.geospatial_lon_max = 152;
end
sam.time_coverage_start = sam.dimensions{idTime}.data(1);
sam.time_coverage_end = sam.dimensions{idTime}.data(end);
sam.dimensions{idTime}.comment = '';
sam.meta.site_id = sam.EP_inputFile;

% initalize timezone, which we actually don't know, so make UTC
% and the use can adjust for plotting purposes
if isfield(sam.meta,'timezone')
    if isempty(sam.meta.timezone)
        sam.meta.timezone='UTC';
    end
else
    sam.meta.timezone='UTC';
end

% initialize StartOffset/StopOffset
type = 'dimensions';
timeIdx = getVar(sam.(type), 'TIME');
lpftimeIdx = getVar(sam.(type), 'LPFTIME');
sam.(type){timeIdx}.EP_StartOffset = 0;
sam.(type){timeIdx}.EP_StopOffset = 0;

% we don't know what the planned depth is in this application
sam.meta.depth = 0;

sam.history = '';


%% add derived diagnositic variables, prefaces with 'EP_'
[sam, defaultLatitude]  = add_EP_vars(sam, defaultLatitude);
sam.meta.latitude = defaultLatitude;
sam.geospatial_lat_min = defaultLatitude;
sam.geospatial_lat_max = defaultLatitude;

idDEPTH =  getVar(sam.variables, 'EP_DEPTH');
if idDEPTH
    DEPTH = sam.variables{idDEPTH}.data;
    ind1 = floor(numel(DEPTH)/3);
    ind2 = ind1 + ind1;
    sam.instrument_nominal_depth = nanmean(DEPTH(ind1:ind2));
else
    sam.instrument_nominal_depth = 10;
end

% add CSPD/CDIR (_MAG) if required
sam = EP_velocityMagDirPP( {sam}, 'EP', true );
sam  = sam{1};

%% update EP_isPlottableVar, must be done after all variables have been added
sam = update_EP_isPlottableVar(sam);
sam = update_EP_axis_types(sam);
sam = update_EP_slicing(sam);
sam.EP_variablePlotStatus = zeros([numel(sam.variables), 1]);
sam.EP_isNew = true;

%% calculate data limits per variable, used in plotting routines
sam = calc_EP_LIMITS(sam);

end
