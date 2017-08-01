
%%
function sam = finaliseDataEasyplot(sam,fileName)
%FINALISEDATA Adds new EP_TIMEDIFF var
%
% Inputs:
%   sam             - a struct containing sample data.
%
% Outputs:
%   sample_data - same as input, with fields added/modified

%% perform any extra instrument specific cleanup on sam structure
if exist([sam.meta.parser 'Cleanup'], 'file')
    parserCleanup = str2func([sam.meta.parser 'Cleanup']);
    sam = parserCleanup(sam);
end

%% make all dimension names upper case
for ii=1:numel(sam.dimensions)
    sam.dimensions{ii}.name = upper(sam.dimensions{ii}.name);
end

idTime  = getVar(sam.dimensions, 'TIME');

%% add derived diagnositic variables, prefaces with 'EP_'
sam = add_EP_TIMEDIFF(sam);
sam = add_EP_LPF(sam);

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

sam.isPlottableVar = false(1,numel(sam.variables));
sam.plotThisVar = false(1,numel(sam.variables));
for kk=1:numel(sam.variables)
    isEmptyDim = isempty(sam.variables{kk}.dimensions);
    isData = isfield(sam.variables{kk},'data') & any(~isnan(sam.variables{kk}.data(:)));
    if ~isEmptyDim && isData
        sam.isPlottableVar(kk) = true;
        sam.plotThisVar(kk) = false;
    end
end
sam.plotThisVar = sam.plotThisVar(:);

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

% only do LPF on PRES, PRES_REL
iLpfVars = find(cell2mat(cellfun(@(x) ~isempty(regexp(x.name,'PRES|PRES_REL')), sam.variables, 'UniformOutput', false)));
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
        newRawData=interp1(sam.dimensions{idTime}.data,rawData-meansignal,filterTime,'linear',0.0);
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
