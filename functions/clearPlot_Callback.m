%% --- Executes on button press in clearPlot.
function clearPlot_Callback(hObject, eventdata, oldHandles)
%CLEARPLOT_CALLBACK Clear easyplot plot window
%
% hObject    handle to clearPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
theParent = ancestor(hObject,'figure');
userData=getappdata(theParent, 'UserData');
gData = guidata(theParent);

% clear plot
if isfield(userData, 'sample_data')
    % clear plots
    children = get(gData.plotPanel, 'Children');
    delete(children);
    
    set(gData.listbox1,'String', '');
    
    % reset jtable
    % how do I reset contents of handles.jtable?
    %     if isfield(handles,'jtable')
    %         %delete(handles.jtable);
    %         handles.jtable.getModel.getActualModel.getActualModel.setRowCount(0);
    %     end
    userData.treePanelData = {};
    userData.treePanelData{1,1}='None';
    userData.treePanelData{1,2}='None';
    userData.treePanelData{1,3}='None';
    userData.treePanelData{1,4}=false;
    userData.treePanelData{1,5}=1;
    %     model = handles.jtable.getModel.getActualModel;
    %     %model = getOriginalModel(jtable);
    %     model.groupAndRefresh;
    %     handles.jtable.repaint;
    userData.jtable = createTreeTable(gData,userData);
    
    userData.sample_data={};
    userData.firstPlot=true;
    userData.plotLimits.TIME.RAW.xMin=NaN;
    userData.plotLimits.TIME.RAW.xMax=NaN;
    userData.plotLimits.MULTI.RAW.yMin=NaN;
    userData.plotLimits.MULTI.RAW.yMax=NaN;
    setappdata(theParent, 'UserData', userData);
end

end


