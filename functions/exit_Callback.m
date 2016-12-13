%% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, oldHandles)
%EXIT_CALLBACK Easyplot exit
%
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userData=getappdata(ancestor(hObject,'figure'), 'UserData');
gData = guidata(ancestor(hObject,'figure'));

userData.ini.startDialog.dataDir=userData.oldPathname;

% inelegant code to handle if user double clicked on a '_ep.fig' and stored
% EPdir is different to current.
[tmpEPdir, ~, ~] = fileparts(which('easyplot'));
userData.EPdir = tmpEPdir;
struct2ini(fullfile(userData.EPdir,'easyplot.ini'),userData.ini);

delete(gData.figure1);

end


