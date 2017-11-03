%%
function [sample_data] = markPlotVar(sample_data, plotVar, iSamples)
%MARKPLOTVAR Create cell array of plotted data for treeTable data

if ~iscell(plotVar)
    plotVar = cellstr(plotVar);
end

for ii=1:numel(sample_data)
    if iSamples(ii)
        variablePlotStatus = double(cellfun(@(x) any(strcmp(x.name,plotVar)), sample_data{ii}.variables));
        variablePlotStatus = variablePlotStatus(:);
        old_variablePlotStatus = sample_data{ii}.variablePlotStatus;
        iNew = (variablePlotStatus==1 & old_variablePlotStatus == 0);
        iDelete = (variablePlotStatus==0 & old_variablePlotStatus == 1);
        sample_data{ii}.variablePlotStatus = variablePlotStatus;
        % if a new plot (variablePlotStatus=1) but was n't plotted before
        % (old_variablePlotStatus=0) then mark as new plot (=2)
        sample_data{ii}.variablePlotStatus(iNew) = 2;
        sample_data{ii}.variablePlotStatus(iDelete) = -1;
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
