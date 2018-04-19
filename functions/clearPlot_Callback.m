%% --- Executes on button press in clearPlot.
function clearPlot_Callback(hObject, eventdata, oldHandles)
%CLEARPLOT_CALLBACK Clear easyplot plot window
%
% hObject    handle to clearPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hFig = ancestor(hObject,'figure');
userData=getappdata(hFig, 'UserData');

filelistPanel= findobj(hFig, 'Tag','filelistPanel');
filelistPanelListbox  = findobj(filelistPanel, 'Tag','filelistPanelListbox');

treePanel = findobj(hFig, 'Tag','treePanel');
plotPanel = findobj(hFig, 'Tag','plotPanel');

% clear plot
if isfield(userData, 'sample_data')
    % clear plots
    children = get(plotPanel, 'Children');
    delete(children);
    
    % clear file list
    set(filelistPanelListbox,'String', '');
    
    % clear tree table
    % https://undocumentedmatlab.com/blog/treetable#comment-308645
    jtree = userData.jtable;
    jtreePanel = jtree.getParent.getParent.getParent;
    jtreePanelParent = jtreePanel.getParent;
    jtreePanelParent.remove(jtreePanel);
    jtreePanelParent.repaint;
    
    userData.sample_data = {};
    userData.EP_firstPlot = true;
    userData.plotLimits.TIME.RAW.xMin = NaN;
    userData.plotLimits.TIME.RAW.xMax = NaN;
    userData.plotLimits.MULTI.RAW.yMin = NaN;
    userData.plotLimits.MULTI.RAW.yMax = NaN;
    setappdata(hFig, 'UserData', userData);
end

end


