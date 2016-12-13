%%
function [isPlottable] = isPlottableData( theData )
isPlottable = false;
if isfield(theData,'data')
    if isfield(theData,'dimensions') && ~isempty(theData.dimensions)
        isPlottable = true;
    end
end
end
