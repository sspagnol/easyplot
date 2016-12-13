%% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, oldHandles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
theParent = ancestor(hObject,'figure');
userData=getappdata(theParent, 'UserData');
gData = guidata(theParent);

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
selectionType=get(gData.figure1,'SelectionType');
% If double click
if strcmp(selectionType,'open')
    index_selected = get(gData.listbox1,'Value');
    file_list = get(gData.listbox1,'String');
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
            set(gData.listbox1,'Value',1); % Matlab workaround, add this line so that the list can be changed
            set(gData.listbox1,'String', getFilelistNames(userData.sample_data));
            userData.treePanelData = generateTreeData(userData.sample_data);
            %setappdata(ancestor(hObject,'figure'), 'UserData', userData);
            % surely I don't have to delete and recreate jtable
            %         if isfield(handles,'jtable')
            %             %delete(handles.jtable);
            %             handles.jtable.getModel.getActualModel.getActualModel.setRowCount(0);
            %         end
            userData.jtable = createTreeTable(gData, userData);
            userData.firstPlot=true;
            setappdata(ancestor(hObject,'figure'), 'UserData', userData);
            plotData(ancestor(hObject,'figure'));
            %        set(handles.axes1,'XLim',[handles.xMin handles.xMax]);
            %        set(handles.axes1,'YLim',[handles.yMin handles.yMax]);
            % set(handle(getOriginalModel(handles.jtable),'CallbackProperties'), 'TableChangedCallback', {@tableVisibilityCallback, ancestor(hObject,'figure')});
            
            %drawnow;
        end
    end
end

if strcmp(selectionType,'normal')
    index_selected = get(gData.listbox1,'Value');
    file_list = get(gData.listbox1,'String');
    % Item selected in list box
    filename = file_list{index_selected};
    iFile = find(cell2mat((cellfun(@(x) ~isempty(strfind(x.easyplot_input_file, filename)), userData.sample_data, 'UniformOutput', false))));
    idTime  = getVar(userData.sample_data{iFile}.dimensions, 'TIME');
    newXLimits=[userData.sample_data{iFile}.dimensions{idTime}.data(1) userData.sample_data{iFile}.dimensions{idTime}.data(end)];
    %xlim(handles.axes1, newXLimits);
    zoom(gData.axes1,'reset');
    set(gData.axes1,'XLim',newXLimits);
    %1 guidata(theParent, gData);
    setappdata(ancestor(hObject,'figure'), 'UserData', userData);
    updateDateLabel(gData.figure1,struct('Axes', gData.axes1), true);
    drawnow;
end

end


