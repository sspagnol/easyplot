% --- Executes on button press in BathCals.
function BathCals_Callback(hObject, eventdata, handles)
% hObject    handle to BathCals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%have to first make sure that temperature is plotted:
theParent = ancestor(hObject,'figure');
userData=getappdata(theParent, 'UserData');
gData = guidata(theParent);

if isfield(userData, 'sample_data')
    plotVar = 'TEMP';
    userData.sample_data = markPlotVar(userData.sample_data, plotVar);
    userData.treePanelData = generateTreeData(userData.sample_data);
    userData.jtable = createTreeTable(gData,userData);
    
    setappdata(theParent, 'UserData', userData);
    plotData(theParent);
    zoomYextent_Callback(hObject);
    zoomXextent_Callback(hObject);
end

% Create the UICONTEXTMENU
uic = uicontextmenu(theParent);
% Create the parent menu
bathcalmenu = uimenu(uic,'label','Bath Calibrations');
% Create the submenus
m1 = uimenu(bathcalmenu,'label','Select Points',...
               'Callback',@selectPoints_Callback);
set(gData.axes1, 'UIContextMenu', uic);
%uic.HandleVisibility = 'off';
%theParent.uic.HandleVisibility = 'on';

h = helpdlg(['Select the region to use for bath calibrations by ' ...
    'zooming in and then use the UIContextMenu ''Select Points''.', ...
    'Calibration selection']);
uiwait(h);
%zoom('on');

end
