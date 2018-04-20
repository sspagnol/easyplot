function varargout = easyplot(varargin)
%EASYPLOT MATLAB code for oceanographic field data viewing using
%imos-toolbox parser routines.

% window figure
hFig = figure(...
    'Name',        'Easyplot', ...
    'Visible',     'on',...
    'Color',       [1 1 1],...
    'MenuBar',     'none',...
    'ToolBar',     'figure',...
    'Resize',      'on',...
    'WindowStyle', 'Normal',...
    'NumberTitle', 'off',...
    'Tag',         'mainWindow');

set(hFig,'CloseRequestFcn',@exit_Callback);

userData=getappdata(hFig,'UserData');

% add menu items
m=uimenu(hFig, 'Label', 'Easyplot');
sm1=uimenu(m, 'Label', 'Plot Vars As...');
uimenu(sm1, 'Label', 'VARS_OVERLAY', 'Checked','on','Callback', @plotType_Callback);
uimenu(sm1, 'Label', 'VARS_STACKED', 'Callback', @plotType_Callback);
uimenu(m, 'Label', 'Plot Time as Day Number', 'Checked','off', 'Callback', @plotYearly_Callback);
uimenu(m, 'Label', 'Use QC flags', 'Callback', @useQCflags_Callback);
uimenu(m, 'Label', 'Do Bath Calibrations', 'Callback', @BathCals_Callback);
uimenu(m, 'Label', 'Do Time Offset', 'Callback', @timeOffsets_Callback);
uimenu(m, 'Label', 'Load filelist (YML)', 'Callback', @loadFilelist_Callback);
uimenu(m, 'Label', 'Save filelist (YML)', 'Callback', @saveFilelist_Callback);
uimenu(m, 'Label', 'Save Image', 'Callback', @saveImage_Callback);
uimenu(m, 'Label', 'Quit', 'Callback', @exit_Callback,...
    'Separator','on','Accelerator','Q');

% modify easyplot toolbar
set(hFig,'Toolbar','figure');
hToolbar = findall(hFig,'tag','FigureToolBar');
%get(findall(hToolbar),'tag')

% change toolbar button 'Standard.FileOpen' callback
hFileOpenButton = findall(hToolbar,'tag','Standard.FileOpen');
set(hFileOpenButton, 'ClickedCallback','import_Callback(gcbf)', 'TooltipString','Import Data File');

% change toolbar button 'Standard.SaveFigure' callback
hSaveButton = findall(hToolbar,'tag','Standard.SaveFigure');
set(hSaveButton, 'ClickedCallback','saveImage_Callback(gcbf)', 'TooltipString','Save Image');

% change toolbar button 'Standard.NewFigure' callback
hNewFigureButton = findall(hToolbar,'tag','Standard.NewFigure');
set(hNewFigureButton, 'ClickedCallback','clearPlot_Callback(gcbf)', 'TooltipString','Clear Plot');

% hide certain default toolbar entries
for txtTag = {'Exploration.Rotate' 'DataManager.Linking' 'Annotation.InsertLegend' 'Annotation.InsertColorbar'}
    hTag = findall(hToolbar, 'tag', char(txtTag));
    if ~isempty(hTag)
        set(hTag, 'Visible', 'Off');
    end
end

% add some custom toolbar buttons
EPpath = mfilename('fullpath');
EPpath=fileparts(EPpath);

[img,map,tran] = imread(fullfile(EPpath,'icons', 'profile.png'));
img = double(img)/255;
img(repmat(tran==0,[1 1 3])) = NaN; % make background transparent
hEPreplotButton = uipushtool(hToolbar,'CData',img, ...
    'TooltipString', 'Change Plot Variable', ...
    'ClickedCallback', 'replot_Callback(gcbf)', ...
    'Separator','on');

iconData=load(fullfile(EPpath,'icons','zoomXextent_CData.mat'));
img = iconData.CData;
img(img ~= 0) = NaN; % make background transparent
hEPzoomXButton = uipushtool(hToolbar,'CData',img,...
    'TooltipString', 'Zoom X Extents', ...
    'ClickedCallback', 'zoomXextent_Callback(gcbf)');

iconData=load(fullfile(EPpath,'icons','zoomYextent_CData.mat'));
img = iconData.CData;
img(img ~= 0) = NaN; % make background transparent
hEPzoomYButton = uipushtool(hToolbar,'CData',img,...
    'TooltipString', 'Zoom Y Extents', ...
    'ClickedCallback', 'zoomYextent_Callback(gcbf)');

