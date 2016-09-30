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

%need to now select the time period/data to do the comparison: need to get
%input from the user using ginput.
%tell the user what to do:
if verLessThan('matlab','8.4')
    set(handles.selectPoints, 'Visible', 'on');
    set(handles.BathCals, 'Visible', 'off');
else
    handles.selectPoints.Visible = 'on';
    handles.BathCals.Visible = 'off';
end

h = helpdlg(['Select the region to use for bath calibrations by ' ...
    'zooming in and then use the ''select points'' button.', ...
    'Calibration selection']);
uiwait(h);
%zoom('on');

end
