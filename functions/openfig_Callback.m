%% --- Executes on openfig.
function openfig_Callback(hObject)
%openfig_Callback callback to remake tree data.
%
% hObject    handle to replot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
theParent = ancestor(hObject,'figure');
userData=getappdata(theParent, 'UserData');
gData = guidata(theParent);

if isfield(userData, 'sample_data')
    userData.treePanelData = generateTreeData(userData.sample_data);
    userData.jtable = createTreeTable(gData,userData);
    setappdata(theParent, 'UserData', userData);
    plotData(theParent);
    zoomYextent_Callback(hObject);
end

end