[img,map,tran] = imread(fullfile(EPpath,'icons', 'crop_tool.png')); % Read an image
img = double(img)/255;
img(repmat(tran==0,[1 1 3])) = NaN; % make background transparent
hEPmanualAxisLimitsButton = uipushtool(hToolbar,'CData',img, ...
    'TooltipString', 'Manual Axis Limits', ...
    'ClickedCallback', 'manualAxisLimits_Callback(gcbf)');

%
% message panel
msgPanel = uipanel(...
    'Parent',     hFig,...
    'BorderType', 'line', ...
    'Tag',        'msgPanel');

% file list display
filelistPanel = uipanel(...
    'Parent',     hFig,...
    'BorderType', 'line',...
    'Tag',        'filelistPanel');

% tree display
treePanel = uipanel(...
    'Parent',     hFig,...
    'BorderType', 'none',...
    'Tag',        'treePanel');

% plot display
plotPanel = uipanel(...
    'Parent',     hFig,...
    'BorderType', 'none',...
    'Tag',        'plotPanel');

msgPanelText = uicontrol(msgPanel, 'Style', 'text', 'String', 'Import some files.', 'Tag', 'msgPanelText');

filelistPanelListbox = uicontrol(filelistPanel, 'Style', 'listbox', ...
    'String', 'No files loaded.', ...
    'Callback', @filelist_Callback, ...
    'Tag', 'filelistPanelListbox');

% use normalized units
set(hFig,           'Units', 'normalized');
set(msgPanel,       'Units', 'normalized');
set(msgPanelText,       'Units', 'normalized');
set(filelistPanel,  'Units', 'normalized');
set(filelistPanelListbox,  'Units', 'normalized');
set(treePanel,      'Units', 'normalized');
set(plotPanel,      'Units', 'normalized');

% set window position
set(hFig, 'Position', [0.1,  0.15, 0.8,  0.7]);

% restrict window to primary screen
set(hFig, 'Units', 'pixels');
pos       = get(hFig,  'OuterPosition');
monitors  = get(0,    'MonitorPositions');
if pos(3) > monitors(1,3)
    pos(1) = 1;
    pos(3) = monitors(1,3);
    set(hFig, 'OuterPosition', pos);
end
set(hFig, 'Units', 'normalized');

% set widget positions
set(msgPanel,       'Position', posUi2(hFig, 100, 100,   1:5,  1:25,  0));
set(filelistPanel,  'Position', posUi2(hFig, 100, 100,  6:45,  1:25,  0));
set(treePanel,      'Position', posUi2(hFig, 100, 100, 45:100,  1:25, 0.01));
set(plotPanel,      'Position', posUi2(hFig, 100, 100, 1:100, 26:100,  0));

set(msgPanelText,       'Position', posUi2(msgPanel, 100, 100,   1:100,  1:100,  0.01));
set(filelistPanelListbox,       'Position', posUi2(filelistPanel, 100, 100,   1:100,  1:100,  0.01));

%msgPanel.BackgroundColor = [1 0 0];
%filelistPanel.BackgroundColor = [0 0 1];
plotPanel.BackgroundColor = [1 1 1];

