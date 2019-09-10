function [sample_data, varNames, varDeleteNames, varNewNames, plotVarCounter] = countVars(sample_data)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%% create list of variable names that will be plotted, delete plots as required
varNames={};
varDeleteNames={};
varNewNames={};
plotVarCounter = struct;

% count up plots per variable, order is important
% variables to delete
for ii=1:numel(sample_data)
    iDeletePlotVars = find(sample_data{ii}.EP_variablePlotStatus == -1)';
    if ~isempty(iDeletePlotVars)
        for jj = iDeletePlotVars
            if isfield(sample_data{ii}.variables{jj}, 'hLine')
                theVar = sample_data{ii}.variables{jj}.name;
                if isfield (plotVarCounter, theVar)
                    plotVarCounter.(theVar) = plotVarCounter.(theVar) - 1;
                else
                    plotVarCounter.(theVar) = 0;
                end
                % delete the plot,
                delete(sample_data{ii}.variables{jj}.hLine);
                sample_data{ii}.variables{jj} = rmfield(sample_data{ii}.variables{jj},'hLine');
                varDeleteNames{end+1}=theVar;
                sample_data{ii}.EP_variablePlotStatus(jj) = 0;
            end
        end
    end
end

% variables already plotted
for ii=1:numel(sample_data)
    iPlotVars = find(sample_data{ii}.EP_variablePlotStatus == 1)';
    if ~isempty(iPlotVars)
        for jj = iPlotVars
            theVar = sample_data{ii}.variables{jj}.name;
            if isfield (plotVarCounter, theVar)
                plotVarCounter.(theVar) = plotVarCounter.(theVar) + 1;
            else
                plotVarCounter.(theVar) = 1;
            end
            varNames{end+1}=theVar;
        end
    end
end

% variables changed iSlice

% variables added since last plot
for ii=1:numel(sample_data)
    % test for changed islice plots, delete old line, and mark as new
    iNewPlotVars = find(sample_data{ii}.EP_variablePlotStatus == -2)';
    if ~isempty(iNewPlotVars)
        for jj = iNewPlotVars
            if isfield(sample_data{ii}.variables{jj}, 'hLine')
                theVar = sample_data{ii}.variables{jj}.name;
                if isfield (plotVarCounter, theVar)
                    plotVarCounter.(theVar) = plotVarCounter.(theVar) - 1;
                else
                    plotVarCounter.(theVar) = 0;
                end
                % delete the plot,
                delete(sample_data{ii}.variables{jj}.hLine);
                sample_data{ii}.variables{jj} = rmfield(sample_data{ii}.variables{jj},'hLine');
                varDeleteNames{end+1}=theVar;
                sample_data{ii}.EP_variablePlotStatus(jj) = 2;
            end
        end
    end
    
    % find new plots to add
    iNewPlotVars = find(sample_data{ii}.EP_variablePlotStatus == 2)';
    if ~isempty(iNewPlotVars)
        for jj = iNewPlotVars
            theVar = sample_data{ii}.variables{jj}.name;
            if isfield (plotVarCounter, theVar)
                plotVarCounter.(theVar) = plotVarCounter.(theVar) + 1;
            else
                plotVarCounter.(theVar) = 1;
            end
            varNewNames{end+1}=theVar;
        end
    end
end
%plotVarCounter
varNames=sort(unique(varNames));
varDeleteNames=sort(unique(varDeleteNames));
varNewNames=sort(unique(varNewNames));

end

