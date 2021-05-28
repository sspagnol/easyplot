% --- Executes on button press in BathCals.
function BathCals_Callback(hObject, eventdata, handles)
% hObject    handle to BathCals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%have to first make sure that temperature is plotted:
hFig = ancestor(hObject,'figure');
userData=getappdata(hFig, 'UserData');

plotPanel = findobj(hFig, 'Tag','plotPanel');
treePanel = findobj(hFig, 'Tag','treePanel');

if isfield(userData, 'sample_data')
    plotVar = {'TEMP'};
    
    varList = {'TEMP', 'CNDC'};

    title = 'Variable to plot?';
    prompt = 'Variable List';
    defaultanswer = 1;
    plotVar = optionDialog( title, prompt, varList, defaultanswer );

    pause(0.1);
    if isempty(plotVar), return; end
    
    userData.sample_data = markPlotVar(userData.sample_data, plotVar, true(size(userData.sample_data)));
    userData.treePanelData = generateTreeData(userData.sample_data);
    %userData.jtable = createTreeTable(treePanel);
    updateTreeDisplay(treePanel, userData.treePanelData);
    userData.plotVarNames = {plotVar};
    setappdata(hFig, 'UserData', userData);
    plotData(hFig);
    %zoomYextent_Callback(hObject);
    %zoomXextent_Callback(hObject);
else
    return;
end

% Create the UICONTEXTMENU
uic = uicontextmenu(hFig);
% Create the parent menu
bathcalmenu = uimenu(uic,'label',[plotVar ' Bath Calibrations']);
% Create the submenus
m1 = uimenu(bathcalmenu,'label','Select Points',...
    'Callback',@selectPoints_Callback);

children = findobj(plotPanel,'Type','axes');
for ii=1:numel(children)
    set(children(ii), 'UIContextMenu', uic);
end

%uic.HandleVisibility = 'off';
%theParent.uic.HandleVisibility = 'on';

h = helpdlg(['Select the region to use for bath calibrations by ' ...
    'zooming in and then use the UIContextMenu ''Select Points''.', ...
    'Calibration selection']);
uiwait(h);
%zoom('on');

end
