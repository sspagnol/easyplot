
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
if ~isfield(sam.meta, 'instrument_model_shortname')
    sam.meta.instrument_model_shortname = sam.meta.instrument_model;
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
    sam.inputFilePath = PATHSTR;
    sam.inputFile = NAME;
    sam.inputFileExt = EXT;
    sam.easyplot_input_file = sam.toolbox_input_file;
else
    [PATHSTR,NAME,EXT] = fileparts(fileName);
    sam.inputFilePath = PATHSTR;
    sam.inputFile = NAME;
    sam.inputFileExt = EXT;
    sam.easyplot_input_file = fileName;
    % for v2.5+ need toolbox_input_file
    sam.toolbox_input_file = fileName;
    
end

sam.geospatial_lat_min = [];
sam.geospatial_lat_max = [];
sam.time_coverage_start = sam.dimensions{idTime}.data(1);
sam.time_coverage_end = sam.dimensions{idTime}.data(end);
sam.dimensions{idTime}.comment = '';
sam.meta.site_id = sam.inputFile;

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
sam = add_EP_TIMEDIFF(sam);
sam = add_EP_LPF(sam);

[sam, defaultLatitude] = add_EP_PSAL(sam, defaultLatitude);
[sam, defaultLatitude] = add_EP_DEPTH(sam, defaultLatitude);

% update isPlottableVar, must be done last
sam.isPlottableVar = false(1,numel(sam.variables));
% plot status, -1=delete, 0=not plotted, 1=plot
sam.variablePlotStatus = zeros(1,numel(sam.variables));
for kk=1:numel(sam.variables)
    isEmptyDim = isempty(sam.variables{kk}.dimensions);
    isData = isfield(sam.variables{kk},'data') & any(~isnan(sam.variables{kk}.data(:)));
    if ~isEmptyDim && isData
        sam.isPlottableVar(kk) = true;
        sam.variablePlotStatus(kk) = 0;
    end
end
sam.variablePlotStatus = sam.variablePlotStatus(:);

%
for kk=1:numel(sam.variables)
    if ~isfield(sam.variables{kk}, 'iSlice')
        sam.variables{kk}.iSlice = 1;
    end
end

% calculate data limits
for ii=1:numel(sam.variables)
    LIMITS = struct;
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
        strcmp(sam.inputFileExt, '.nc');
    
    %theVar = sam.variables{ii}.name;
    idTime  = getVar(sam.dimensions, 'TIME');
    RAW.xMin=min(sam.dimensions{idTime}.data(1), RAW.xMin);
    RAW.xMax=max(sam.dimensions{idTime}.data(end), RAW.xMax);
    if ~isfinite(RAW.xMin), RAW.xMin=floor(now); end
    if ~isfinite(RAW.xMax), RAW.xMax=floor(now)+1; end
    QC.xMin = RAW.xMin;
    QC.xMax = RAW.xMax;
    
    yData = double(sam.variables{ii}.data);
    RAW.yMin=min(min(yData), RAW.yMin);
    RAW.yMax=max(max(yData), RAW.yMax);
    
    if isIMOS
        if isfield(sam.variables{ii}, 'flags')
            varFlags = sam.variables{ii}.flags;
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
    
    LIMITS.QC = QC;
    LIMITS.RAW = RAW;
    sam.variables{ii}.LIMITS = LIMITS;
end

end

%%
function sam = add_EP_TIMEDIFF(sam)
% add derived variable TIMEDIFF

idTime  = getVar(sam.dimensions, 'TIME');
tmpStruct = struct();
tmpStruct.dimensions = idTime;
tmpStruct.name = 'EP_TIMEDIFF';
theData=sam.dimensions{idTime}.data(:);
theData = [NaN; diff(theData*86400.0)];
tmpStruct.data = theData;
tmpStruct.iSlice = 1;
tmpStruct.typeCastFunc = sam.dimensions{idTime}.typeCastFunc;
sam.variables{end+1} = tmpStruct;

