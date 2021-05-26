function plotData(hObject)
%PLOTDATA plot marked variables in sample_data
%
% Inputs:
%   hObject - handle to figure

if isempty(hObject), return; end

% set re-entrancy flag
persistent hash;
if isempty(hash)
    hash = java.util.Hashtable;
end
if ~isempty(hash.get(hObject))
    pause(0.1);
    return;
end
hash.put(hObject,1);

hFig = ancestor(hObject,'figure');
if isempty(hFig)
    hash.remove(hObject);
    return;
end

userData = getappdata(hFig, 'UserData');
if isempty(userData.sample_data)
    plotPanel = findobj(hFig, 'Tag','plotPanel');
    hLegend = findobj(plotPanel.Children,'Tag','legend');
    delete(hLegend);
    pause(0.1);
    hash.remove(hObject);
    return; 
end

% retrieve good flag values
goodFlags = getGoodFlags();

figure(hFig); %make figure current

msgPanel = findobj(hFig, 'Tag','msgPanel');
msgPanelText = findobj(msgPanel, 'Tag','msgPanelText');
plotPanel = findobj(hFig, 'Tag','plotPanel');
graphs = findobj(plotPanel,'Type','axes','-not','tag','legend','-not','tag','Colobar');
hLine = gobjects(0);

%%
[userData.sample_data, varNames, varDeleteNames, varNewNames, plotVarCounter] = countVars(userData.sample_data);

isEmptyPlotPanel = isempty(plotPanel.Children);
isAnyEmptyGraphs = any(arrayfun(@(x) isempty(x.Children), graphs));
isPlotTypeChange = strcmpi(userData.EP_plotType,'VARS_STACKED') && (~isempty(graphs) && strcmp(graphs(1).Tag, 'MULTI')) || ...
    strcmpi(userData.EP_plotType,'VARS_OVERLAY') && (~isempty(graphs) && ~strcmp(graphs(1).Tag, 'MULTI'));
isNewSubplot = strcmpi(userData.EP_plotType,'VARS_STACKED') && ...
    (~isempty(varNames) && ~isempty(varNewNames) && ...
    ~any(strcmp(varNewNames, varNames)));

% % require || result redoSubplots = false
% isNotP1 = strcmpi(userData.EP_plotType, 'VARS_OVERLAY') && ... % overlay
%     ~isempty(varNames);                                     % have plotted some variable
% % stacked and there is some variable to plot 
% isNotP2 = strcmpi(userData.EP_plotType,'VARS_STACKED') && ...
%     all(cellfun(@(x) plotVarCounter.(x) > 0, fieldnames(plotVarCounter)));
% % stacked and no new vars plotted
% isNotP3 = strcmpi(userData.EP_plotType,'VARS_STACKED') && ...
%     ~isempty(varNames) && isempty(varNewNames);

% require || result redoSubplots = true
redoSubplots = false;
if isEmptyPlotPanel || isAnyEmptyGraphs || isPlotTypeChange || isNewSubplot || userData.EP_redoPlots
    redoSubplots = true;
end

%
if ~isempty(varNewNames)
    varNames = {varNames{:} varNewNames{:}};
    varNames=sort(unique(varNames));
end
userData.plotVarNames = varNames;

%%
if ~redoSubplots && ~isempty(varDeleteNames) && isempty(varNewNames)
    %updateDateLabel(hFig,struct('Axes', graphs(1)), true);
    updateLegends(hFig);
    set(msgPanelText,'String','Done');
    setappdata(hFig, 'UserData', userData);
    % is this needed?
    %drawnow;
    
    % return early if overlay/stacked graphs still have lines and no new
    % plots are to be added
    if  (strcmpi(userData.EP_plotType,'VARS_OVERLAY') & any(cellfun(@(x) plotVarCounter.(char(x)) > 0, fieldnames(plotVarCounter)))) || ...
            (strcmpi(userData.EP_plotType,'VARS_STACKED') & all(cellfun(@(x) plotVarCounter.(char(x)) > 0, fieldnames(plotVarCounter))))
        %updateLegends(hFig);
        % release rentrancy flag
        hash.remove(hObject);
        return
    end
end

%% update axis index
[userData.sample_data, nSubPlots] = calcAxisIndex(userData.sample_data, userData.EP_plotType, varNames);

%% determine QC use
try
    useQCflags = userData.EP_plotQC;
catch
    useQCflags = false;
