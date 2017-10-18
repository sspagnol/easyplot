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

msgPanel = findobj(hFig, 'Tag','msgPanel');
msgPanelText = findobj(msgPanel, 'Tag','msgPanelText');
plotPanel = findobj(hFig, 'Tag','plotPanel');

%% create list of variable names that will be plotted, delete plots as required
varNames={};
varDeleteNames={};
varNewNames={};
plotVarCounter = struct;
hLine = gobjects(0);
% count up plots per variable, order is important
% variables to delete
for ii=1:numel(userData.sample_data)
    iDeletePlotVars = find(userData.sample_data{ii}.variablePlotStatus == -1)';
    if ~isempty(iDeletePlotVars)
        for jj = iDeletePlotVars
            theVar = userData.sample_data{ii}.variables{jj}.name;
            if isfield (plotVarCounter, theVar)
                plotVarCounter.(theVar) = plotVarCounter.(theVar) - 1;
            else
                plotVarCounter.(theVar) = 0;
            end
            % delete the plot
            delete(userData.sample_data{ii}.variables{jj}.hLine);
            % is this required?
            %userData.sample_data{ii}.variables{jj} = rmfield(userData.sample_data{ii}.variables{jj},'hLine');
            varDeleteNames{end+1}=theVar;
            userData.sample_data{ii}.variablePlotStatus(jj) = 0;
        end
    end
end
% variables already plotted
for ii=1:numel(userData.sample_data)
    iPlotVars = find(userData.sample_data{ii}.variablePlotStatus == 1)';
    if ~isempty(iPlotVars)
        for jj = iPlotVars
            theVar = userData.sample_data{ii}.variables{jj}.name;
            if isfield (plotVarCounter, theVar)
                plotVarCounter.(theVar) = plotVarCounter.(theVar) + 1;
            else
                plotVarCounter.(theVar) = 1;
            end
            varNames{end+1}=theVar;
        end
    end
end
% variables added since last plot
for ii=1:numel(userData.sample_data)
    iNewPlotVars = find(userData.sample_data{ii}.variablePlotStatus == 2)';
    if ~isempty(iNewPlotVars)
        for jj = iNewPlotVars
            theVar = userData.sample_data{ii}.variables{jj}.name;
            if isfield (plotVarCounter, theVar)
                plotVarCounter.(theVar) = plotVarCounter.(theVar) + 1;
            else
                plotVarCounter.(theVar) = 1;
            end
            varNewNames{end+1}=theVar;
        end
    end
end
%plotVarCounter
varNames=sort(unique(varNames));
varDeleteNames=sort(unique(varDeleteNames));
varNewNames=sort(unique(varNewNames));

%%
graphs = findobj(plotPanel,'Type','axes','-not','tag','legend','-not','tag','Colobar');
% require result redoSubplots = true
redoSubplots = true;
isEmptyPlotPanel = isempty(plotPanel.Children);
isAnyEmptyStackedPlots = strcmpi(userData.plotType, 'VARS_STACKED') && any(cellfun(@(x) plotVarCounter.(x) == 0, fieldnames(plotVarCounter)));
isAnyEmptyOverlayPlots = strcmpi(userData.plotType, 'VARS_OVERLAY') && all(cellfun(@(x) plotVarCounter.(x) == 0, fieldnames(plotVarCounter)));
isPlotTypeChange = strcmpi(userData.plotType,'VARS_STACKED') && (~isempty(graphs) && strcmp(graphs(1).Tag, 'MULTI')) || ...
    strcmpi(userData.plotType,'VARS_OVERLAY') && (~isempty(graphs) && ~strcmp(graphs(1).Tag, 'MULTI'));
isNewSubplot = strcmpi(userData.plotType,'VARS_STACKED') && ...
    (~isempty(varNames) && ~isempty(varNewNames) && ...
    ~any(strcmp(varNewNames, varNames)));

% require result redoSubplots = false
isNotP1 = strcmpi(userData.plotType, 'VARS_OVERLAY') && ... % overlay
    ~isempty(varNames);                                     % have plotted some variable
% isNotP2 = strcmpi(userData.plotType,'VARS_STACKED') && ~isempty(varNames) && ~isempty(varNewNames) && any(strcmp(varNewNames, varNames));
% isNotP2 = strcmpi(userData.plotType,'VARS_STACKED') && ...  % stacked
%     ~isempty(varNames) && ~isempty(varNewNames) && ...      % have non empty old/new vars
%     any(strcmp(varNewNames, varNames)) && ...               % new var is already plotted
%     all(cellfun(@(x) plotVarCounter.(x) > 0, fieldnames(plotVarCounter))); %
isNotP2 = strcmpi(userData.plotType,'VARS_STACKED') && ...
    all(cellfun(@(x) plotVarCounter.(x) > 0, fieldnames(plotVarCounter)));

