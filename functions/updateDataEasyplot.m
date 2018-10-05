%%
function sam = updateDataEasyplot(sam)
%updateDataEasyplot Adds new EP_TIMEDIFF var
%
% Inputs:
%   sam             - a struct containing sample data.
%
% Outputs:
%   sample_data - same as input, with fields added/modified

%% retrieve good flag values
qcSet     = str2double(readProperty('toolbox.qc_set'));
rawFlag   = imosQCFlag('raw', qcSet, 'flag');
goodFlag  = imosQCFlag('good', qcSet, 'flag');
goodFlags = [rawFlag, goodFlag];

%%
if isfield(sam.meta, 'latitude')
    defaultLatitude = sam.meta.latitude;
else
    defaultLatitude = NaN;
end

%%
idTime  = getVar(sam.dimensions, 'TIME');

%% add derived diagnositic variables, prefaces with 'EP_'
sam = add_EP_TIMEDIFF(sam);
[sam, defaultLatitude] = add_EP_PSAL(sam, defaultLatitude);
[sam, defaultLatitude] = add_EP_DEPTH(sam, defaultLatitude);

% done after adding other variables
sam = add_EP_LPF(sam);

% calculate data limits
for ii=1:numel(sam.variables)
    EP_LIMITS = struct;
    RAW = struct;
    QC = struct;
    
    eps=1e-1;
    RAW.xMin = NaN;
    RAW.xMax = NaN;
    QC.xMin = NaN;
    QC.xMax = NaN;
    RAW.yMin = NaN;
    RAW.yMax = NaN;
    QC.yMin = NaN;
    QC.yMax = NaN;
    % is this an imos nc file
    isIMOS = isfield(sam, 'Conventions') && ~isempty(strfind(sam.Conventions, 'IMOS')) &&...
        strcmp(sam.inputFileExt, '.nc');
    
    %theVar = sam.variables{ii}.name;
    idTime  = getVar(sam.dimensions, 'TIME');
    theOffset = sam.dimensions{idTime}.EP_OFFSET;
    theScale = sam.dimensions{idTime}.EP_SCALE;
    RAW.xMin=min(sam.dimensions{idTime}.data(1)+theOffset, RAW.xMin);
    RAW.xMax=max(sam.dimensions{idTime}.data(end)+theOffset, RAW.xMax);
    if ~isfinite(RAW.xMin), RAW.xMin=floor(now); end
    if ~isfinite(RAW.xMax), RAW.xMax=floor(now)+1; end
    QC.xMin = RAW.xMin;
    QC.xMax = RAW.xMax;
    
    theOffset = sam.variables{ii}.EP_OFFSET;
    theScale = sam.variables{ii}.EP_SCALE;
    yData = theOffset + double(sam.variables{ii}.data).*theScale;
    RAW.yMin=min(min(yData), RAW.yMin);
    RAW.yMax=max(max(yData), RAW.yMax);
    
    if isIMOS
        if isfield(sam.variables{ii}, 'flags')
            varFlags = int8(sam.variables{ii}.flags);
            iGood = ismember(varFlags, goodFlags);
            yData(~iGood) = NaN;
        end
        QC.yMin=min(min(yData), QC.yMin);
        QC.yMax=max(max(yData), QC.yMax);
    else
        QC.yMin = RAW.yMin;
        QC.yMax = RAW.yMax;
    end
    
    if RAW.yMax - RAW.yMin < eps
        RAW.yMax = RAW.yMax*1.05;
        RAW.yMin = RAW.yMin*0.95;
    end
    if QC.yMax - QC.yMin < eps
        QC.yMax = QC.yMax*1.05;
        QC.yMin = QC.yMin*0.95;
    end
    
    if ~isfinite(RAW.yMin), RAW.yMin=0; end
    if ~isfinite(RAW.yMax), RAW.yMax=1; end
    
    if ~isfinite(QC.yMin), QC.yMin=0; end
    if ~isfinite(QC.yMax), QC.yMax=1; end
    
    EP_LIMITS.QC = QC;
    EP_LIMITS.RAW = RAW;
    sam.variables{ii}.EP_LIMITS = EP_LIMITS;
end

end
