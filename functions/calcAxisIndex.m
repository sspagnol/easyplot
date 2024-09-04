function [sample_data, num_subplots, subplot_type] = calcAxisIndex(sample_data, plotType, varNames)
%CALCAXISINDEX calculate axis index

% VARS_OVERLAY : one plot with all vars
% VARS_STACKED : subplots with common vars per subplot
% VARS_SINGLE : subplot per var, not implemented yet
% for each marked variable assign it an subplot/axis number
counter = 1;
subplot_type = [];
switch upper(plotType)
    case 'VARS_OVERLAY'
        num_subplots = 1;
        for ii=1:numel(sample_data)
            sample_data{ii}.axisIndex = zeros(size(sample_data{ii}.EP_variablePlotStatus));
            indSlices = cellfun(@(x) x.EP_iSlice, sample_data{ii}.variables)';
            iVars = (sample_data{ii}.EP_variablePlotStatus > 0) & (indSlices ~= 0);
            sample_data{ii}.axisIndex(iVars) = 1;
            if isempty(subplot_type)
                subplot_type(end+1) = 1;
            end
            indVars = find((sample_data{ii}.EP_variablePlotStatus > 0) & (sample_data{ii}.EP_axis_types == 2) & (indSlices == 0))';
            for jj = 1:numel(indVars)
               k = indVars(jj); 
               counter = counter + 1;
               sample_data{ii}.axisIndex(k) = counter;
               num_subplots = num_subplots + 1;
               subplot_type(end+1) = 2;
            end
        end
        
    case 'VARS_STACKED'
        num_subplots = numel(varNames);
        for ii=1:numel(sample_data)
            
            sample_data{ii}.axisIndex = zeros(size(sample_data{ii}.EP_variablePlotStatus));
            iVars = find(sample_data{ii}.EP_variablePlotStatus > 0)';
            markedVarNames = arrayfun(@(x) sample_data{ii}.variables{x}.name, iVars, 'UniformOutput', false);
            sample_data{ii}.axisIndex(iVars) = cell2mat(arrayfun(@(x) find(strcmp(x,varNames)), markedVarNames, 'UniformOutput', false));
            
%             sample_data{ii}.axisIndex = zeros(size(sample_data{ii}.EP_variablePlotStatus));
%             indSlices = cellfun(@(x) x.EP_iSlice, sample_data{ii}.variables)';
%             indVars = find((sample_data{ii}.EP_variablePlotStatus > 0) & (indSlices ~= 0))';
%             markedVarNames = arrayfun(@(x) sample_data{ii}.variables{x}.name, indVars, 'UniformOutput', false);
%             sample_data{ii}.axisIndex(indVars) = cell2mat(arrayfun(@(x) find(strcmp(x,varNames)), markedVarNames, 'UniformOutput', false));

            indSlices = cellfun(@(x) x.EP_iSlice, sample_data{ii}.variables)';
            indVars = find((sample_data{ii}.EP_variablePlotStatus > 0) & (sample_data{ii}.EP_axis_types == 2) & (indSlices == 0))';
            for jj = 1:numel(indVars)
               k = indVars(jj); 
               counter = counter + 1;
               sample_data{ii}.axisIndex(k) = counter;
               num_subplots = num_subplots + 1;
               subplot_type(end+1) = 2;
            end

        end
        
    otherwise
        disp('help');
end

end

