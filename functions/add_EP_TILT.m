function sam = add_EP_TILT(sam)
% add derived variable TILT

iPitchRoll = find(cell2mat(cellfun(@(x) ~isempty(regexp(x.name,'^PITCH$|^ROLL$','once')), sam.variables, 'UniformOutput', false)));
if isempty(iPitchRoll), return; end

idx = getVar(sam.variables, 'EP_TILT');
if idx ~= 0, return; end

idTIME  = getVar(sam.dimensions, 'TIME');
idPITCH = getVar(sam.variables, 'PITCH');
idROLL  = getVar(sam.variables, 'ROLL');

pitch = sam.variables{idPITCH}.data(:);
roll  = sam.variables{idROLL}.data(:);

tmpStruct = struct();
tmpStruct.dimensions = idTIME;
tmpStruct.name = 'EP_TILT';
tmpStruct.data = real(acos(sqrt(1 - sin(roll*pi/180).^2 - sin(pitch*pi/180).^2))*180/pi);
tmpStruct.EP_iSlice = 1;
tmpStruct.EP_OFFSET = 0.0;
tmpStruct.EP_SCALE = 1.0;
tmpStruct.coordinates = 'TIME LATITUDE LONGITUDE NOMINAL_DEPTH';
tmpStruct.typeCastFunc = sam.dimensions{idTIME}.typeCastFunc;

idx = length(sam.variables) + 1;
sam.variables{idx} = tmpStruct;

end