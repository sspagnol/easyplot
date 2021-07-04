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
        treePanelData = generateTreeData(userData.sample_data);
        updateTreeDisplay(treePanel, treePanelData);

        if ~isfield(userData, 'dataLimits')
            userData.dataLimits = [];
        end
        userData.dataLimits = updateVarExtents(userData.sample_data, userData.dataLimits);
        
        setappdata(hFig, 'UserData', userData);
        plotData(hFig);
        zoomYextent_Callback(hObject);
    end
end

end