end
useFlags = 'RAW';
if useQCflags, useFlags='QC'; end

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
for ii = 1:numel(userData.sample_data)
    iVars = find(userData.sample_data{ii}.EP_variablePlotStatus == 2)';
    if redoSubplots
        iVars = find(userData.sample_data{ii}.EP_variablePlotStatus > 0)';
    end
    for jj = iVars
        legendString = {};
        theVar = userData.sample_data{ii}.variables{jj}.name;
        ihAx = userData.sample_data{ii}.axisIndex(jj);
        if redoSubplots
            graphs(ihAx) = subplot(nSubPlots,1,ihAx,'Parent',plotPanel);
            graphs(ihAx).UserData.axesInfo = userData.axesInfo;
        else
            switch upper(userData.EP_plotType)
                case 'VARS_OVERLAY'
                    %axes(graphs(1));
                    set(hFig,'CurrentAxes', graphs(1));
                case 'VARS_STACKED'
                    ihAx = find(strcmp({graphs.Tag}, theVar));
                    %axes(graphs(ihAx));
                    set(hFig,'CurrentAxes', graphs(ihAx));
            end
            %grid(graphs(ihAx), 'on');
        end
        
        %hAx(ihAx) = subplot_tight(nSubPlots,1,ihAx,[0.02 0.02],'Parent',plotPanel);
        
        % for each subplot set a tag and xlim/ylim
        switch upper(userData.EP_plotType)
            case 'VARS_OVERLAY'
                graphs(ihAx).Tag = 'MULTI';
                if userData.EP_plotYearly
                    set(graphs(ihAx),'XLim',[1 367])
                else
                    if isfield(userData.plotLimits, 'TIME') && isfinite(userData.plotLimits.TIME.xMin) && isfinite(userData.plotLimits.TIME.xMax)
                        set(graphs(ihAx),'XLim',[userData.plotLimits.TIME.xMin userData.plotLimits.TIME.xMax]);
                    else
                        set(graphs(ihAx),'XLim',[userData.dataLimits.TIME.RAW.xMin userData.dataLimits.TIME.RAW.xMax]);
                    end
                end
                if ~isfield(userData.plotLimits, 'MULTI')
                    userData.plotLimits.MULTI.yMin = userData.dataLimits.MULTI.(useFlags).yMin;
                    userData.plotLimits.MULTI.yMax = userData.dataLimits.MULTI.(useFlags).yMax;
                end
                
            case 'VARS_STACKED'
                graphs(ihAx).Tag = theVar;
                if userData.EP_plotYearly
                    set(graphs(ihAx),'XLim',[1 367])
                else
                    if isfield(userData.plotLimits, 'TIME') && isfinite(userData.plotLimits.TIME.xMin) && isfinite(userData.plotLimits.TIME.xMax)
                        set(graphs(ihAx),'XLim',[userData.plotLimits.TIME.xMin userData.plotLimits.TIME.xMax]);
                    else
                        set(graphs(ihAx),'XLim',[userData.dataLimits.TIME.RAW.xMin userData.dataLimits.TIME.RAW.xMax]);
                    end
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
        
        % if plotting LPF variable use LPF time
        if strfind(theVar, 'LPF_')
            idTime  = getVar(userData.sample_data{ii}.dimensions, 'LPFTIME');
        else
            idTime  = getVar(userData.sample_data{ii}.dimensions, 'TIME');
        end

        instStr=strcat(theVar, '-',userData.sample_data{ii}.meta.EP_instrument_model_shortname,'-',userData.sample_data{ii}.meta.EP_instrument_serial_no_deployment);
        instStr = regexprep(instStr, '[^ -~]', '-'); %only printable ascii characters
        legendString = strrep(instStr,'_','\_');
        try
            % xdata
            xdataVar = getXdata(userData.sample_data{ii}.dimensions{idTime});
            
            % ydata
            ydataVar = getYdata(userData.sample_data{ii}.variables{jj}, useQCflags);
            
            if userData.EP_plotYearly
                yyyy = year(xdataVar);
                yStart = yyyy(1);
                yEnd = yyyy(end);
                for yr = yStart:yEnd
                    yGood = yyyy == yr;
                    hLine = line('Parent',graphs(ihAx),'XData',xdataVar(yGood) - datenum(yr,1,1,0,0,0), ...
                        'YData',ydataVar(yGood), ...
                        'LineStyle',lineStyle, 'Marker', markerStyle,...
                        'DisplayName', legendString, 'Tag', instStr);
                end
            else
                hLine = line('Parent',graphs(ihAx),'XData',xdataVar, ...
                    'YData',ydataVar, ...
                    'LineStyle',lineStyle, 'Marker', markerStyle,...
                    'DisplayName', legendString, 'Tag', instStr);
            end
            
            hLine.UserData.legendString = legendString;
            [~, fNAME, fEXT] = fileparts(userData.sample_data{ii}.toolbox_input_file);
            hLine.UserData.fileName = [strtrim(fNAME), strtrim(fEXT)];
            userData.sample_data{ii}.variables{jj}.hLine = hLine;
            userData.sample_data{ii}.EP_variablePlotStatus(jj) = 1;
        catch e
            disp(e.message);
            for ie = 1:numel(e.stack)
               e.stack(ie)
            end
            hash.remove(hObject);
            warning('PLOTDATA: plot failed.');
            return
        end
        hold(graphs(ihAx),'on');
        set(msgPanelText,'String',strcat('Plot : ', instStr));
    end
end

%% update line colours, labels and legends
updateLineColour( hFig );

if redoSubplots
    % link all/any subplot axes
    dragzoom(graphs);
    linkaxes(graphs,'x');
    
    % update date labels, only pass one axis and it will update any others
    updateDateLabel([], struct('Axes', graphs(1)), false);
    
    % not the best when have multiline xticklabels, not sure why yet.
    addlistener(graphs, 'XLim', 'PostSet', @updateDateLabel);
    
    % update ylabels
    for ii=1:length(graphs)
        set(hFig,'CurrentAxes', graphs(ii));
        updateYlabel( graphs(ii) );
        grid(graphs(ii),'on');
    end
end

updateLegends(hFig);

%% update progress string and save UserData
set(msgPanelText,'String','Done');
userData.EP_redoPlots = false;
setappdata(hFig, 'UserData', userData);
% is this needed?
pause(0.1);
drawnow;

% release rentrancy flag
hash.remove(hObject);

end
