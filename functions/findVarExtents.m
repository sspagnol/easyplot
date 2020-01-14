%%
function dataLimits=findVarExtents(sample_data,varNames)
%FINDVAREXTENTS Find time and data extents of marked sample_data variables

%% retrieve good flag values
goodFlags = getGoodFlags();

%%
if isempty(sample_data)
    dataLimits.RAW.xMin = floor(now);
    dataLimits.RAW.xMax = floor(now)+1;
    dataLimits.RAW.yMin = 0;
    dataLimits.RAW.yMax = 1;
    dataLimits.QC.xMin = floor(now);
    dataLimits.QC.xMax = floor(now)+1;
    dataLimits.QC.yMin = 0;
    dataLimits.QC.yMax = 1;
    return
end

%%
eps=1e-1;
dataLimits = struct;
for ii=1:numel(varNames)
    theVar=char(varNames{ii});
    dataLimits.(theVar).RAW.yMin = NaN;
    dataLimits.(theVar).RAW.yMax = NaN;
    dataLimits.(theVar).QC.yMin = NaN;
    dataLimits.(theVar).QC.yMax = NaN;
    dataLimits.MULTI.RAW.yMin = NaN;
    dataLimits.MULTI.RAW.yMax = NaN;
    dataLimits.MULTI.QC.yMin = NaN;
    dataLimits.MULTI.QC.yMax = NaN;
end
dataLimits.TIME.RAW.xMin = NaN;
dataLimits.TIME.RAW.xMax = NaN;
dataLimits.TIME.RAW.yMin = NaN;
dataLimits.TIME.RAW.yMax = NaN;
dataLimits.TIME.QC.yMin = NaN;
dataLimits.TIME.QC.yMax = NaN;

%%
for ii=1:numel(sample_data)
    for jj=1:numel(sample_data{ii}.variables)
        if sample_data{ii}.EP_variablePlotStatus(jj) > 0
            theVar = sample_data{ii}.variables{jj}.name;
            
            dataLimits.TIME.RAW.xMin = min(dataLimits.TIME.RAW.xMin, sample_data{ii}.variables{jj}.EP_LIMITS.RAW.xMin);
            dataLimits.TIME.RAW.xMax = max(dataLimits.TIME.RAW.xMax, sample_data{ii}.variables{jj}.EP_LIMITS.RAW.xMax);
            dataLimits.TIME.QC.xMin = dataLimits.TIME.RAW.xMin;
            dataLimits.TIME.QC.xMax = dataLimits.TIME.RAW.xMax;
            
            if isvector(sample_data{ii}.variables{jj}.data)
                yData = double(sample_data{ii}.variables{jj}.data);
                theOffset = sample_data{ii}.variables{jj}.EP_OFFSET;
                theScale = sample_data{ii}.variables{jj}.EP_SCALE;
                yData = theOffset + (theScale .* yData);
            else
                EP_iSlice=sample_data{ii}.variables{jj}.EP_iSlice;
                yData = double(sample_data{ii}.variables{jj}.data(:,EP_iSlice));
                theOffset = sample_data{ii}.variables{jj}.EP_OFFSET;
                theScale = sample_data{ii}.variables{jj}.EP_SCALE;
                yData = theOffset + (theScale .* yData);
            end
            dataLimits.(theVar).RAW.yMin=min(min(yData), dataLimits.(theVar).RAW.yMin);
            dataLimits.(theVar).RAW.yMax=max(max(yData), dataLimits.(theVar).RAW.yMax);
            dataLimits.(theVar).QC.yMin=min(min(yData), dataLimits.(theVar).QC.yMin);
            dataLimits.(theVar).QC.yMax=max(max(yData), dataLimits.(theVar).QC.yMax);
           
            dataLimits.MULTI.RAW.yMin=min(dataLimits.(theVar).RAW.yMin, dataLimits.MULTI.RAW.yMin);
            dataLimits.MULTI.RAW.yMax=max(dataLimits.(theVar).RAW.yMax, dataLimits.MULTI.RAW.yMax);
            dataLimits.MULTI.QC.yMin=min(dataLimits.(theVar).QC.yMin, dataLimits.MULTI.QC.yMin);
            dataLimits.MULTI.QC.yMax=max(dataLimits.(theVar).QC.yMax, dataLimits.MULTI.QC.yMax);
        end
    end
end


end
