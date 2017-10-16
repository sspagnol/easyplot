%%
function [sample_data] = markPlotVar(sample_data, plotVar, iSamples)
%MARKPLOTVAR Create cell array of plotted data for treeTable data

if ~iscell(plotVar)
    plotVar = {plotVar};
end

for ii=1:numel(sample_data)
    if iSamples(ii)
        variablePlotStatus = cellfun(@(x) any(strcmp(x.name,plotVar)), sample_data{ii}.variables);
        old_variablePlotStatus = sample_data{ii}.variablePlotStatus;
        sample_data{ii}.variablePlotStatus = double(variablePlotStatus(:)); % convert logical to double
        % if a new plot (variablePlotStatus=1) but was n't plotted before
        % (old_variablePlotStatus=0) then mark as new plot (=2)
        sample_data{ii}.variablePlotStatus((sample_data{ii}.variablePlotStatus + old_variablePlotStatus) == 1) = 2;
    end
    for jj=1:numel(sample_data{ii}.variables)
        sample_data{ii}.variables{jj}.iSlice=1;
        sample_data{ii}.variables{jj}.minSlice=1;
        sample_data{ii}.variables{jj}.maxSlice=1;
        if ~isvector(sample_data{ii}.variables{jj}.data)
            [d1,d2] = size(sample_data{ii}.variables{jj}.data);
            sample_data{ii}.variables{jj}.iSlice=floor(d2/2);
            sample_data{ii}.variables{jj}.minSlice=1;
            sample_data{ii}.variables{jj}.maxSlice=d2;
        end
    end
    
end

end
