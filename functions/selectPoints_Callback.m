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
%select the area to use for comparison
[x,y,ph1] = select_points_v2(axH);

userData.calx = x;
userData.caly = y;

% is there a second range?
temp2 = questdlg(['If there a second ' char(userData.plotVarNames) ' range to select, click '],...
    'Bath Calibrations','No');

switch temp2
    case 'Yes'
        zoom('off');
        [x, y, ph2] = select_points(axH);
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
catch ME
    disp(ME.identifier);
    disp(ME.message);
    warning('had problems executing bathCals');
end

if exist('ph1', 'var'), delete(ph1); end
if exist('ph2', 'var'), delete(ph2); end

%axH.UIContextMenu.HandleVisibility = 'off';
%axH.UIContextMenu.Visible = 'off';
delete(axH.UIContextMenu);

    function [x,y, ph] = select_points_v1(hAx)
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
        % redraw in dataspace units
        if isa(axH.XAxis,'matlab.graphics.axis.decorator.DatetimeRuler')
            ph = plot(datenum2datetime(x), y);
        else
            ph = plot(x, y);
        end
    end

    function [x, y, ph] = select_points_v2(hAx)
        %function [x,y] = select_points
        % If available use drawrectangle function else fallback to rbbox
        % to select points in the timeseries chart for flagging.
        % Returns [x,y] - index of rectangle corners in figure units
                
        if ~isa(axH.XAxis,'matlab.graphics.axis.decorator.DatetimeRuler') && license('test','Image_Toolbox') 
            ph = drawrectangle(hAx);
            x = [ph.Position(1) ph.Position(1)+ph.Position(3)];
            y = [ph.Position(2) ph.Position(2)+ph.Position(4)];
            delete(ph);
        else
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
            if isa(axH.XAxis,'matlab.graphics.axis.decorator.DatetimeRuler')
                x = num2ruler(x, hAx.XAxis);
            end
            ph = plot(x,y);  % redraw in dataspace units
        end
    end

    function [x,y, ph] = select_points(hAx)
        %function [x,y] = select_points
        % Uses rbbox to select points in the timeseries chart for flagging.
        % Returns [x,y] - index of rectangle corners in figure units
        ax = hAx;
        if ~exist('ax')
            ax = gca;
        end
        if ~exist('fg')
            fg = gcf;
        end
        
        % Store current units for axes and figure in order to restore them at the end of the routine.
        funits = get(fg,'Units');
        aunits = get(hAx,'Units');
        
        set(fg,'Units','pixels'); % Set the figure units to 'pixels'
        set(ax,'Units','pixels');  % Set the axis units to 'pixels'
        
        k = waitforbuttonpress;
%         point1 = get(gca,'CurrentPoint');    % button down detected
%         BOUND = rbbox;                   % return figure units
%         point2 = get(gca,'CurrentPoint');    % button up detected

        point1 = hAx.CurrentPoint;    % button down detected
        BOUND = rbbox;                   % return figure units
        point2 = hAx.CurrentPoint;    % button up detected
        disp(point1)
        disp(point2)
        %set(fg,'Units','pixels'); % Set the figure units to 'pixels'
        %set(ax,'Units','pixels');  % Set the axis units to 'pixels'
        P = get(hAx, 'Position');  % Retrieve the axes position.
        XLimit = get(hAx, 'Xlim');
        YLimit = get(hAx, 'Ylim');
        if isa(axH.XAxis,'matlab.graphics.axis.decorator.DatetimeRuler')
            XLimit = datenum(XLimit);
        end
        % Get the coordinates of the lower left corner of the box
        % Its height and width, and the X-Y coordinates of the 4 corners
        DeltaX = XLimit(2)-XLimit(1);
        DeltaY = YLimit(2)-YLimit(1);
        LeftDist = BOUND(1)-P(1);
        UpDist = BOUND(2)-P(2);
        
        % Defining some useful quantities which will be used often
        %XLow = XLimit(1)+DeltaX*LeftDist/P(3);
        XLow = XLimit(1)+DeltaX*P(1)/P(3);
        %XHigh = XLimit(1)+DeltaX*(LeftDist+BOUND(3))/P(3);
        XHigh = XLimit(1)+DeltaX*(P(1)+BOUND(3))/P(3);
        YLow = YLimit(1)+DeltaY*UpDist/P(4);
        YHigh = YLimit(1)+DeltaY*(UpDist+BOUND(4))/P(4);
        
        % This is the X-Y information about the corners of the RBBOX
        XBounds = [XLow, XHigh];
        YBounds = [YLow, YHigh];
        
        % Reset the figure and axis units to their original settings
        set(fg,'Units',funits);
        set(hAx,'Units',aunits);
        
        x = [XLow XHigh XHigh XLow XLow];
        y = [YLow YLow YHigh YHigh YLow];
        hold('on');
        axis('manual');
        % redraw in dataspace units
        if isa(axH.XAxis,'matlab.graphics.axis.decorator.DatetimeRuler')
            ph = plot(datenum_to_datetime(x), y, 'r-.');
        else
            ph = plot(x, y, 'r-.');
        end
    end

end

