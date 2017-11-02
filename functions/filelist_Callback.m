%% --- Executes on selection change in listbox1.
function filelist_Callback(hObject, eventdata, oldHandles)
% hObject    handle to filelistPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hFig = ancestor(hObject,'figure');
userData=getappdata(hFig, 'UserData');

msgPanel = findobj(hFig, 'Tag','msgPanel');
msgPanelText = findobj(msgPanel, 'Tag','msgPanelText');
filelistPanel= findobj(hFig, 'Tag','filelistPanel');
filelistPanelListbox  = findobj(filelistPanel, 'Tag','filelistPanelListbox');
treePanel = findobj(hFig, 'Tag','treePanel');
plotPanel = findobj(hFig, 'Tag','plotPanel');

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
selectionType=get(hFig, 'SelectionType');
% If double click
if strcmp(selectionType,'open')
    index_selected = get(filelistPanelListbox,'Value');
    file_list = get(filelistPanelListbox,'String');
    % Item selected in list box
    filename = file_list{index_selected};
    
    buttonName = questdlg(['Remove file : ' filename], 'Remove file?', 'No');
    if strcmp(upper(buttonName),'YES')
        if numel(userData.sample_data) == 1
            % removing last plot
            clearPlot_Callback(hObject, eventdata, userData);
        else
            iFile = find(cell2mat((cellfun(@(x) ~isempty(strfind(x.easyplot_input_file, filename)), userData.sample_data, 'UniformOutput', false))));
            userData.sample_data(iFile)=[];
            %setappdata(ancestor(hObject,'figure'), 'UserData', userData);
            set(filelistPanelListbox,'Value',1); % Matlab workaround, add this line so that the list can be changed
            set(filelistPanelListbox,'String', getFilelistNames(userData.sample_data));
            userData.treePanelData = generateTreeData(userData.sample_data);
            %setappdata(ancestor(hObject,'figure'), 'UserData', userData);
            % surely I don't have to delete and recreate jtable
            %         if isfield(handles,'jtable')
            %             %delete(handles.jtable);
            %             handles.jtable.getModel.getActualModel.getActualModel.setRowCount(0);
            %         end
            userData.jtable = createTreeTable(treePanel, userData);
            userData.firstPlot=true;
            setappdata(hFig, 'UserData', userData);
            plotData(plotPanel);
            % set(handle(getOriginalModel(handles.jtable),'CallbackProperties'), 'TableChangedCallback', {@tableVisibilityCallback, ancestor(hObject,'figure')});
            
            %drawnow;
        end
    end
end

if strcmp(selectionType,'normal')
    index_selected = get(filelistPanelListbox,'Value');
    file_list = get(filelistPanelListbox,'String');
    % Item selected in list box
    filename = file_list{index_selected};
    iFile = find(cell2mat((cellfun(@(x) ~isempty(strfind(x.easyplot_input_file, filename)), userData.sample_data, 'UniformOutput', false))));
    idTime  = getVar(userData.sample_data{iFile}.dimensions, 'TIME');
    newXLimits=[userData.sample_data{iFile}.dimensions{idTime}.data(1) userData.sample_data{iFile}.dimensions{idTime}.data(end)];
    zoom(gca,'reset');
    set(gca,'XLim',newXLimits);
    setappdata(hFig, 'UserData', userData);
    drawnow;
end

end