end

%%
function sam = add_EP_LPF(sam)

% There is a possibilty of non-monotonic time step (say due to instrument
% problems) or you might have burst sampled data, but for low pass
% filtering need a monotonic time stamp with regular dt and with nan data
% replaced with mean of time series.

% only do LPF on PRES, PRES_REL. Search is setup such to avoid bursted
% names
iLpfVars = find(cell2mat(cellfun(@(x) ~isempty(regexp(x.name,'PRES$|PRES_REL$','once')), sam.variables, 'UniformOutput', false)));
if isempty(iLpfVars), return; end

% filtering burst data like WQMs can be problematic, totally experimental
% determination of a sampleInterval to construct a new time data
instrument_sample_interval=sam.meta.instrument_sample_interval;

instrument_burst_interval = NaN;
if isfield(sam.meta, 'instrument_burst_interval')
    instrument_burst_interval=sam.meta.instrument_burst_interval;
end

instrument_burst_duration = NaN;
if isfield(sam.meta, 'instrument_burst_duration')
    instrument_burst_duration=sam.meta.instrument_burst_duration;
end

if isnan(instrument_burst_interval)
    sampleInterval = instrument_sample_interval;
elseif instrument_burst_interval/instrument_burst_duration < 4
    sampleInterval = instrument_burst_interval;
else
    sampleInterval = instrument_burst_interval/3;
end

idTime  = getVar(sam.dimensions, 'TIME');

% cannot determine samrate from file
if sampleInterval<eps
    sampleInterval=mode(diff(sam.dimensions{idTime}.data))*86400;
end

nt=round(((sam.dimensions{idTime}.data(end)-sam.dimensions{idTime}.data(1)))/(sampleInterval/24/3600) +1);
if nt > 1e10
    warning('Too many data points for lowpass filtering.');
    return;
end
%if length(dataset.XDATA.data)~=nt
if length(sam.dimensions{idTime}.data)~=nt
    avec=0:nt-1;
    filterTime=sam.dimensions{idTime}.data(1) + avec.*(sampleInterval/24/3600);
else
    filterTime=sam.dimensions{idTime}.data;
end
filterTime=filterTime(:);

% % [delta] : seconds
% %deltat=diff(xdata2)*24*60*60;
% % remove mean (else get strange offsets) and replace
% % with zero
% rawData=dataset.YDATA.data;
% ibad=isnan(dataset.YDATA.data);
% istart=find(~ibad,1,'first');
% if ~isempty(istart)
%     tstart=dataset.TDATA.data(istart);
%     [distance,index]=sort(abs(filterTime-tstart));
%     i2start=min(index(1),numel(filterTime));
% else
%     i2start=1;
% end
%
% ifin=find(~ibad,1,'last');
% if ~isempty(ifin)
%     tfin=dataset.TDATA.data(ifin);
%     [distance,index]=sort(abs(filterTime-tfin));
%     i2fin=min(index(1),numel(filterTime));
% else
%     i2fin=numel(filterTime);
% end
%
% if numel(filterTime) > 10
%     filterTime(1:i2start)=[];
%     filterTime(i2fin:end)=[];
%     meansignal=nanmean(dataset.YDATA.data);
%     rawData=rawData-meansignal;
%     rawData(ibad)=0;
% end


candoLpf = false;
if (numel(filterTime)*sampleInterval/3600) > 40 %&& sum(~isnan(dataset.YDATA.data)) > 10
    candoLpf = true;
end

