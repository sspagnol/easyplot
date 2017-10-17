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

if isfield(userData, 'sample_data')
    userData.treePanelData = generateTreeData(userData.sample_data);
    userData.jtable = createTreeTable(treePanel, userData);
    setappdata(hFig, 'UserData', userData);
    plotData(hFig);
    zoomYextent_Callback(hObject);
end

end