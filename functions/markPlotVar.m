%%
function [sample_data] = markPlotVar(sample_data, plotVar)
%MARKPLOTVAR Create cell array of plotted data for treeTable data

if ~iscell(plotVar)
    plotVar = {plotVar};
end

for ii=1:numel(sample_data)
    sample_data{ii}.plotThisVar = cellfun(@(x) any(strcmp(x.name,plotVar)), sample_data{ii}.variables);
    sample_data{ii}.plotThisVar = sample_data{ii}.plotThisVar(:);
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