isNotP3 = strcmpi(userData.plotType,'VARS_STACKED') && ...
    ~isempty(varNames) && isempty(varNewNames);

if isEmptyPlotPanel || isAnyEmptyStackedPlots || isPlotTypeChange || isNewSubplot
    redoSubplots = true;
elseif isNotP1 || isNotP2 || isNotP3
    redoSubplots = false;
end

%%
if ~redoSubplots && ~isempty(varDeleteNames) && isempty(varNewNames)
    %updateDateLabel(hFig,struct('Axes', graphs(1)), true);
    set(msgPanelText,'String','Done');
    setappdata(hFig, 'UserData', userData);
    % is this needed?
    drawnow;
    
    % return early if overlay/stacked graphs still have lines and no new
    % plots are to be added
    if  (strcmpi(userData.plotType,'VARS_OVERLAY') & any(cellfun(@(x) plotVarCounter.(char(x)) > 0, fieldnames(plotVarCounter)))) || ...
            (strcmpi(userData.plotType,'VARS_STACKED') & all(cellfun(@(x) plotVarCounter.(char(x)) > 0, fieldnames(plotVarCounter))))
        % release rentrancy flag
        hash.remove(hObject);
        return
    end
end

if ~isempty(varNewNames)
    varNames{end+1} = varNewNames{:};
    varNames=sort(unique(varNames));
end

userData.plotVarNames = varNames;

%% testing number of subplots calculation
% VARS_OVERLAY : one plot with all vars
% VARS_STACKED : subplots with common vars per subplot
% VARS_SINGLE : subplot per var, not implemented yet
% for each marked variable assign it an subplot/axis number
switch upper(userData.plotType)
    case 'VARS_OVERLAY'
        nSubPlots = 1;
        for ii=1:numel(userData.sample_data)
            userData.sample_data{ii}.axisIndex = zeros(size(userData.sample_data{ii}.variablePlotStatus));
            iVars = find(userData.sample_data{ii}.variablePlotStatus > 0)';
            %markedVarNames = arrayfun(@(x) userData.sample_data{ii}.variables{x}.name, iVars, 'UniformOutput', false);
            userData.sample_data{ii}.axisIndex(iVars) = 1;
        end
        
    case 'VARS_STACKED'
        nSubPlots = numel(varNames);
        for ii=1:numel(userData.sample_data)
            userData.sample_data{ii}.axisIndex = zeros(size(userData.sample_data{ii}.variablePlotStatus));
            iVars = find(userData.sample_data{ii}.variablePlotStatus > 0)';
            markedVarNames = arrayfun(@(x) userData.sample_data{ii}.variables{x}.name, iVars, 'UniformOutput', false);
            userData.sample_data{ii}.axisIndex(iVars) = cell2mat(arrayfun(@(x) find(strcmp(x,varNames)), markedVarNames, 'UniformOutput', false));
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

% data limits for those variables
userData.dataLimits=findVarExtents(userData.sample_data, varNames);

%% Create a string for legend
legendStr={};

%% delete old subplots if required
graphs = findobj(plotPanel,'Type','axes','-not','tag','legend','-not','tag','Colobar');
if redoSubplots
    if ~isempty(graphs)
        xlimits = get(graphs(1), 'XLim');
        userData.plotLimits.TIME.xMin = xlimits(1);
        userData.plotLimits.TIME.xMax = xlimits(2);
        delete(graphs);
    end
    graphs=gobjects(nSubPlots,1);
end

%%
% loop over sample_data and plot the marked variables into previously
% calculated subplot/axis number
%varNames={};

