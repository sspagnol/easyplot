%%
function originalModel = getOriginalModel(jtable)
%GETORIGINALMODEL Get original jtable model

originalModel = [];
if ~isempty(jtable)
    originalModel = jtable.getModel;
    try
        while(true)
            originalModel = originalModel.getActualModel;
        end;
    catch
        % never mind - bail out...
    end
end

end  % getOriginalModel

