%%
function dataLimits=findVarExtents(sample_data)
%FINDVAREXTENTS Find time and data extents of marked sample_data variables

if isempty(sample_data)
    dataLimits.xMin = floor(now);
    dataLimits.xMax = floor(now)+1;
    dataLimits.yMin = 0;
    dataLimits.yMax = 1;
else
    eps=1e-1;
    dataLimits.xMin = NaN;
    dataLimits.xMax = NaN;
    dataLimits.yMin = NaN;
    dataLimits.yMax = NaN;
    for ii=1:numel(sample_data) % loop over files
        for jj=1:numel(sample_data{ii}.variables)
            if sample_data{ii}.plotThisVar(jj)
                idTime  = getVar(sample_data{ii}.dimensions, 'TIME');
                dataLimits.xMin=min(sample_data{ii}.dimensions{idTime}.data(1), dataLimits.xMin);
                dataLimits.xMax=max(sample_data{ii}.dimensions{idTime}.data(end), dataLimits.xMax);
                if isvector(sample_data{ii}.variables{jj}.data)
                    dataLimits.yMin=min(min(sample_data{ii}.variables{jj}.data), dataLimits.yMin);
                    dataLimits.yMax=max(max(sample_data{ii}.variables{jj}.data), dataLimits.yMax);
                else
                    iSlice=sample_data{ii}.variables{jj}.iSlice;
                    dataLimits.yMin=min(min(sample_data{ii}.variables{jj}.data(:,iSlice)), dataLimits.yMin);
                    dataLimits.yMax=max(max(sample_data{ii}.variables{jj}.data(:,iSlice)), dataLimits.yMax);
                end
            end
        end
    end
    % if ylimits are small, make them a bit bigger for nice visuals
    if dataLimits.yMax-dataLimits.yMin < eps
        dataLimits.yMax=dataLimits.yMax*1.05;
        dataLimits.yMin=dataLimits.yMin*0.95;
    end
    if ~isfinite(dataLimits.xMin), dataLimits.xMin=floor(now); end
    if ~isfinite(dataLimits.xMax), dataLimits.xMax=floor(now)+1; end
    if ~isfinite(dataLimits.yMin), dataLimits.yMin=0; end
    if ~isfinite(dataLimits.yMax), dataLimits.yMax=1; end
end

end
