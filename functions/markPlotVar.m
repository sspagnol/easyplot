%%
function [sample_data] = markPlotVar(sample_data, plotVar, iSamples)
%MARKPLOTVAR Create cell array of plotted data for treeTable data

if ~iscell(plotVar)
    plotVar = cellstr(plotVar);
end

for ii=1:numel(sample_data)
    if iSamples(ii)
        EP_variablePlotStatus = double(cellfun(@(x) any(strcmp(x.name,plotVar)), sample_data{ii}.variables));
        EP_variablePlotStatus = EP_variablePlotStatus(:);
        old_EP_variablePlotStatus = sample_data{ii}.EP_variablePlotStatus;
        iNew = (EP_variablePlotStatus==1 & old_EP_variablePlotStatus == 0);
        iDelete = (EP_variablePlotStatus==0 & old_EP_variablePlotStatus == 1);
        sample_data{ii}.EP_variablePlotStatus = EP_variablePlotStatus;
        % if a new plot (EP_variablePlotStatus=1) but was n't plotted before
        % (old_EP_variablePlotStatus=0) then mark as new plot (=2)
        sample_data{ii}.EP_variablePlotStatus(iNew) = 2;
        sample_data{ii}.EP_variablePlotStatus(iDelete) = -1;
    end
    for jj=1:numel(sample_data{ii}.variables)
        sample_data{ii}.variables{jj}.EP_iSlice=1;
        sample_data{ii}.variables{jj}.EP_minSlice=1;
        sample_data{ii}.variables{jj}.EP_maxSlice=1;
        if ~isvector(sample_data{ii}.variables{jj}.data)
            [d1,d2] = size(sample_data{ii}.variables{jj}.data);
            sample_data{ii}.variables{jj}.EP_iSlice=floor(d2/2);
            sample_data{ii}.variables{jj}.EP_minSlice=1;
            sample_data{ii}.variables{jj}.EP_maxSlice=d2;
        end
    end
    
end

end
