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
tmpStruct.EP_iSlice = 1;
tmpStruct.EP_OFFSET = 0.0;
tmpStruct.EP_SCALE = 1.0;
tmpStruct.typeCastFunc = sam.dimensions{idTime}.typeCastFunc;

idx = getVar(sam.variables, 'EP_TIMEDIFF');
if idx == 0
    idx = length(sam.variables) + 1;
end

sam.variables{idx} = tmpStruct;

end
