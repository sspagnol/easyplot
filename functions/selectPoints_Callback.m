% --- Executes on button press in selectPoints.
function selectPoints_Callback(hObject, eventdata, handles)
% hObject    handle to selectPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%user is ready to choose the area for the bath calibrations:

hFig = ancestor(hObject,'figure');
userData=getappdata(hFig, 'UserData');
%zoom('off');
%pan('off');

axH = gca;
%dragzoom('off');
[x,y,ph1] = select_points(axH);

userData.calx = x;
userData.caly = y;

% is there a second temperature range?
temp2 = questdlg('If there a second temperature range to select, click ',...
    'Bath Calibrations','No');

switch temp2
    case 'Yes'
        zoom('off');
        [x,y,ph2] = select_points(axH);
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

if exist('ph1'), delete(ph1); end
if exist('ph2'), delete(ph2); end

%axH.UIContextMenu.HandleVisibility = 'off';
%axH.UIContextMenu.Visible = 'off';
delete(axH.UIContextMenu);
%dragzoom(axH, 'on');

    function [x,y, ph] = select_points(hAx)
        %function [x,y] = select_points
        % Uses rbbox to select points in the timeseries chart for flagging.
        % Returns [x,y] - index of rectangle corners in figure units
        axes(hAx);
        k = waitforbuttonpress;
        point1 = get(gca,'CurrentPoint');    % button down detected
        finalRect = rbbox;                   % return figure units
        point2 = get(gca,'CurrentPoint');    % button up detected
        point1 = point1(1,1:2);              % extract x and y
        point2 = point2(1,1:2);
        p1 = min(point1,point2);             % calculate locations
        offset = abs(point1-point2);         % and dimensions
        x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
        y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
        hold('on');
        axis('manual');
        ph = plot(x,y);                            % redraw in dataspace units
    end

end