% so we have enough data to do LPF
if candoLpf
    % add LPFTIME dimension
    idTime  = getVar(sam.dimensions, 'TIME');
    
    dimStruct = struct;
    dimStruct.name = 'LPFTIME';
    dimStruct.typeCastFunc  = str2func(netcdf3ToMatlabType(imosParameters(sam.dimensions{idTime}.name, 'type')));
    dimStruct.data          = sam.dimensions{idTime}.typeCastFunc(filterTime);
    
    sam.dimensions{end+1} = dimStruct;
    clear('dimStruct');
    
    idLpfTime  = getVar(sam.dimensions, 'LPFTIME');
    
    for ii = iLpfVars
        rawData=sam.variables{ii}.data;
        meansignal=nanmean(rawData);
        % interpolate onto clean time data
        [qdata, index] = unique(sam.dimensions{idTime}.data); 
        newRawData=interp1(qdata,rawData(index)-meansignal,filterTime,'linear',0.0);
        newRawData(isnan(newRawData))=0; % this should never be the case but...
        
        % butterworth low pass filter with 40h cutoff, using
        % matlab function as has zero phase shift
        order=4;
        cutoff_freq=1/(40*3600);
        dT=sampleInterval;
        Fs=1/dT;
        ftype='low';
        nyquist_freq = Fs/2;  % Nyquist frequency
        Wn=cutoff_freq/nyquist_freq;    % non-dimensional frequency
        % butterworth
        if license('test','Signal_Toolbox')
            [z,p,k] = butter(order,Wn,ftype);
            [sos,g] = zp2sos(z,p,k);
            filterData=filtfilt(sos,g,double(newRawData)) + meansignal;
        else
            filterData=pl66tn(newRawData,dT/3600,33);
            filterData = filterData + meansignal;
        end
        
        
        % if not enough lpf data skip
        if sum(isnan(filterData))==numel(filterData)
            continue;
        end
        
        % add LPF data
        varStruct = struct();
        varStruct.name = ['EP_LPF_' sam.variables{ii}.name];
        varStruct.typeCastFunc = str2func(netcdf3ToMatlabType(imosParameters(sam.variables{ii}.name, 'type')));
        varStruct.dimensions = 1;
        varStruct.data = filterData;
        varStruct.coordinates = 'LPFTIME LATITUDE LONGITUDE NOMINAL_DEPTH';
        
        sam.variables{end+1} = varStruct;
        clear('varStruct');
        
    end
end
end

%%
function [sam, latitude] = add_EP_PSAL(sam, defaultLatitude)
%add_EP_PSAL Calculate simplified PSAL value

% data set already contains salinity
if getVar(sam.variables, 'PSAL'), return; end

cndcIdx       = getVar(sam.variables, 'CNDC');
tempIdx       = getVar(sam.variables, 'TEMP');

presIdx       = getVar(sam.variables, 'PRES');
presRelIdx    = getVar(sam.variables, 'PRES_REL');
isPresVar     = logical(presIdx || presRelIdx);

isDepthInfo   = false;
depthType     = 'variables';
depthIdx      = getVar(sam.(depthType), 'DEPTH');
if depthIdx == 0
    depthType     = 'dimensions';
    depthIdx      = getVar(sam.(depthType), 'DEPTH');
end
if depthIdx > 0, isDepthInfo = true; end

if isfield(sam, 'instrument_nominal_depth')
    if ~isempty(sam.instrument_nominal_depth)
        isDepthInfo = true;
    end
end

% cndc, temp, and pres/pres_rel or nominal depth not present in data set
if ~(cndcIdx && tempIdx && (isPresVar || isDepthInfo)), return; end

cndc = sam.variables{cndcIdx}.data;
temp = sam.variables{tempIdx}.data;

latitude = defaultLatitude;

% pressure information used for Salinity computation is from the
% PRES or PRES_REL variables in priority
if isPresVar
    if presRelIdx > 0
        presRel = sam.variables{presRelIdx}.data;
        presName = 'PRES_REL';
    else
        % update from a relative pressure like SeaBird computes
        % it in its processed files, substracting a constant value
        % 10.1325 dbar for nominal atmospheric pressure
        presRel = sam.variables{presIdx}.data - gsw_P0/10^4;
        presName = 'PRES substracting a constant value 10.1325 dbar for nominal atmospheric pressure';
    end