legendStr = cell(nSubPlots,1);
for ii = 1:numel(userData.sample_data)
    iVars = find(userData.sample_data{ii}.variablePlotStatus == 2)';
    if redoSubplots
        iVars = find(userData.sample_data{ii}.variablePlotStatus > 0)';
    end
    for jj = iVars
        legendString = {};
        theVar = userData.sample_data{ii}.variables{jj}.name;
        ihAx = userData.sample_data{ii}.axisIndex(jj);
        if redoSubplots
            graphs(ihAx) = subplot(nSubPlots,1,ihAx,'Parent',plotPanel);
            
        else
            switch upper(userData.plotType)
                case 'VARS_OVERLAY'
                    axes(graphs(1));
                case 'VARS_STACKED'
                    ihAx = find(strcmp({graphs.Tag}, theVar));
                    axes(graphs(ihAx));
            end
        end
        
        %hAx(ihAx) = subplot_tight(nSubPlots,1,ihAx,[0.02 0.02],'Parent',plotPanel);
        
        % for each subplot set a tag and xlim/ylim
        switch upper(userData.plotType)
            case 'VARS_OVERLAY'
                graphs(ihAx).Tag = 'MULTI';
                if isfield(userData.plotLimits, 'TIME') & isfinite(userData.plotLimits.TIME.xMin) & isfinite(userData.plotLimits.TIME.xMax)
                    set(graphs(ihAx),'XLim',[userData.plotLimits.TIME.xMin userData.plotLimits.TIME.xMax]);
                else
                    set(graphs(ihAx),'XLim',[userData.dataLimits.TIME.RAW.xMin userData.dataLimits.TIME.RAW.xMax]);
                end
                if ~isfield(userData.plotLimits, 'MULTI')
                    userData.plotLimits.MULTI.yMin = userData.dataLimits.MULTI.(useFlags).yMin;
                    userData.plotLimits.MULTI.yMax = userData.dataLimits.MULTI.(useFlags).yMax;
                end
                
            case 'VARS_STACKED'
                graphs(ihAx).Tag = theVar;
                if isfield(userData.plotLimits, 'TIME') & isfinite(userData.plotLimits.TIME.xMin) & isfinite(userData.plotLimits.TIME.xMax)
                    set(graphs(ihAx),'XLim',[userData.plotLimits.TIME.xMin userData.plotLimits.TIME.xMax]);
                else
                    set(graphs(ihAx),'XLim',[userData.dataLimits.TIME.RAW.xMin userData.dataLimits.TIME.RAW.xMax]);
                end
                if ~isfield(userData.plotLimits, theVar)
                    userData.plotLimits.(theVar).yMin = userData.dataLimits.(theVar).(useFlags).yMin;
                    userData.plotLimits.(theVar).yMax = userData.dataLimits.(theVar).(useFlags).yMax;
                end
                set(graphs(ihAx),'YLim',[userData.plotLimits.(theVar).yMin userData.plotLimits.(theVar).yMax]);
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
        legendString = strrep(instStr,'_','\_');
        try
            if isvector(userData.sample_data{ii}.variables{jj}.data)
                % 1D var
                ydataVar = userData.sample_data{ii}.variables{jj}.data;
                if useQCflags & isfield(userData.sample_data{ii}.variables{jj}, 'flags')
                    varFlags = userData.sample_data{ii}.variables{jj}.flags;
                    iGood = ismember(varFlags, goodFlags);
                    ydataVar(~iGood) = NaN;
                end
                hLine = line('Parent',graphs(ihAx),'XData',userData.sample_data{ii}.dimensions{idTime}.data, ...
                    'YData',ydataVar, ...
                    'LineStyle',lineStyle, 'Marker', markerStyle,...
                    'DisplayName', legendString, 'Tag', instStr);
            else
                % 2D var
                iSlice = userData.sample_data{ii}.variables{jj}.iSlice;
                ydataVar = userData.sample_data{ii}.variables{jj}.data(:,iSlice);
                if useQCflags & isfield(userData.sample_data{ii}.variables{jj}, 'flags')
                    varFlags = userData.sample_data{ii}.variables{jj}.flags(:,iSlice);
                    iGood = ismember(varFlags, goodFlags);
                    ydataVar(~iGood) = NaN;
                end
                hLine = line('Parent',graphs(ihAx),'XData',userData.sample_data{ii}.dimensions{idTime}.data, ...
                    'YData',ydataVar, ...
                    'LineStyle',lineStyle, 'Marker', markerStyle,...
                    'DisplayName', legendString, 'Tag', instStr);
            end
            hLine.UserData.legendString = legendString;
            userData.sample_data{ii}.variables{jj}.hLine = hLine;
            userData.sample_data{ii}.variablePlotStatus(jj) = 1;
        catch
            error('PLOTDATA: plot failed.');
        end
        hold(graphs(ihAx),'on');
        legendStr{ihAx}{end+1}=strrep(instStr,'_','\_');
        graphs(ihAx).UserData.legendStrings = legendStr{ihAx};
        set(msgPanelText,'String',strcat('Plot : ', instStr));
    end
end

%% update line colours
updateLineColour( hFig );

if redoSubplots
    % link all/any subplot axes
    linkaxes(graphs,'x');
    
    % not the best when have multiline xticklabels, not sure why yet.
    %addlistener(graphs, 'XLim', 'PostSet', @updateDateLabel);
    
    % update y labels
    updateYlabels( hFig );
    
    % update legends
    for ii=1:length(graphs)
        axes(graphs(ii));
        graphs(ii).UserData.axesInfo = userData.axesInfo;
        updateDateLabel([], struct('Axes', graphs(ii)), false);
        grid(graphs(ii),'on');
        hLegend = legend('show');
        hLegend.FontSize = 8;
    end
end

%% update progress string and save UserData
set(msgPanelText,'String','Done');
setappdata(hFig, 'UserData', userData);
% is this needed?
drawnow;

% release rentrancy flag
hash.remove(hObject);

end
