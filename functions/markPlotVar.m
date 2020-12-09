function [structs] = markPlotVar(structs, plotVar, iSamples)
%MARKPLOTVAR updates cell array of plotted data status
% updates cell array of plotted data status for later use in treeTable

if ~iscell(plotVar)
    plotVar = cellstr(plotVar);
end

if all(cellfun(@isempty,plotVar))
    return;
end

if isstruct(structs)
    structs = num2cell(structs);
end

% plot status
% -1 = existing plot to delete
% 0 = not plotted
% 1 = existing plot
% 2 = new plot to add

for ii=1:numel(structs)
    if iSamples(ii)
        EP_variablePlotStatus = double(cellfun(@(x) any(strcmp(x.name,plotVar)), structs{ii}.variables));
        EP_variablePlotStatus = EP_variablePlotStatus(:);
        if isfield(structs{ii}, 'EP_variablePlotStatus')
            old_EP_variablePlotStatus = structs{ii}.EP_variablePlotStatus;
        else
            old_EP_variablePlotStatus = zeros(size(EP_variablePlotStatus));
        end
        %old_EP_variablePlotStatus = sample_data{ii}.EP_variablePlotStatus;
        iNew = (EP_variablePlotStatus==1 & old_EP_variablePlotStatus == 0);
        iDelete = (EP_variablePlotStatus==0 & old_EP_variablePlotStatus == 1);
        structs{ii}.EP_variablePlotStatus = EP_variablePlotStatus;
        % if a new plot (EP_variablePlotStatus=1) but was n't plotted before
        % (old_EP_variablePlotStatus=0) then mark as new plot (=2)
        structs{ii}.EP_variablePlotStatus(iNew) = 2;
        structs{ii}.EP_variablePlotStatus(iDelete) = -1;
    end
end

end
