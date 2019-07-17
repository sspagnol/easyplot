%% --- Executes on button press in saveImage.
function saveImage_Callback(hObject, eventdata, oldHandles)
%SAVEIMAGE_CALLBACK Easyplot save image
%
% hObject    handle to saveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hFig = ancestor(hObject,'figure');
userData=getappdata(hFig, 'UserData');
msgPanel = findobj(hFig, 'Tag','msgPanel');
msgPanelText = findobj(msgPanel, 'Tag','msgPanelText');
plotPanel = findobj(hFig, 'Tag','plotPanel');
treePanel = userData.treePanel;

if isfield(userData,'sample_data') && numel(userData.sample_data) > 0
    [FILENAME, PATHNAME, FILTERINDEX] = uiputfile('*.png', 'Filename to save png');
    if isequal(FILENAME,0) || isequal(PATHNAME,0)
        disp('No file selected.');
    else
        export_fig(fullfile(PATHNAME,FILENAME),'-png',plotPanel);
        set(msgPanelText,'String','Exported PNG file.');
    end
    %uiresume(handles.figure1);
end

ButtonName = questdlg('Export MATLAB fig?', ...
    'Export MATLAB fig', ...
    'YES', 'NO', 'NO');
switch ButtonName
    case 'YES'
        % set CreateFcn callback in case user double click on fig file to
        % open it
        set(hFig,'CreateFcn','openfig_Callback(gcbo)');
        tUserData = getappdata(treePanel, 'UserData');
        jtable = tUserData.jtable;
        tUserData.jtable = [];
        setappdata(treePanel, 'UserData', tUserData);
        saveas(plotPanel, fullfile(PATHNAME,regexprep(FILENAME,'\.png','\_ep\.fig','ignorecase')), 'fig');
        tUserData = get(treePanel, 'UserData');
        tUserData.jtable = jtable;
        setappdata(treePanel, 'UserData', tUserData);
        set(msgPanelText,'String','Exported FIG file.');
end % switch

end