else
    % when no pressure variable exists, we use depth information either
    % from the DEPTH variable or from the instrument_nominal_depth
    % global attribute
    if depthIdx > 0
        % with depth data
        depth = sam.(depthType){depthIdx}.data;
        presName = 'DEPTH';
    else
        % with nominal depth information
        depth = 10*ones(size(temp));
        presName = 'instrument_nominal_depth';
    end
    if isfield(sam.meta, 'latitude')
        latitude = sam.meta.latitude;
    else
        prompt = {'Enter approximate latitude (decimal degrees, -ve S):'};
        dlg_title = 'Latitude';
        num_lines = 1;
        defaultans = {num2str(defaultLatitude)};
        latitude = str2double(inputdlg(prompt,dlg_title,num_lines,defaultans));
        sam.meta.latitude = latitude;   
    end
    presRel = gsw_p_from_z(depth, latitude);
end
% calculate C(S,T,P)/C(35,15,0) ratio
% conductivity is in S/m and gsw_C3515 in mS/cm
R = 10*cndc ./ gsw_C3515;

% calculate salinity
psal = gsw_SP_from_R(R, temp, presRel);

dimensions = sam.variables{tempIdx}.dimensions;
salinityComment = ['salinityPP.m: derived from CNDC, TEMP and ' presName ' using the Gibbs-SeaWater toolbox (TEOS-10) v3.05'];

if isfield(sam.variables{tempIdx}, 'coordinates')
    coordinates = sam.variables{tempIdx}.coordinates;
else
    coordinates = '';
end

% add salinity data as new variable in data set
sam = EP_addVar(...
    sam, ...
    'EP_PSAL', ...
    psal, ...
    dimensions, ...
    salinityComment, ...
    coordinates);

end

%%
function [sam, latitude] = add_EP_DEPTH(sam, defaultLatitude)

% exit if we already have depth
depthIdx       = getVar(sam.variables, 'DEPTH');
if depthIdx ~= 0
    return;
end
    
presIdx       = getVar(sam.variables, 'PRES');
presRelIdx    = getVar(sam.variables, 'PRES_REL');
isPresVar     = logical(presIdx || presRelIdx);
if ~isPresVar
    return;
end

if isfield(sam.meta, 'latitude')
    latitude = sam.meta.latitude;
else
    prompt = {'Enter approximate latitude (decimal degrees, -ve S):'};
    dlg_title = 'Latitude';
    num_lines = 1;
    defaultans = {num2str(defaultLatitude)};
    latitude = str2double(inputdlg(prompt,dlg_title,num_lines,defaultans));
    sam.meta.latitude = latitude;
end

if presRelIdx > 0
    presRel = sam.variables{presRelIdx}.data;
    presName = 'PRES_REL';
    dimensions = sam.variables{presRelIdx}.dimensions;
    coordinates = sam.variables{presRelIdx}.coordinates;
    dimensions = sam.variables{presRelIdx}.dimensions;
else
    % update from a relative pressure like SeaBird computes
    % it in its processed files, substracting a constant value
    % 10.1325 dbar for nominal atmospheric pressure
    presRel = sam.variables{presIdx}.data - gsw_P0/10^4;
    presName = 'PRES substracting a constant value 10.1325 dbar for nominal atmospheric pressure';
    dimensions = sam.variables{presIdx}.dimensions;
    coordinates = sam.variables{presIdx}.coordinates;
    dimensions = sam.variables{presIdx}.dimensions;
end

depth = gsw_z_from_p(presRel, latitude);

depthComment = ['add_EP_DEPTH.m: derived from ' presName ' using the Gibbs-SeaWater toolbox (TEOS-10) v3.05'];

% add depth data as new variable in data set
sam = EP_addVar(...
    sam, ...
    'EP_DEPTH', ...
    depth, ...
    dimensions, ...
    depthComment, ...
    coordinates);

end