% --- Executes on button press in selectPoints.
function selectPoints_Callback(hObject, eventdata, handles)
% hObject    handle to selectPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%user is ready to choose the area for the bath calibrations:
zoom('off');

theParent = ancestor(hObject,'figure');
userData=getappdata(theParent, 'UserData');

gData = guidata(theParent);
axH = gData.axes1;
%[x,y,hh1] = select_points;
[x,y] = select_points(axH);

userData.calx = x;
userData.caly = y;

% is there a second temperature range?
temp2 = questdlg('If there a second temperature range to select, click ',...
    'Bath Calibrations','No');

switch temp2
    case 'Yes'
        zoom('off');
        %[x,y,hh2] = select_points;
        [x,y] = select_points(axH);
        userData.calx2 = x;
        userData.caly2 = y;
    case 'No'
    case 'Cancel'
        return
end

%now call the function to process the bath calibrations and make some
%plots:
try
    bathCals(userData);
catch
    warning('had problems executing bathCals');
end

if verLessThan('matlab','8.4')
    set(handles.selectPoints,'Visible','off');
    set(handles.BathCals,'Visible','on');
else
    handles.selectPoints.Visible = 'off';
    handles.BathCals.Visible = 'on';
end

if exist('hh1'), delete(hh1); end;
if exist('hh2'), delete(hh2); end;

end
