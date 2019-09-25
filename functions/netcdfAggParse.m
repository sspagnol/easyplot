
function sample_data = netcdfAggParse( filename, tmode )
filename = filename{1};
netcdfData = netcdfParse({filename}, 'timeSeries');

idTIME = getVar(netcdfData.variables, 'TIME');

instrument_index = netcdfData.variables{getVar(netcdfData.variables, 'instrument_index')}.data;
source_file = netcdfData.variables{getVar(netcdfData.variables, 'source_file')}.data;
% older test aggregate files instrument_id was call instrument_type
idVar = getVar(netcdfData.variables, 'instrument_id');
if idVar == 0
    idVar = getVar(netcdfData.variables, 'instrument_type');
end    
instrument_id = netcdfData.variables{idVar}.data;

sample_data = {};
counter = 0;
for i = 1:length(instrument_id)
    meta = struct;
    dimensions = {};
    variables  = {};
    
    meta.file_name =  source_file{i};
    meta.instrument_model = char(instrument_id{i});
    strs = strtrim(strsplit(instrument_id{i}, ';'));
    meta.instrument_make = char(strs{1});
    instrument_model = char(strs{2});
    meta.instrument_model = updateIfEmpty(instrument_model, meta.instrument_make, instrument_model);
    meta.instrument_serial_no = char(strs{3});
    
    % copy TIME
    v = struct;
    fnames = fieldnames(netcdfData.variables{idTIME});
    fnames = setdiff(fnames, 'data');
    for j = 1:length(fnames)
        fname = char(fnames{j});
        v.(fname) = netcdfData.variables{idTIME}.(fname);
    end
    v.data = netcdfData.variables{idTIME}.data(instrument_index == i);
    if isempty(v.data)
        continue;
    end
    v.data = v.data + datenum(1950,1,1,0,0,0);
    v.units = 'matlab serial date';
    dimensions{end+1} = v;
    
    meta.instrument_sample_interval = mean(diff(v.data)*86400);
    
    % copy other variables
    v = struct;
    vnames = cellfun(@(x) x.name, netcdfData.variables,  'UniformOutput', false);
    vnames = setdiff(vnames, {'TIME', 'LATITUDE', 'LONGITUDE', 'NOMINAL_DEPTH', 'instrument_index', 'source_file', 'instrument_id', 'instrument_type', 'deployment_code', 'instrument_burst_duration', 'instrument_burst_interval', 'instrument_burst_interval'});
    for j = 1:length(vnames)
        v = struct;
        vname = char(vnames{j});
        idVar = getVar(netcdfData.variables, vname);
        if idVar == 0
            continue;
        end
        v = netcdfData.variables{idVar};
        if isfield(v, 'instance_dimension') && strcmp(v.instance_dimension, 'instrument')
            continue;
        end
        v.data = v.data(instrument_index == i);
        if isempty(v.data)
            continue;
        end
        if isfield(v,'flags')
            v.flags = v.flags(instrument_index == i);
        else
            v.flags = ones(size(v.data), 'uint8');
        end
        variables{end+1} = v;
    end
    
    % update sample_data
    counter = counter + 1;
    sample_data{counter}.dimensions = dimensions;
    sample_data{counter}.variables = variables;
    sample_data{counter}.meta = meta;
    sample_data{counter}.EP_inputFile = source_file{i};
end
    
% update global attributes
% idLAT = getVar(netcdfData.variables, 'LATITUDE');
% idLON = getVar(netcdfData.variables, 'LONGITUDE');
% lat = netcdfData.variables{idLAT}.data;
% lon = netcdfData.variables{idLON}.data;
for j = 1:length(sample_data)
    sample_data{j}.geospatial_lat_max = netcdfData.geospatial_lat_max;
    sample_data{j}.geospatial_lat_max = netcdfData.geospatial_lat_max;
    sample_data{j}.geospatial_lon_max = netcdfData.geospatial_lon_max;
    sample_data{j}.geospatial_lon_min = netcdfData.geospatial_lon_min;
end

end