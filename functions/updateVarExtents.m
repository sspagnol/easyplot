%%
function dataLimits = updateVarExtents(sample_data, dataLimits)
%UPDATEVAREXTENTS Find time and data extents of marked sample_data variables

%% retrieve good flag values
%goodFlags = getGoodFlags();

%%
if isempty(sample_data)
    dataLimits = struct;
    dataLimits.RAW = struct;
    dataLimits.QC = struct;
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
%eps=1e-1;
if isempty(dataLimits)
    dataLimits = struct;
end

% initialize TIME struct
if ~isfield(dataLimits, 'TIME')
    dataLimits.TIME = struct;
end
dataLimits.TIME.RAW = struct;
dataLimits.TIME.QC = struct;
dataLimits.TIME.RAW.xMin = NaN;
dataLimits.TIME.RAW.xMax = NaN;
dataLimits.TIME.RAW.yMin = NaN;
dataLimits.TIME.RAW.yMax = NaN;
dataLimits.TIME.QC.yMin = NaN;
dataLimits.TIME.QC.yMax = NaN;

% initialize MULTI struct
if ~isfield(dataLimits, 'MULTI')
    dataLimits.MULTI = struct;
end
dataLimits.MULTI.RAW = struct;
dataLimits.MULTI.QC = struct;
dataLimits.MULTI.RAW.yMin = NaN;
dataLimits.MULTI.RAW.yMax = NaN;
dataLimits.MULTI.QC.yMin = NaN;
dataLimits.MULTI.QC.yMax = NaN;

%%
allVarNames = {};
for ii=1:numel(sample_data)
    for jj=1:numel(sample_data{ii}.variables)
        if sample_data{ii}.EP_isPlottableVar(jj)
            theVar = sample_data{ii}.variables{jj}.name;
            allVarNames{end+1} = theVar;
            
            if ~isfield(dataLimits, theVar)
                dataLimits.(theVar) = struct;
                dataLimits.(theVar).RAW = struct;
                dataLimits.(theVar).QC = struct;
                dataLimits.(theVar).RAW.yMin = NaN;
                dataLimits.(theVar).RAW.yMax = NaN;
                dataLimits.(theVar).QC.yMin = NaN;
                dataLimits.(theVar).QC.yMax = NaN;
            end
            
            % always update TIME
            dataLimits.TIME.RAW.xMin = min(dataLimits.TIME.RAW.xMin, sample_data{ii}.variables{jj}.EP_LIMITS.RAW.xMin);
            dataLimits.TIME.RAW.xMax = max(dataLimits.TIME.RAW.xMax, sample_data{ii}.variables{jj}.EP_LIMITS.RAW.xMax);
            dataLimits.TIME.QC.xMin = dataLimits.TIME.RAW.xMin;
            dataLimits.TIME.QC.xMax = dataLimits.TIME.RAW.xMax;
            
            % get the data to analyse
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
            
            % update limits for a variable
            dataLimits.(theVar).RAW.yMin=min(min(yData), dataLimits.(theVar).RAW.yMin);
            dataLimits.(theVar).RAW.yMax=max(max(yData), dataLimits.(theVar).RAW.yMax);
            dataLimits.(theVar).QC.yMin=min(min(yData), dataLimits.(theVar).QC.yMin);
            dataLimits.(theVar).QC.yMax=max(max(yData), dataLimits.(theVar).QC.yMax);
            
            % update MULTI (limits for all plots on one graph), but only
            % for variables that could be plotted
            if sample_data{ii}.EP_variablePlotStatus(jj) > 0
                dataLimits.MULTI.RAW.yMin=min(dataLimits.(theVar).RAW.yMin, dataLimits.MULTI.RAW.yMin);
                dataLimits.MULTI.RAW.yMax=max(dataLimits.(theVar).RAW.yMax, dataLimits.MULTI.RAW.yMax);
                dataLimits.MULTI.QC.yMin=min(dataLimits.(theVar).QC.yMin, dataLimits.MULTI.QC.yMin);
                dataLimits.MULTI.QC.yMax=max(dataLimits.(theVar).QC.yMax, dataLimits.MULTI.QC.yMax);
            end
            
        end
    end
end

% remove any dataLimits variables not plotted
allVarNames = unique(allVarNames);
allVarNames{end+1} = 'TIME';
allVarNames{end+1} = 'MULTI';
varNames = fieldnames(dataLimits);
iSet = ~ismember(varNames, allVarNames);
if any(iSet)
    dataLimits = rmfield(dataLimits, varNames(iSet));
end

end
