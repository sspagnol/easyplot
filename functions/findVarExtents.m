%%
function dataLimits=findVarExtents(sample_data)
%FINDVAREXTENTS Find time and data extents of marked sample_data variables

% retrieve good flag values
qcSet     = str2double(readProperty('toolbox.qc_set'));
rawFlag   = imosQCFlag('raw', qcSet, 'flag');
goodFlag  = imosQCFlag('good', qcSet, 'flag');
goodFlags = [rawFlag, goodFlag];

%useQCflags = logical(gData.plotQC.Value);

if isempty(sample_data)
    dataLimits.RAW.xMinRAW = floor(now);
    dataLimits.RAW.xMaxRAW = floor(now)+1;
    dataLimits.RAW.yMinRAW = 0;
    dataLimits.RAW.yMaxRAW = 1;
    dataLimits.QC.xMinQC = floor(now);
    dataLimits.QC.xMaxQC = floor(now)+1;
    dataLimits.QC.yMinQC = 0;
    dataLimits.QC.yMaxQC = 1;
else
    eps=1e-1;
    xMinRAW = NaN;
    xMaxRAW = NaN;
    yMinRAW = NaN;
    yMaxRAW = NaN;
    xMinQC = NaN;
    xMaxQC = NaN;
    yMinQC = NaN;
    yMaxQC = NaN;
    
    for ii=1:numel(sample_data) % loop over files
        % is this an imos nc file
        isIMOS = isfield(sample_data{ii}, 'Conventions') && ~isempty(strfind(sample_data{ii}.Conventions, 'IMOS')) &&...
            strcmp(sample_data{ii}.inputFileExt, '.nc');
        for jj=1:numel(sample_data{ii}.variables)
            if sample_data{ii}.plotThisVar(jj)
                idTime  = getVar(sample_data{ii}.dimensions, 'TIME');
                xMinRAW=min(sample_data{ii}.dimensions{idTime}.data(1), xMinRAW);
                xMaxRAW=max(sample_data{ii}.dimensions{idTime}.data(end), xMaxRAW);
                xMinQC = xMinRAW;
                xMaxQC = xMaxRAW;
                if isvector(sample_data{ii}.variables{jj}.data)
                    yData = sample_data{ii}.variables{jj}.data;
                else
                    iSlice=sample_data{ii}.variables{jj}.iSlice;
                    yData = sample_data{ii}.variables{jj}.data(:,iSlice);
                end
                yMinRAW=min(min(yData), yMinRAW);
                yMaxRAW=max(max(yData), yMaxRAW);
                if isIMOS
                    if isfield(sample_data{ii}.variables{jj}, 'flags')
                        varFlags = sample_data{ii}.variables{jj}.flags;
                        if ~isvector(sample_data{ii}.variables{jj}.data)
                            varFlags = varFlags(:,iSlice);
                        end
                        iGood = ismember(varFlags, goodFlags);
                        yData(~iGood) = NaN;
                    end
                    yMinQC=min(min(yData), yMinQC);
                    yMaxQC=max(max(yData), yMaxQC);
                else
                    yMinQC = yMinRAW;
                    yMaxQC = yMaxRAW;
                end
            end
        end
    end
    % if ylimits are small, make them a bit bigger for nice visuals
    if yMaxRAW-yMinRAW < eps
        yMaxRAW=yMaxRAW*1.05;
        yMinRAW=yMinRAW*0.95;
    end
    if yMaxQC-yMinQC < eps
        yMaxQC=yMaxQC*1.05;
        yMinQC=yMinQC*0.95;
    end
    
    if ~isfinite(xMinRAW), xMinRAW=floor(now); end
    if ~isfinite(xMaxRAW), xMaxRAW=floor(now)+1; end
    if ~isfinite(yMinRAW), yMinRAW=0; end
    if ~isfinite(yMaxRAW), yMaxRAW=1; end
    
    if ~isfinite(xMinQC), xMinQC=floor(now); end
    if ~isfinite(xMaxQC), xMaxQC=floor(now)+1; end
    if ~isfinite(yMinQC), yMinQC=0; end
    if ~isfinite(yMaxQC), yMaxQC=1; end
    
    dataLimits.RAW.xMin = xMinRAW;
    dataLimits.RAW.xMax = xMaxRAW;
    dataLimits.RAW.yMin = yMinRAW;
    dataLimits.RAW.yMax = yMaxRAW;
    dataLimits.QC.xMin = xMinRAW;
    dataLimits.QC.xMax = xMaxRAW;
    dataLimits.QC.yMin = yMinQC;
    dataLimits.QC.yMax = yMaxQC;
end

end
