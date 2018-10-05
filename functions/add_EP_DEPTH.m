%%
function [sam, latitude] = add_EP_DEPTH(sam, defaultLatitude)

latitude = defaultLatitude;
% exit if we already have depth
%depthIdx       = getVar(sam.variables, 'DEPTH');
if (getVar(sam.variables, 'DEPTH') ~= 0) || (getVar(sam.variables, 'EP_DEPTH') ~= 0)
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
    theOffset = sam.variables{presRelIdx}.EP_OFFSET;
    theScale = sam.variables{presRelIdx}.EP_SCALE;
    presRel = theOffset + (theScale .* presRel);
    presName = 'PRES_REL';
    dimensions = sam.variables{presRelIdx}.dimensions;
    coordinates = sam.variables{presRelIdx}.coordinates;
    dimensions = sam.variables{presRelIdx}.dimensions;
else
    % update from a relative pressure like SeaBird computes
    % it in its processed files, substracting a constant value
    % 10.1325 dbar for nominal atmospheric pressure
    presRel = sam.variables{presIdx}.data - gsw_P0/10^4;
    theOffset = sam.variables{presRelIdx}.EP_OFFSET;
    theScale = sam.variables{presRelIdx}.EP_SCALE;
    presRel = theOffset + (theScale .* presRel);
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

% update plot status
if isfield(sam, 'variablePlotStatus')
    if sam.variablePlotStatus(presRelIdx) == 2
        sam.variablePlotStatus(getVar(sam.variables, 'EP_DEPTH')) = 2;
    end
end
end