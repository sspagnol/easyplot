%% --- Executes on button press in replot.
function replot_Callback(hObject, eventdata, oldHandles)
%replot_Callback choose a variable to plot
%
% hObject    handle to replot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hFig = ancestor(hObject,'figure');
userData=getappdata(hFig, 'UserData');
treePanel = findobj(hFig, 'Tag','treePanel');

if isfield(userData, 'sample_data')
    oldPlotVarNames = userData.plotVarNames;
    plotVar = chooseVar(userData.sample_data);
    if ~isempty(plotVar)
        userData.plotVarNames = {plotVar};
        userData.sample_data = markPlotVar(userData.sample_data, plotVar, true(size(userData.sample_data)));
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
        userData.jtable = createTreeTable(treePanel, userData);
        
        setappdata(hFig, 'UserData', userData);
        plotData(hFig);
        zoomYextent_Callback(hObject);
    end
end

end


