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
m=uimenu(hFig,'Label','Easyplot');
sm1=uimenu(m,'Label','Plot Vars As...');
uimenu(sm1,'Label','VARS_OVERLAY','Checked','on','Callback',@plotType_Callback);
uimenu(sm1,'Label','VARS_STACKED','Callback',@plotType_Callback);
uimenu(m,'Label','Use QC flags','Callback',@useQCflags_Callback);
uimenu(m,'Label','Do Bath Calibrations','Callback',@BathCals_Callback);
uimenu(m,'Label','Save Image','Callback',@saveImage_Callback);
uimenu(m,'Label','Quit','Callback',@exit_Callback,...
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
userData.plotType = 'VARS_OVERLAY';

% if plot IMOS netcdf files, plot using raw/good qc flags
userData.plotQC = false;

% old path for easier importing
[userData.EPdir, name, ext] = fileparts(mfilename('fullpath'));
userData.oldPathname=userData.EPdir;
userData.ini = ini2struct(fullfile(userData.EPdir,'easyplot.ini'));
try
    thePath=userData.ini.startDialog.dataDir;
    if exist(thePath)
        userData.oldPathname=thePath;
    end
end
if ~isfield(userData.ini.plotting,'doMultilineXLabel')
    userData.ini.plotting.doMultilineXLabel = false;
end

% get parser list
userData.parserList=initParserList;

userData.firstPlot = true;

userData.plotVarNames = {};
axesInfo.mdformat = 'dd-mmm';
axesInfo.Type = 'dateaxes';
axesInfo.XLabel = 'Time (UTC)';
axesInfo.doMultilineXLabel = userData.ini.plotting.doMultilineXLabel;

userData.axesInfo=axesInfo;
%set(axH,'ButtonDownFcn',@updateAxisManual)

% Wanted slightly different date string layout so pulled apart code from
% http://au.mathworks.com/matlabcentral/fileexchange/27075-intelligent-dynamic-date-ticks
% Tried a callback on zoom/pan and XLim listener but that just cause
% massive confusion. At the moment just call updateDateLabel as required,
% if I look into this again think I will create seperate callbacks
% for ActionPostCallback and PostSet XLim listener, which would then
% call common updateDateLabel
z = zoom(hFig);
p = pan(hFig);
set(z,'ActionPostCallback',@updateDateLabel);
set(p,'ActionPostCallback',@updateDateLabel);
set(hFig, 'WindowKeyPressFcn', @keyPressCallback);

% custome data tip with nicely formatted date
dcm_h = datacursormode(hFig);
set(dcm_h, 'UpdateFcn', @customDatacursorText)

% callback for mouse click on plot
set(hFig,'WindowButtonDownFcn', @mouseDownListener);

% Dummy treeTable data
userData.treePanelData{1,1}='None';
userData.treePanelData{1,2}='None';
userData.treePanelData{1,3}='None';
userData.treePanelData{1,4}=false;
userData.treePanelData{1,5}=0;
userData.treePanelHeader = {'','Instrument','Variable','Show','Slice'};
userData.treePanelColumnTypes = {'','char','char','logical','integer'};
userData.treePanelColumnEditable = {false, false, true, true};
userData.jtable = createTreeTable(treePanel, userData);

setappdata(hFig, 'UserData', userData);

%% --- Executes when user attempts to close figure1.
    function plotType_Callback(hObject, eventdata, handles)
        % hObject    handle to figure1 (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        hFig = ancestor(hObject,'figure');
        userData=getappdata(hFig, 'UserData');
        
        oldPlotType = userData.plotType;
        userData.plotType = hObject.Label;
        
        if strcmp(userData.plotType, oldPlotType)
            set(hObject,'Checked','on');
        else
            set(hObject,'Checked','on');
            iCheckOff = arrayfun(@(x) strcmp(x.Label, oldPlotType), hObject.Parent.Children);
            set(hObject.Parent.Children(iCheckOff),'Checked','off');
        end
        
        setappdata(hFig, 'UserData', userData);
        plotData(hFig);
        
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
            userData.ini.startDialog.dataDir=userData.oldPathname;
            % need to convert logical to string for struct2ini
            if userData.ini.plotting.doMultilineXLabel
                userData.ini.plotting.doMultilineXLabel = 'true';
            else
                userData.ini.plotting.doMultilineXLabel = 'false';
            end
            % inelegant code to handle if user double clicked on a '_ep.fig' and stored
            % EPdir is different to current.
            [tmpEPdir, ~, ~] = fileparts(which('easyplot'));
            userData.EPdir = tmpEPdir;
            struct2ini(fullfile(userData.EPdir,'easyplot.ini'),userData.ini);
        catch
            warning('Error writing to easyplot.ini');
        end
        delete(hFig);
        
    end

end