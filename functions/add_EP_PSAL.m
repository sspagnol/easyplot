function [sam, latitude] = add_EP_PSAL(sam, defaultLatitude)
%add_EP_PSAL Calculate simplified PSAL value

latitude = defaultLatitude;
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

