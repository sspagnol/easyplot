function [sample_data, nSubPlots] = calcAxisIndex(sample_data, plotType, varNames)
%CALCAXISINDEX calculate axis index

% VARS_OVERLAY : one plot with all vars
% VARS_STACKED : subplots with common vars per subplot
% VARS_SINGLE : subplot per var, not implemented yet
% for each marked variable assign it an subplot/axis number
switch upper(plotType)
    case 'VARS_OVERLAY'
        nSubPlots = 1;
        for ii=1:numel(sample_data)
            sample_data{ii}.axisIndex = zeros(size(sample_data{ii}.EP_variablePlotStatus));
            iVars = find(sample_data{ii}.EP_variablePlotStatus > 0)';
            %markedVarNames = arrayfun(@(x) sample_data{ii}.variables{x}.name, iVars, 'UniformOutput', false);
            sample_data{ii}.axisIndex(iVars) = 1;
        end
        
    case 'VARS_STACKED'
        nSubPlots = numel(varNames);
        for ii=1:numel(sample_data)
            sample_data{ii}.axisIndex = zeros(size(sample_data{ii}.EP_variablePlotStatus));
            iVars = find(sample_data{ii}.EP_variablePlotStatus > 0)';
            markedVarNames = arrayfun(@(x) sample_data{ii}.variables{x}.name, iVars, 'UniformOutput', false);
            sample_data{ii}.axisIndex(iVars) = cell2mat(arrayfun(@(x) find(strcmp(x,varNames)), markedVarNames, 'UniformOutput', false));
        end
        
    otherwise
        disp('help');
end

end

