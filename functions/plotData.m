%%
function plotData(hObject)
%PLOTDATA plot marked variables in sample_data
%
% Inputs:
%   hObject - handle to figure

% set re-entrancy flag
persistent hash;
if isempty(hash)
    hash = java.util.Hashtable;
end
if ~isempty(hash.get(hObject))
    return;
end
hash.put(hObject,1);
if isempty(hObject), return; end

hFig = ancestor(hObject,'figure');
if isempty(hFig), return; end

userData = getappdata(hFig, 'UserData');
if isempty(userData.sample_data), return; end

% retrieve good flag values
qcSet     = str2double(readProperty('toolbox.qc_set'));
rawFlag   = imosQCFlag('raw', qcSet, 'flag');
goodFlag  = imosQCFlag('good', qcSet, 'flag');
%pGoodFlag = imosQCFlag('probablyGood', qcSet, 'flag');
goodFlags = [rawFlag, goodFlag]; %, pGoodFlag];

figure(hFig); %make figure current
gData = guidata(hFig);

%% testing number of subplots calculation
% VARS_OVERLAY : one plot with all vars
% VARS_STACKED : subplots with common vars per subplot
% VARS_SINGLE : subplot per var, not implemented yet
% for each marked variable assign it an subplot/axis number
switch upper(userData.plotType)
    case 'VARS_OVERLAY'
        %userData.plotVarNames
        nSubPlots = 1;
        for ii=1:numel(userData.sample_data) % loop over files
            userData.sample_data{ii}.axisIndex = zeros(size(userData.sample_data{ii}.plotThisVar));
            iVars = find(userData.sample_data{ii}.plotThisVar)';
            %markedVarNames = arrayfun(@(x) userData.sample_data{ii}.variables{x}.name, iVars, 'UniformOutput', false);
            userData.sample_data{ii}.axisIndex(iVars) = 1;
        end
        
    case 'VARS_STACKED'
        %userData.plotVarNames
        nSubPlots = numel(userData.plotVarNames);
        for ii=1:numel(userData.sample_data) % loop over files
            userData.sample_data{ii}.axisIndex = zeros(size(userData.sample_data{ii}.plotThisVar));
            iVars = find(userData.sample_data{ii}.plotThisVar)';
            markedVarNames = arrayfun(@(x) userData.sample_data{ii}.variables{x}.name, iVars, 'UniformOutput', false);
            userData.sample_data{ii}.axisIndex(iVars) = cell2mat(arrayfun(@(x) find(strcmp(x,userData.plotVarNames)), markedVarNames, 'UniformOutput', false));
        end
        
    otherwise
        disp('help');
end

%% determine QC use
try
    useQCflags = userData.plotQC;
catch
    useQCflags = false;
end
useFlags = 'RAW';
if useQCflags, useFlags='QC'; end

%% create list of variable names that will be plotted
varNames={};
for ii=1:numel(userData.sample_data)
    iVars = find(userData.sample_data{ii}.plotThisVar)';
    for jj = iVars
        theVar = userData.sample_data{ii}.variables{jj}.name;
        varNames{end+1}=theVar;
    end
end
varNames=unique(varNames);
userData.dataLimits=findVarExtents(userData.sample_data, varNames);

%% Create a string for legend
legendStr={};

%% delete old plots
children = findobj(gData.plotPanel,'Type','axes');
if ~isempty(children)
    xlimits = get(children(1), 'XLim');
    userData.plotLimits.TIME.xMin = xlimits(1);
    userData.plotLimits.TIME.xMax = xlimits(2);
    delete(children);
end

