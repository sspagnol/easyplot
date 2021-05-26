%%
function sam = add_EP_X_demeaned(sam)

% There is a possibilty of non-monotonic time step (say due to instrument
% problems) or you might have burst sampled data, but for low pass
% filtering need a monotonic time stamp with regular dt and with nan data
% replaced with mean of time series.

%% determine QC use
try
    useQCflags = userData.EP_plotQC;
catch
    useQCflags = false;
end
useFlags = 'RAW';
if useQCflags, useFlags='QC'; end

% retrieve good flag values
goodFlags = getGoodFlags();

% only do LPF on PRES, PRES_REL and DEPTH. Search is setup such to avoid bursted
% names, and aggregated stats variables (eg DEPTH_std)
iXVars = find(cell2mat(cellfun(@(x) ~isempty(regexp(x.name,'^PRES$|^PRES_REL$|^DEPTH$|^EP_DEPTH$','once')), sam.variables, 'UniformOutput', false)));
if isempty(iXVars), return; end

% filtering burst data like WQMs can be problematic, totally experimental
% determination of a sampleInterval to construct a new time data
instrument_sample_interval=sam.meta.instrument_sample_interval;

instrument_burst_interval = NaN;
if isfield(sam.meta, 'instrument_burst_interval')
    instrument_burst_interval=sam.meta.instrument_burst_interval;
    if isempty(instrument_burst_interval)
        instrument_burst_interval = NaN;
    end
end

instrument_burst_duration = NaN;
if isfield(sam.meta, 'instrument_burst_duration')
    instrument_burst_duration=sam.meta.instrument_burst_duration;
    if isempty(instrument_burst_duration)
        instrument_burst_duration = NaN;
    end
end

if isnan(instrument_burst_interval)
    sampleInterval = instrument_sample_interval;
elseif instrument_burst_interval/instrument_burst_duration < 4
    sampleInterval = instrument_burst_interval;
else
    sampleInterval = instrument_burst_interval/3;
end

idTime  = getVar(sam.dimensions, 'TIME');
theOffset = sam.dimensions{idTime}.EP_OFFSET;
theScale = sam.dimensions{idTime}.EP_SCALE;
xdataVar = sam.dimensions{idTime}.data;
xdataVar = theOffset + (theScale .* xdataVar);

% cannot determine samrate from file
if sampleInterval<eps
    sampleInterval=mode(diff(xdataVar))*86400;
end

idXTime  = getVar(sam.dimensions, 'TIME');
[qdata, qindex] = unique(sam.dimensions{idTime}.data);
for vv = 1:numel(iXVars)
    ii = iXVars(vv);
    rawData=sam.variables{ii}.data;
    theOffset = sam.variables{ii}.EP_OFFSET;
    theScale = sam.variables{ii}.EP_SCALE;
    rawData = theOffset + (theScale .* rawData);
    %if useQCflags & isfield(sam.variables{ii}, 'flags')
    if isfield(sam.variables{ii}, 'flags')
        varFlags = int8(sam.variables{ii}.flags);
        iGood = ismember(varFlags, goodFlags);
        rawData(~iGood) = NaN;
    end
    % since easyplot doesn't know about info about in/out water time,
    % demean inner 80% of data which hopefully ignores in/out
    % water data and give user expected mean about zero
    buffer = 0.10; % percent to ignore at ends
    n = numel(rawData);
    i1 = max(2, floor(n * buffer));
    i2 = n - i1 + 1;
    meansignal=nanmean(rawData(i1:i2));
    
    % add LPF data
    varStruct = struct();
    varStruct.name = [sam.variables{ii}.name '_demeaned'];
    varStruct.typeCastFunc = str2func(netcdf3ToMatlabType(imosParameters(sam.variables{ii}.name, 'type')));
    varStruct.dimensions = idXTime;
    varStruct.data = rawData - meansignal;
    varStruct.coordinates = 'TIME LATITUDE LONGITUDE NOMINAL_DEPTH';
    if isfield(sam.variables{ii}, 'flags')
        varStruct.flags = varFlags;
    end
    varStruct.EP_OFFSET = 0.0;
    varStruct.EP_SCALE = 1.0;
    varStruct.EP_iSlice = 1;
    
    idx = getVar(sam.variables, varStruct.name);
    if idx == 0
        idx = length(sam.variables) + 1;
    end
    sam.variables{idx} = varStruct;
    
    % update plot status
    if isfield(sam, 'EP_variablePlotStatus')
        if sam.EP_variablePlotStatus(getVar(sam.variables, sam.variables{ii}.name)) == 2
            sam.EP_variablePlotStatus(idx) = 2;
        end
    end
    
    clear('varStruct');
    
end
end
