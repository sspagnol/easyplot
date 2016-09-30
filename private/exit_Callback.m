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
struct2ini(fullfile(userData.EPdir,'easyplot.ini'),userData.ini);

delete(gData.figure1);

end