%%
% loop over sample_data and plot the marked variables into previously
% calculated subplot/axis number
%varNames={};
hAx=gobjects(nSubPlots,1);
legendStr = cell(nSubPlots,1);
for ii=1:numel(userData.sample_data)
    iVars = find(userData.sample_data{ii}.plotThisVar)';
    legendString = {};
    for jj = iVars
        theVar = userData.sample_data{ii}.variables{jj}.name;
        ihAx = userData.sample_data{ii}.axisIndex(jj);
        hAx(ihAx) = subplot(nSubPlots,1,ihAx,'Parent',gData.plotPanel);
        grid(hAx(ihAx),'on');
        %hAx(ihAx) = subplot_tight(nSubPlots,1,ihAx,[0.02 0.02],'Parent',gData.plotPanel);
        %axes(hAx(ihAx));
        % for each subplot set a tag and xlim/ylim
        switch upper(userData.plotType)
            case 'VARS_OVERLAY'
                hAx(ihAx).Tag = 'MULTI';
                if isfield(userData.plotLimits, 'TIME') & isfinite(userData.plotLimits.TIME.xMin) & isfinite(userData.plotLimits.TIME.xMax)
                    set(hAx(ihAx),'XLim',[userData.plotLimits.TIME.xMin userData.plotLimits.TIME.xMax]);
                else
                    set(hAx(ihAx),'XLim',[userData.dataLimits.TIME.RAW.xMin userData.dataLimits.TIME.RAW.xMax]);
                end
                if ~isfield(userData.plotLimits, 'MULTI')
                    userData.plotLimits.MULTI.yMin = userData.dataLimits.MULTI.(useFlags).yMin;
                    userData.plotLimits.MULTI.yMax = userData.dataLimits.MULTI.(useFlags).yMax;
                end
                
            case 'VARS_STACKED'
                hAx(ihAx).Tag = theVar;
                if isfield(userData.plotLimits, 'TIME') & isfinite(userData.plotLimits.TIME.xMin) & isfinite(userData.plotLimits.TIME.xMax)
                    set(hAx(ihAx),'XLim',[userData.plotLimits.TIME.xMin userData.plotLimits.TIME.xMax]);
                else
                    set(hAx(ihAx),'XLim',[userData.dataLimits.TIME.RAW.xMin userData.dataLimits.TIME.RAW.xMax]);
                end
                if ~isfield(userData.plotLimits, theVar)
                    userData.plotLimits.(theVar).yMin = userData.dataLimits.(theVar).(useFlags).yMin;
                    userData.plotLimits.(theVar).yMax = userData.dataLimits.(theVar).(useFlags).yMax;
                end
                set(hAx(ihAx),'YLim',[userData.plotLimits.(theVar).yMin userData.plotLimits.(theVar).yMax]);
        end
        
        if strcmp(userData.sample_data{ii}.variables{jj}.name,'EP_TIMEDIFF')
            lineStyle='none';
            markerStyle='.';
        else
            lineStyle='-';
            markerStyle='none';
        end
        
        if strfind(theVar, 'EP_LPF')
            idTime  = getVar(userData.sample_data{ii}.dimensions, 'LPFTIME');
        else
            idTime  = getVar(userData.sample_data{ii}.dimensions, 'TIME');
        end
        
        instStr=strcat(theVar, '-',userData.sample_data{ii}.meta.instrument_model,'-',userData.sample_data{ii}.meta.instrument_serial_no);
        instStr = regexprep(instStr, '[^ -~]', '-'); %only printable ascii characters
        %disp(['Size : ' num2str(size(handles.sample_data{ii}.variables{jj}.data))]);
        %[PATHSTR,NAME,EXT] = fileparts(userData.sample_data{ii}.toolbox_input_file);
        tagStr = [userData.sample_data{ii}.inputFile userData.sample_data{ii}.inputFileExt];
        try
            if isvector(userData.sample_data{ii}.variables{jj}.data)
                % 1D var
                ydataVar = userData.sample_data{ii}.variables{jj}.data;
                if useQCflags & isfield(userData.sample_data{ii}.variables{jj}, 'flags')
                    varFlags = userData.sample_data{ii}.variables{jj}.flags;
                    iGood = ismember(varFlags, goodFlags);
                    ydataVar(~iGood) = NaN;
                end
                hLine = line('Parent',hAx(ihAx),'XData',userData.sample_data{ii}.dimensions{idTime}.data, ...
                    'YData',ydataVar, ...
                    'LineStyle',lineStyle, 'Marker', markerStyle,...
                    'DisplayName', instStr, 'Tag', instStr);
            else
                % 2D var
                iSlice = userData.sample_data{ii}.variables{jj}.iSlice;
                ydataVar = userData.sample_data{ii}.variables{jj}.data(:,iSlice);
                if useQCflags & isfield(userData.sample_data{ii}.variables{jj}, 'flags')
                    varFlags = userData.sample_data{ii}.variables{jj}.flags(:,iSlice);
                    iGood = ismember(varFlags, goodFlags);
                    ydataVar(~iGood) = NaN;
                end
                hLine = line('Parent',hAx(ihAx),'XData',userData.sample_data{ii}.dimensions{idTime}.data, ...
                    'YData',ydataVar, ...
                    'LineStyle',lineStyle, 'Marker', markerStyle,...
                    'DisplayName', instStr, 'Tag', instStr);
            end
            userData.sample_data{ii}.variables{jj}.hLine = hLine;
        catch
            error('PLOTDATA: plot failed.');
        end
        hold(hAx(ihAx),'on');
        legendStr{ihAx}{end+1}=strrep(instStr,'_','\_');
        hAx(ihAx).UserData.legendStrings = legendStr{ihAx};
        set(gData.progress,'String',strcat('Plot : ', instStr));
    end
end

linkaxes(hAx,'x');

%% update y labels
updateYlabels( hFig );

%% update line colours
updateLineColour( hFig );

%% update legends
updateLegends( hFig );

%% update xlabels (linked so only have to do one)
updateDateLabel(hFig,struct('Axes', hAx(1)), true);

%% update progress string and save UserData
set(gData.progress,'String','Done');
setappdata(hFig, 'UserData', userData);
drawnow;

% release rentrancy flag
hash.remove(hObject);

end
