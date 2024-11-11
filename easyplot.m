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

% hFig = uifigure(...
%     'Name',        'Easyplot', ...
%     'Visible',     'on',...
%     'Color',       [1 1 1],...
%     'Resize',      'on',...
%     'NumberTitle', 'off',...
%     'Tag',         'mainWindow');

set(hFig,'CloseRequestFcn',@exit_Callback);

userData=getappdata(hFig,'UserData');

% add menu items
m=uimenu(hFig, 'Label', 'Easyplot');
uimenu(m, 'Label', 'Plot Time as Day Number', 'Checked','off', 'Callback', @plotYearly_Callback);

sm1=uimenu(m, 'Label', 'Plot Vars As...');
uimenu(sm1, 'Label', 'VARS_OVERLAY', 'Checked','on','Callback', @plotType_Callback);
uimenu(sm1, 'Label', 'VARS_STACKED', 'Callback', @plotType_Callback);

sm2=uimenu(m, 'Label', 'Plot Line Colours As...');
uimenu(sm2, 'Label', 'LINECOLOUR_PER_INSTRUMENT_PER_DEPLOYMENT', 'Checked','on','Callback', @lineColourType_Callback);
uimenu(sm2, 'Label', 'LINECOLOUR_PER_INSTRUMENT', 'Callback', @lineColourType_Callback);
uimenu(sm2, 'Label', 'LINECOLOUR_PER_INSTRUMENTTYPE', 'Callback', @lineColourType_Callback);
%uimenu(sm2, 'Label', 'LINECOLOUR_PER_DEPLOYMENTID', 'Callback', @lineColourType_Callback);
uimenu(m, 'Label', 'Plot Using QC flags', 'Callback', @useQCflags_Callback);

uimenu(m, 'Label', 'Do Time Offset', 'Callback', @timeOffsets_Callback, 'Separator','on');
uimenu(m, 'Label', 'Do Time Drift', 'Callback', @timeDrift_Callback);
uimenu(m, 'Label', 'Do Variable Offset', 'Callback', @variableOffsets_Callback);
uimenu(m, 'Label', 'Do CTD test tank comparison', 'Callback', @BathCals_Callback);
uimenu(m, 'Label', 'Do CTD cast comparison', 'Callback', @inwater_ctd_comparison_Callback);

uimenu(m, 'Label', 'Load filelist (YML)', 'Callback', @loadFilelist_Callback, 'Separator','on');
uimenu(m, 'Label', 'Save filelist (YML)', 'Callback', @saveFilelist_Callback);
uimenu(m, 'Label', 'Save Image', 'Callback', @saveImage_Callback, 'Separator','on');
uimenu(m, 'Label', 'Quit', 'Callback', @exit_Callback,...
    'Separator','on','Accelerator','Q');

% modify easyplot toolbar
set(hFig,'Toolbar','figure');
hToolbar = findall(hFig,'tag','FigureToolBar');
%get(findall(hToolbar),'tag')

modifyToolbarButtons(hToolbar);

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
set(msgPanel,       'Position', posUi2(hFig, 100, 100,    1:5,  1:25,  0));
set(filelistPanel,  'Position', posUi2(hFig, 100, 100,   6:45,  1:25,  0));
set(treePanel,      'Position', posUi2(hFig, 100, 100,  45:100,  1:25, 0.01));
set(plotPanel,      'Position', posUi2(hFig, 100, 100,   1:100, 26:100,  0));

set(msgPanelText,       'Position', posUi2(msgPanel, 100, 100,   1:100,  1:100,  0.01));
set(filelistPanelListbox,       'Position', posUi2(filelistPanel, 100, 100,   1:100,  1:100,  0.01));

%msgPanel.BackgroundColor = [1 0 0];
%filelistPanel.BackgroundColor = [0 0 1];
plotPanel.BackgroundColor = [1 1 1];

