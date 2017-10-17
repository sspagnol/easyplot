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
    userData.sample_data = markPlotVar(userData.sample_data, plotVar, true(size(userData.sample_data)));
    userData.treePanelData = generateTreeData(userData.sample_data);
    userData.jtable = createTreeTable(treePanel, userData);
    userData.plotVarNames = {'TEMP'};
    setappdata(hFig, 'UserData', userData);
    plotData(hFig);
    zoomYextent_Callback(hObject);
    zoomXextent_Callback(hObject);
end

% Create the UICONTEXTMENU
uic = uicontextmenu(hFig);
% Create the parent menu
bathcalmenu = uimenu(uic,'label','Bath Calibrations');
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
