
function sample_data = netcdfAggParse( filename, tmode )
filename = filename{1};
netcdfData = netcdfParse({filename}, 'timeSeries');

idTIME = getVar(netcdfData.variables, 'TIME');

instrument_index = netcdfData.variables{getVar(netcdfData.variables, 'instrument_index')}.data;
source_file = netcdfData.variables{getVar(netcdfData.variables, 'source_file')}.data;
instrument_type = netcdfData.variables{getVar(netcdfData.variables, 'instrument_type')}.data;

sample_data = {};
counter = 0;
for i = 1:length(instrument_type)
    meta = struct;
    dimensions = {};
    variables  = {};
    
    meta.file_name =  source_file{i};
    meta.instrument_model = char(instrument_type{i});
    strs = strsplit(instrument_type{i}, ' ');
    meta.instrument_make = char(strs{1});
    instrument_model = strjoin(strs(2:end-1), ' ');
    meta.instrument_model = updateIfEmpty(instrument_model, meta.instrument_make, instrument_model);
    meta.instrument_serial_no = char(strs{end});
    
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
    vnames = setdiff(vnames, {'TIME', 'LATITUDE', 'LONGITUDE', 'NOMINAL_DEPTH', 'instrument_index', 'source_file', 'instrument_type'});
    for j = 1:length(vnames)
        v = struct;
        vname = char(vnames{j});
        idVar = getVar(netcdfData.variables, vname);
        v = netcdfData.variables{idVar};
        v.data = v.data(instrument_index == i);
        if isempty(v.data)
            continue;
        end
        v.flags = v.flags(instrument_index == i);
        variables{end+1} = v;
    end
    
    % update sample_data
    counter = counter + 1;
    sample_data{counter}.dimensions = dimensions;
    sample_data{counter}.variables = variables;
    sample_data{counter}.meta = meta;
    sample_data{counter}.inputFile = source_file{i};

    % update global attributes
    idLAT = getVar(netcdfData.variables, 'LATITUDE');
    idLON = getVar(netcdfData.variables, 'LONGITUDE');
    lat = netcdfData.variables{idLAT}.data;
    lon = netcdfData.variables{idLON}.data;
    for j = 1:length(lat)
        sample_data{counter}.geospatial_lat_max = lat(j);
        sample_data{counter}.geospatial_lat_min = lat(j);
        sample_data{counter}.geospatial_lon_max = lon(j);
        sample_data{counter}.geospatial_lon_min = lon(j);
    end
    
end