% if ispc && isequal(get(filelistPanel,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(filelistPanel,'BackgroundColor','white');
% end

%
tUserData = getappdata(treePanel, 'UserData');
tUserData.treePanelData = {};
tUserData.treePanelHeader = {'Instrument','File','Serial','Variable','Show','Slice'};
tUserData.treePanelColumnGroupBy = {true, true, true, false, false, false};
tUserData.treePanelColumnTypes = {'', '', '', 'char', 'logical', 'integer'};
tUserData.treePanelColumnEditable = {'', '', '', false, true, true};
setappdata(treePanel, 'UserData', tUserData);
createTreeTable(treePanel);

% data min/max
userData.plotLimits.TIME.xMin=NaN;
userData.plotLimits.TIME.xMax=NaN;
userData.plotLimits.MULTI.yMin=NaN;
userData.plotLimits.MULTI.yMax=NaN;

% default single plot with any selected variables
userData.EP_plotType = 'VARS_OVERLAY';
userData.EP_lineColourType = 'LINECOLOUR_PER_INSTRUMENT_PER_DEPLOYMENT';
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
try
    thePath=userData.ini.startDialog.ymlDir;
    if exist(thePath)
        userData.EP_previousYmlDir=thePath;
    else
        userData.EP_previousYmlDir=userData.EP_easyplotDir;
    end
end
if ~isfield(userData.ini.plotting,'doMultilineXLabel')
    userData.ini.plotting.doMultilineXLabel = false;
end

% get parser list
userData.parserList=initParserList;

userData.EP_redoPlots = true;

userData.EP_defaultLatitude = -19;

userData.plotVarNames = {};
axesInfo.mdformat = 'dd-mmm';
axesInfo.Type = 'dateaxes';
axesInfo.XLabel = 'Time (UTC)';
axesInfo.doMultilineXLabel = userData.ini.plotting.doMultilineXLabel;

userData.axesInfo=axesInfo;

set(hFig, 'WindowKeyPressFcn', @keyPressCallback);

% custome data tip with nicely formatted date
dcm_h = datacursormode(hFig);
set(dcm_h, 'UpdateFcn', @customDatacursorText)

% callback for mouse click on plot
set(hFig,'WindowButtonDownFcn', @mouseDownListener);

userData.msgPanel = msgPanel;
userData.filelistPanel = filelistPanel;
userData.filelistPanelListbox = filelistPanelListbox;
userData.treePanel = treePanel;
userData.plotPanel = plotPanel;

setappdata(hFig, 'UserData', userData);

%% --- Executes when user changes plot type.
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

%% --- Executes when user changes line colour type.
    function lineColourType_Callback(hObject, eventdata, handles)
        % hObject    handle to figure1 (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        hFig = ancestor(hObject,'figure');
        userData=getappdata(hFig, 'UserData');
        
        oldLineColourType = userData.EP_lineColourType;
        userData.EP_lineColourType = hObject.Label;
        
        if strcmp(userData.EP_lineColourType, oldLineColourType)
            set(hObject,'Checked','on');
        else
            set(hObject,'Checked','on');
            iCheckOff = arrayfun(@(x) strcmp(x.Label, oldLineColourType), hObject.Parent.Children);
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
        userData.EP_redoPlots = true;
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
        %treePanel = userData.treePanel;
        treePanel = findobj(hFig, 'Tag','treePanel');
        if ~isempty(treePanel)
            tUserData = getappdata(treePanel, 'UserData');
            if ~isempty(tUserData)
                delete(tUserData.jtable);
            end
        end
        
        try
            % save path
            userData.ini.startDialog.dataDir=userData.EP_previousDataDir;
            % need to convert logical to string for struct2ini
            if userData.ini.plotting.doMultilineXLabel
                userData.ini.plotting.doMultilineXLabel = 'true';
            else
                userData.ini.plotting.doMultilineXLabel = 'false';
            end
            userData.ini.startDialog.ymlDir = userData.EP_previousYmlDir;
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
        
        [ymlFileName, ymlPathName, ~] = uigetfile(fullfile(userData.EP_previousYmlDir, '*.yml'),'');
        if isempty(ymlFileName)
            return;
        end
        if ymlFileName == 0.0
            return;
        end
        
        ymlData = yml.read(fullfile(ymlPathName,ymlFileName));
        % test if no file selected
        if ~isfield(ymlData, 'files')
            return;
        end
        
        if isfield(ymlData, 'plottype')
            oldPlotType = userData.EP_plotType;
            EP_plotType = upper(ymlData.plottype);
            userData.EP_plotType = EP_plotType;
            menuObject = findobj(hFig.Children, 'Text', EP_plotType);
            if strcmp(userData.EP_plotType, oldPlotType)
                set(menuObject,'Checked', 'on');
            else
                set(menuObject, 'Checked', 'on');
                iCheckOff = arrayfun(@(x) strcmp(x.Label, oldPlotType), menuObject.Parent.Children);
                set(menuObject.Parent.Children(iCheckOff), 'Checked', 'off');
            end
        end
        
        for kk=1:numel(userData.sample_data)
            userData.sample_data{kk}.EP_isNew = false;
        end
        
        nFiles = numel(ymlData.files);
        % a bit more paranoia
        if nFiles == 0
            return;
        end 
        nFiles = numel(ymlData.files);
        defaultLatitude = userData.EP_defaultLatitude;
        for ii = 1:nFiles
            parser_name = ymlData.files{ii}.parser;
            % older file with only absolute path filename
            toolbox_input_file = ymlData.files{ii}.filename;

            % newer file with relative and absolute path filename
            if isfield(ymlData.files{ii}, 'relpath_filename')
                toolbox_input_file = fullfile(ymlPathName, ymlData.files{ii}.relpath_filename);
                if ispc
                    toolbox_input_file = strrep(toolbox_input_file, '/', filesep);
                else
                    toolbox_input_file = strrep(toolbox_input_file, '\', filesep);
                end
                toolbox_input_file = strrep(toolbox_input_file, [filesep '.' filesep], filesep);

                if ~exist(toolbox_input_file, 'file')
                    toolbox_input_file = ymlData.files{ii}.abspath_filename;
                end
                
                % handle case if name in the db is the wrong case, windows
                % will allow it but causes confusion on linux
                [f_path, f_name, f_ext] = fileparts(toolbox_input_file);
                files_in_dir = dir(f_path);
                for jj = 1:numel(files_in_dir)
                   if strcmpi([f_name f_ext], files_in_dir(jj).name)
                       toolbox_input_file = fullfile(f_path, files_in_dir(jj).name);
                       break;
                   end
                end
            else
                [f_path, f_name, f_ext] = fileparts(toolbox_input_file);
                files_in_dir = dir([ymlPathName '**']);
                for jj = 1:numel(files_in_dir)
                   if ~files_in_dir(jj).isdir && strcmpi([f_name f_ext], files_in_dir(jj).name)
                       toolbox_input_file = fullfile(f_path, files_in_dir(jj).name);
                       break;
                   end
                end  
            end
            
            [pathStr, fileStr, extStr] = fileparts(toolbox_input_file);
            toolbox_input_file_short = [fileStr extStr];
            
            plotVar = '';
            if isfield(ymlData.files{ii}, 'variables') & ~isempty(ymlData.files{ii}.variables)
                plotVar = strtrim(strsplit(ymlData.files{ii}.variables, ','));
                % var rename handle, all LPF variable are new just
                % LPF_theVariableName
                if strcmp(plotVar, 'EP_LPF_PRES_REL')
                    plotVar = 'LPF_PRES_REL';
                end
            end
            
            notLoaded = ~any(cell2mat((cellfun(@(x) ~isempty(strfind(x.toolbox_input_file, toolbox_input_file)), userData.sample_data, 'UniformOutput', false))));
            
            parser = str2func(parser_name);
            
            if notLoaded
                set(msgPanelText,'String',strcat({'Loading : '}, toolbox_input_file_short));
                %drawnow;
                disp(['importing file ', num2str(ii), ' of ', num2str(nFiles), ' : ', toolbox_input_file_short]);

                try
                    structs = parser( {toolbox_input_file}, 'timeSeries' );
                catch
                    warning(['Unable to load file : ' toolbox_input_file]);
                    continue;
                end
                
                % some parsers return struct some a cell or cell array
                if isstruct(structs)
                    structs = num2cell(structs);
                end
                
                % add in offset/scale 
                structs = add_EPOffset_EPScale(structs);

                % add latitude etc info from yml file
                [structs, latitude] = add_yml_info(structs, parser_name, ymlData.files{ii});
                
                [userData.sample_data, defaultLatitude] = add_structs_to_sample_data(userData.sample_data, structs, parser_name, defaultLatitude, toolbox_input_file, plotVar);
                
                clear('structs');
            end
        end
        
        % enumerate labels of instruments by number of times deployed
        userData.sample_data = updateDeploymentNumber(userData.sample_data);
        
        % data limits for those variables
        varNames = {};
        % variables already plotted
        for ii=1:numel(userData.sample_data)
            iPlotVars = find(userData.sample_data{ii}.EP_variablePlotStatus > 0)';
            if ~isempty(iPlotVars)
                for jj = iPlotVars
                    theVar = userData.sample_data{ii}.variables{jj}.name;
                    varNames{end+1}=theVar;
                end
            end
        end
        varNames=sort(unique(varNames));
        userData.plotVarNames = varNames;
        %userData.dataLimits = findVarExtents(userData.sample_data, varNames);
        if ~isfield(userData, 'dataLimits')
            userData.dataLimits = [];
        end
        userData.dataLimits = updateVarExtents(userData.sample_data, userData.dataLimits);
        
        set(filelistPanelListbox,'String', getFilelistNames(userData.sample_data),'Value',1);
        treePanelData = generateTreeData(userData.sample_data);
        updateTreeDisplay(treePanel, treePanelData);

        setappdata(hFig, 'UserData', userData);
        plotData(hFig);
        
        function [structs, latitude] = add_yml_info(structs, parser_name, yml_data_info)
            
            hasLatitude = isfield(yml_data_info, 'latitude') && ~isempty(yml_data_info.latitude);
            latitude = NaN;
            if hasLatitude   
                latitude = yml_data_info.latitude;
                if ~isfloat(latitude)
                    latitude = str2num(latitude);
                end
            end
            
            if isfield(yml_data_info, 'variables') && ~isempty(yml_data_info.variables)
                plotVar = strtrim(strsplit(yml_data_info.variables, ','));
                % var rename handle, all LPF variable are new just
                % LPF_theVariableName
                if strcmp(plotVar, 'EP_LPF_PRES_REL')
                    plotVar = 'LPF_PRES_REL';
                end
            end
            
            for k = 1:length(structs)
                structs{k}.meta.parser = parser_name;
                structs{k}.EP_isNew = true;
                
                if hasLatitude   
                    structs{k}.meta.latitude = latitude;
                end
                
                %EP_isNew=cellfun(@(x) x.EP_isNew, structs{k});
                %tructs{k} = markPlotVar(structs{k}, plotVar, EP_isNew);
                
                if isfield(yml_data_info, 'offsets') && ~isempty(yml_data_info.offsets)
                    offsets = yml_data_info.offsets;
                    for ll = 1:numel(fieldnames(offsets))
                        theVar = offsets{ll};
                        if strcmp(theVar, 'TIME')
                            varId = getVar(structs{k}.dimensions, theVar);
                            structs{k}.dimensions(varId).EP_OFFSET = offsets.(theVar)/24;
                            structs{k}.dimensions(varId).EP_SCALE = 1.0;
                        else
                            varId = getVar(structs{k}.variables, theVar);
                            theOffset = offsets.(theVar);
                            structs{k}.variables(varId).EP_OFFSET = theOffset(1);
                            structs{k}.variables(varId).EP_SCALE = theOffset(2);
                        end
                    end
                end
            end
        end
    end

%%
    function saveFilelist_Callback(hObject, eventdata, handles)
        hFig = ancestor(hObject,'figure');
        if isempty(hFig)
            return;
        end
        
        userData=getappdata(hFig, 'UserData');
        if ~isfield(userData, 'sample_data')
            return;
        end
        if isempty(userData.sample_data)
            return;
        end

        [ymlFileName, ymlPathName, FilterIndex] = uiputfile('*.yml','Save file list as');
        
        ymlData = struct;
        ymlData.plottype = userData.EP_plotType;
        for ii=1:numel(userData.sample_data)
            tmpStruct = struct;
            % older style only absolute path filename
            abspath_filename = userData.sample_data{ii}.toolbox_input_file;
            abspath_filename = strrep(abspath_filename, [filesep '.' filesep], filesep);
            tmpStruct.filename = abspath_filename;
            % also add relative (to yml directory) path 
            tmpStruct.relpath_filename = relativepath_alt( abspath_filename, ymlPathName );
            tmpStruct.abspath_filename = abspath_filename;
            
            tmpStruct.parser = userData.sample_data{ii}.meta.parser;
            plotVars = cellfun(@(x) x.name, userData.sample_data{ii}.variables, 'UniformOutput', false);
            plotVars = plotVars(logical(userData.sample_data{ii}.EP_variablePlotStatus));
            plotVars = strjoin(plotVars, ', ');
            tmpStruct.variables = plotVars;
            if isfield(userData.sample_data{ii}.meta, 'latitude') && ~isempty(userData.sample_data{ii}.meta.latitude)
                tmpStruct.latitude = userData.sample_data{ii}.meta.latitude;
            end
            ymlData.files{ii} = tmpStruct;
        end
 
        yml.write(fullfile(ymlPathName,ymlFileName),ymlData);
        userData.EP_previousYmlDir = ymlPathName;
        setappdata(hFig, 'UserData', userData);
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
        
        userData.sample_data = timeOffsetPP_local(userData.sample_data, 'raw', false);

        if ~isfield(userData, 'dataLimits')
            userData.dataLimits = [];
        end
        userData.dataLimits = updateVarExtents(userData.sample_data, userData.dataLimits);

        userData.EP_redoPlots = true;
        setappdata(hFig, 'UserData', userData);
        plotData(hFig);
    end

%%
    function timeDrift_Callback(hObject, eventdata, handles)
        hFig = ancestor(hObject,'figure');
        userData=getappdata(hFig, 'UserData');
        
        msgPanel = findobj(hFig, 'Tag','msgPanel');
        msgPanelText = findobj(msgPanel, 'Tag','msgPanelText');

        if ~isfield(userData,'sample_data')
            return;
        end
        
        userData.sample_data = timeDriftPP_local(userData.sample_data, 'raw', false);

        if ~isfield(userData, 'dataLimits')
            userData.dataLimits = [];
        end
        userData.dataLimits = updateVarExtents(userData.sample_data, userData.dataLimits);

        userData.EP_redoPlots = true;
        setappdata(hFig, 'UserData', userData);
        plotData(hFig);
    end

%%
    function variableOffsets_Callback(hObject, eventdata, handles)
        hFig = ancestor(hObject,'figure');
        userData=getappdata(hFig, 'UserData');
        
        msgPanel = findobj(hFig, 'Tag','msgPanel');
        msgPanelText = findobj(msgPanel, 'Tag','msgPanelText');

        if ~isfield(userData,'sample_data')
            return;
        end
        
        userData.sample_data = variableOffsetPP_local(userData.sample_data, 'raw', false);
        for ii = 1:length(userData.sample_data)
            userData.sample_data{ii} = updateDataEasyplot(userData.sample_data{ii});
        end
        
        if ~isfield(userData, 'dataLimits')
            userData.dataLimits = [];
        end
        userData.dataLimits = updateVarExtents(userData.sample_data, userData.dataLimits);
        
        userData.EP_redoPlots = true;
        setappdata(hFig, 'UserData', userData);
        plotData(hFig);
    end
end

%%

