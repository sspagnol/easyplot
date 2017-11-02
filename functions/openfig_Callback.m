%% --- Executes on openfig.
function openfig_Callback(hObject)
%openfig_Callback callback to remake tree data.
%
% hObject    handle to replot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hFig = ancestor(hObject,'figure');
userData=getappdata(hFig, 'UserData');
treePanel = findobj(hFig, 'Tag','treePanel');

% modify easyplot toolbar
set(hFig,'Toolbar','figure');
hToolbar = findall(hFig,'tag','FigureToolBar');

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

% add some custom toolbar buttons, need previous used EPpath to find icons
EPpath = userData.EPdir;

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

if isfield(userData, 'sample_data')
    userData.treePanelData = generateTreeData(userData.sample_data);
    userData.jtable = createTreeTable(treePanel, userData);
    setappdata(hFig, 'UserData', userData);
    plotData(hFig);
    zoomYextent_Callback(hObject);
end

end