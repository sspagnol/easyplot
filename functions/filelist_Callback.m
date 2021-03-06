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
            % find sample_data struct associated with filename and delete
            % any plots
            iFile = find(cell2mat((cellfun(@(x) ~isempty(strfind(x.EP_inputFullFilename, filename)), userData.sample_data, 'UniformOutput', false))));
            for ii=iFile
                iDeletePlotVars = find(userData.sample_data{ii}.EP_variablePlotStatus > 0)';
                if ~isempty(iDeletePlotVars)
                    for jj = iDeletePlotVars
                        delete(userData.sample_data{ii}.variables{jj}.hLine);
                    end
                end
            end
            % delete sample_data structs
            userData.sample_data(iFile)=[];
            %setappdata(ancestor(hObject,'figure'), 'UserData', userData);
            set(filelistPanelListbox,'Value',1); % Matlab workaround, add this line so that the list can be changed
            set(filelistPanelListbox,'String', getFilelistNames(userData.sample_data));
            
            treePanelData = generateTreeData(userData.sample_data);
            updateTreeDisplay(treePanel, treePanelData);
            
            userData.EP_redoPlots = true;
            setappdata(hFig, 'UserData', userData);
            plotData(plotPanel);
            %drawnow;
        end
    end
end

if strcmp(selectionType,'normal')
    index_selected = get(filelistPanelListbox,'Value');
    file_list = get(filelistPanelListbox,'String');
    % Item selected in list box
    filename = file_list{index_selected};
    iFile = find(cell2mat((cellfun(@(x) ~isempty(strfind(x.EP_inputFullFilename, filename)), userData.sample_data, 'UniformOutput', false))));
    if length(iFile) == 1
        idTime  = getVar(userData.sample_data{iFile}.dimensions, 'TIME');
        newXLimits=[userData.sample_data{iFile}.dimensions{idTime}.data(1) userData.sample_data{iFile}.dimensions{idTime}.data(end)];
    else
        tstart = +Inf;
        tend = -Inf;
        for i = 1:length(iFile)
            idTime  = getVar(userData.sample_data{iFile(i)}.dimensions, 'TIME');
            tstart = min(userData.sample_data{iFile(i)}.dimensions{idTime}.data(1), tstart);
            tend   = max(userData.sample_data{iFile(i)}.dimensions{idTime}.data(end), tend);
        end
        newXLimits=[tstart tend];
    end
    zoom(gca,'reset');
    set(gca,'XLim',newXLimits);
    setappdata(hFig, 'UserData', userData);
    drawnow;
end

end


