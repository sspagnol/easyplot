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
