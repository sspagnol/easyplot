function sam = update_EP_isPlottableVar(sam)
%UPDATE_EP_ISPLOTTABLEVAR determine if variables are plottable or not
%   determine if variables are plottable or not based on dimensional data
%   test

sam.EP_isPlottableVar = false(1,numel(sam.variables));

for kk=1:numel(sam.variables)
    isNotEmptyDim = ~isempty(sam.variables{kk}.dimensions);
    isPlottableDim = numel(sam.variables{kk}.dimensions) < 3;
    hasDimData = isfield(sam.variables{kk},'data') & any(~isnan(sam.variables{kk}.data(:)));
    if isNotEmptyDim && isPlottableDim && hasDimData
        sam.EP_isPlottableVar(kk) = true;
    end
end

end

