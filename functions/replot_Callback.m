%% --- Executes on button press in replot.
function replot_Callback(hObject, eventdata, oldHandles)
%replot_Callback choose a variable to plot
%
% hObject    handle to replot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
theParent = ancestor(hObject,'figure');
userData=getappdata(theParent, 'UserData');
gData = guidata(theParent);

if isfield(userData, 'sample_data')
    
    plotVar = chooseVar(userData.sample_data);
    userData.sample_data = markPlotVar(userData.sample_data, plotVar);
    userData.treePanelData = generateTreeData(userData.sample_data);
    %setappdata(theParent, 'UserData', userData);
    
    %     %model = handles.jtable.getModel.getActualModel;
    %     model = getOriginalModel(handles.jtable);
    %     model.groupAndRefresh;
    %     handles.jtable.repaint;
    
    % surely I don't have to delete and recreate jtable
    %     if isfield(handles,'jtable')
    %         %delete(handles.jtable);
    %         handles.jtable.getModel.getActualModel.getActualModel.setRowCount(0);
    %     end
    userData.jtable = createTreeTable(gData,userData);
    
    setappdata(theParent, 'UserData', userData);
    plotData(theParent);
    zoomYextent_Callback(hObject);
end

end