% if ispc && isequal(get(filelistPanel,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(filelistPanel,'BackgroundColor','white');
% end

% data min/max
userData.plotLimits.TIME.xMin=NaN;
userData.plotLimits.TIME.xMax=NaN;
userData.plotLimits.MULTI.yMin=NaN;
userData.plotLimits.MULTI.yMax=NaN;

% default single plot with any selected variables
userData.EP_plotType = 'VARS_OVERLAY';
userData.EP_plotYearly = false;

% if plot IMOS netcdf files, plot using raw/good qc flags
userData.EP_plotQC = false;

% old path for easier importing
[userData.EP_easyplotDir, name, ext] = fileparts(mfilename('fullpath'));
userData.EP_previousDataDir=userData.EP_easyplotDir;
userData.ini = ini2struct(fullfile(userData.EP_easyplotDir,'easyplot.ini'));
try
    thePath=userData.ini.startDialog.dataDir;
    if exist(thePath)
        userData.EP_previousDataDir=thePath;
    end
end
if ~isfield(userData.ini.plotting,'doMultilineXLabel')
    userData.ini.plotting.doMultilineXLabel = false;
end

% get parser list
userData.parserList=initParserList;

userData.EP_firstPlot = true;

userData.EP_defaultLatitude = -19;

userData.plotVarNames = {};
axesInfo.mdformat = 'dd-mmm';
axesInfo.Type = 'dateaxes';
axesInfo.XLabel = 'Time (UTC)';
axesInfo.doMultilineXLabel = userData.ini.plotting.doMultilineXLabel;

userData.axesInfo=axesInfo;

% Wanted slightly different date string layout so pulled apart code from
% http://au.mathworks.com/matlabcentral/fileexchange/27075-intelligent-dynamic-date-ticks
% Tried a callback on zoom/pan and XLim listener but that just cause
% massive confusion. At the moment just call updateDateLabel as required,
% if I look into this again think I will create seperate callbacks
% for ActionPostCallback and PostSet XLim listener, which would then
% call common updateDateLabel
% z = zoom(hFig);
% p = pan(hFig);
% set(z,'ActionPostCallback',@updateDateLabel);
% set(p,'ActionPostCallback',@updateDateLabel);
%set(hFig, 'WindowKeyPressFcn', @keyPressCallback);

% custome data tip with nicely formatted date
dcm_h = datacursormode(hFig);
set(dcm_h, 'UpdateFcn', @customDatacursorText)

% callback for mouse click on plot
set(hFig,'WindowButtonDownFcn', @mouseDownListener);

setappdata(hFig, 'UserData', userData);

%% --- Executes when user attempts to close figure1.
    function plotType_Callback(hObject, eventdata, handles)
        % hObject    handle to figure1 (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        hFig = ancestor(hObject,'figure');
        userData=getappdata(hFig, 'UserData');
        
        oldPlotType = userData.EP_plotType;
        userData.EP_plotType = hObject.Label;
        
        if strcmp(userData.EP_plotType, oldPlotType)
            set(hObject,'Checked','on');
        else
            set(hObject,'Checked','on');
            iCheckOff = arrayfun(@(x) strcmp(x.Label, oldPlotType), hObject.Parent.Children);
            set(hObject.Parent.Children(iCheckOff),'Checked','off');
        end
        
        setappdata(hFig, 'UserData', userData);
        plotData(hFig);
        
    end

%% --- Executes when user attempts to close figure1.
    function plotYearly_Callback(hObject, eventdata, handles)
        % hObject    handle to figure1 (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        hFig = ancestor(hObject,'figure');
        userData=getappdata(hFig, 'UserData');
        
        if strcmp(get(hObject,'Checked'),'on')
            set(hObject,'Checked','off');
            userData.EP_plotYearly = false;
        else
            set(hObject,'Checked','on');
            userData.EP_plotYearly = true;
        end
        userData.redoPlots = true;
        setappdata(hFig, 'UserData', userData);
        if isfield(userData, 'sample_data')
            plotData(hFig);
        end
        
    end

%% --- Executes on button press in exit.
    function exit_Callback(hObject, eventdata, handles)
        %EXIT_CALLBACK Easyplot exit
        %
        % hObject    handle to exit (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        hFig = ancestor(hObject,'figure');
        userData=getappdata(hFig, 'UserData');
        try
            % save path
            userData.ini.startDialog.dataDir=userData.EP_previousDataDir;
            % need to convert logical to string for struct2ini
            if userData.ini.plotting.doMultilineXLabel
                userData.ini.plotting.doMultilineXLabel = 'true';
            else
                userData.ini.plotting.doMultilineXLabel = 'false';
            end
            % inelegant code to handle if user double clicked on a '_ep.fig' and stored
            % EPdir is different to current.
            [tmpEPdir, ~, ~] = fileparts(which('easyplot'));
            userData.EP_easyplotDir = tmpEPdir;
            struct2ini(fullfile(userData.EP_easyplotDir,'easyplot.ini'),userData.ini);
        catch
            warning('Error writing to easyplot.ini');
        end
        delete(hFig);
        
    end

%%
    function loadFilelist_Callback(hObject, eventdata, handles)
        hFig = ancestor(hObject,'figure');
        userData=getappdata(hFig, 'UserData');
        
        msgPanel = findobj(hFig, 'Tag','msgPanel');
        msgPanelText = findobj(msgPanel, 'Tag','msgPanelText');

        if ~isfield(userData,'sample_data')
            userData.sample_data={};
        end
        
        for kk=1:numel(userData.sample_data)
            userData.sample_data{kk}.isNew = false;
        end
        
        [ymlFileName, ymlPathName, ~] = uigetfile('*.yml','');
        ymlData = yml.read(fullfile(ymlPathName,ymlFileName));
        % test if no file selected
        if ~isfield(ymlData, 'files')
            return;
        end
        nFiles = numel(ymlData.files);
        % a bit more paranoia
        if nFiles == 0
            return;
        end 
        nFiles = numel(ymlData.files);
        for ii = 1:nFiles
            theParser = ymlData.files{ii}.parser;
            theFullFile = ymlData.files{ii}.filename;
            [pathStr, fileStr, extStr] = fileparts(theFullFile);
            theFile = [fileStr extStr];
            
            notLoaded = ~any(cell2mat((cellfun(@(x) ~isempty(strfind(x.easyplot_input_file, theFullFile)), userData.sample_data, 'UniformOutput', false))));
            
            if notLoaded
                set(msgPanelText,'String',strcat({'Loading : '}, theFile));
                drawnow;
                disp(['importing file ', num2str(ii), ' of ', num2str(nFiles), ' : ', theFile]);
                parser = str2func(theParser);
                structs = parser( {theFullFile}, 'timeSeries' );
                isNew = false(size(userData.sample_data));
                if numel(structs) == 1
                    % only one struct generated for one raw data file
                    structs.meta.parser = theParser;
                    if isfield(ymlData.files{ii}, 'latitude') && ~isempty(ymlData.files{ii}.latitude)
                        structs.meta.latitude = ymlData.files{ii}.latitude;
                    end
                    tmpStruct = finaliseDataEasyplot(structs, theFullFile);
                    userData.sample_data{end+1} = tmpStruct;
                    clear('tmpStruct');
                    userData.sample_data{end}.isNew = true;
                    isNew(end+1) = true;
                else
                    % one data set may have generated more than one sample_data struct
                    % eg AWAC .wpr with waves in .wap etc
                    for k = 1:length(structs)
                        structs{k}.meta.parser = theParser;
                        if isfield(ymlData.files{ii}, 'latitude') & ~isempty(ymlData.files{ii}.latitude)
                            structs{k}.meta.latitude = ymlData.files{ii}.latitude;
                        end
                        tmpStruct = finaliseDataEasyplot(structs{k}, theFullFile);
                        userData.sample_data{end+1} = tmpStruct;
                        clear('tmpStruct');
                        userData.sample_data{end}.isNew = true;
                        isNew(end+1) = true;
                    end
                end
                if isfield(ymlData.files{ii}, 'variables') & ~isempty(ymlData.files{ii}.variables)
                    plotVar = strtrim(strsplit(ymlData.files{ii}.variables, ','));
                    userData.sample_data = markPlotVar(userData.sample_data, plotVar, isNew);
                end
            end
        end
        
        % data limits for those variables
        varNames = {};
        % variables already plotted
        for ii=1:numel(userData.sample_data)
            iPlotVars = find(userData.sample_data{ii}.variablePlotStatus > 0)';
            if ~isempty(iPlotVars)
                for jj = iPlotVars
                    theVar = userData.sample_data{ii}.variables{jj}.name;
                    varNames{end+1}=theVar;
                end
            end
        end
        varNames=sort(unique(varNames));
        userData.plotVarNames = varNames;
        userData.dataLimits = findVarExtents(userData.sample_data, varNames);

        set(filelistPanelListbox,'String', getFilelistNames(userData.sample_data),'Value',1);
        userData.treePanelData = generateTreeData(userData.sample_data);
        userData.jtable = createTreeTable(treePanel, userData);
        setappdata(hFig, 'UserData', userData);
        plotData(hFig);
    end

%%
    function saveFilelist_Callback(hObject, eventdata, handles)
        hFig = ancestor(hObject,'figure');
        if isempty(hFig)
            return;
        end
        
        userData=getappdata(hFig, 'UserData');
        if isempty(userData.sample_data)
            return;
        end

        ymlData = struct;
        for ii=1:numel(userData.sample_data)
            tmpStruct = struct;
            tmpStruct.filename = userData.sample_data{ii}.toolbox_input_file;
            tmpStruct.parser = userData.sample_data{ii}.meta.parser;
            plotVars = cellfun(@(x) x.name, userData.sample_data{ii}.variables, 'UniformOutput', false);
            plotVars = plotVars(logical(userData.sample_data{ii}.variablePlotStatus));
            plotVars = strjoin(plotVars, ', ');
            tmpStruct.variables = plotVars;
            if isfield(userData.sample_data{ii}.meta, 'latitude') && ~isempty(userData.sample_data{ii}.meta.latitude)
                tmpStruct.latitude = userData.sample_data{ii}.meta.latitude;
            end
            ymlData.files{ii} = tmpStruct;
        end
        
        %ymlData.plottype = userData.EP_plotType;
        
        [ymlFileName, ymlPathName, FilterIndex] = uiputfile('*.yml','Save file list as');
        yml.write(fullfile(ymlPathName,ymlFileName),ymlData);
    end
%%
    function timeOffsets_Callback(hObject, eventdata, handles)
        hFig = ancestor(hObject,'figure');
        userData=getappdata(hFig, 'UserData');
        
        msgPanel = findobj(hFig, 'Tag','msgPanel');
        msgPanelText = findobj(msgPanel, 'Tag','msgPanelText');

        if ~isfield(userData,'sample_data')
            return;
        end
        
        userData.sample_data = timeOffsetPP(userData.sample_data, 'raw', false);
        userData.redoPlots = true;
        setappdata(hFig, 'UserData', userData);
        plotData(hFig);
    end
end

%%

