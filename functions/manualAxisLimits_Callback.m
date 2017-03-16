%%
function manualAxisLimits_Callback(hObject,eventdata)
%manualAxisLimits_Callback : bring up requestor for uses to select axis
%limits
%
% --- Executes on button press in manualAxisLimits.

% hObject    handle to zoomXextent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%
theParent = ancestor(hObject,'figure');
userData=getappdata(theParent, 'UserData');
gData = guidata(theParent);
set(gData.progress, 'String', '');
useQCflags = logical(gData.plotQC.Value);

if isfield(userData,'sample_data')
    dataLimits=findVarExtents(userData.sample_data);
    % dialog figure
    f = figure('Name',        'Enter limits', ...
        'Visible',     'off',...
        'MenuBar',     'none',...
        'Resize',      'off',...
        'WindowStyle', 'Modal',...
        'NumberTitle', 'off');
    
    % create widgets
    startDateTxt = uicontrol('Style','text', 'String','Start Date');
    endDateTxt   = uicontrol('Style','text', 'String','End Date');
    yMinTxt = uicontrol('Style','text', 'String','Y min value');
    yMaxTxt = uicontrol('Style','text', 'String','Y max value');
    startDateUI = uicontrol('Style','edit', 'String',datestr(userData.xMin,31));
    endDateUI   = uicontrol('Style','edit', 'String',datestr(userData.xMax,31));
    yMinUI = uicontrol('Style','edit', 'String',num2str(userData.yMin));
    yMaxUI = uicontrol('Style','edit', 'String',num2str(userData.yMax));
    confirmButton = uicontrol('Style', 'pushbutton', 'String', 'Ok');
    cancelButton  = uicontrol('Style', 'pushbutton', 'String', 'Cancel');
    
    % use normalized units
    set(f,             'Units', 'normalized');
    set(startDateTxt,   'Units', 'normalized');
    set(endDateTxt,     'Units', 'normalized');
    set(yMinTxt,        'Units', 'normalized');
    set(yMaxTxt,        'Units', 'normalized');
    set(startDateUI,   'Units', 'normalized');
    set(endDateUI,     'Units', 'normalized');
    set(yMinUI,        'Units', 'normalized');
    set(yMaxUI,        'Units', 'normalized');
    set(cancelButton,  'Units', 'normalized');
    set(confirmButton, 'Units', 'normalized');
    
    % position figure and widgets
    set(f,             'Position', [0.40, 0.46, 0.25, 0.20]);
    set(cancelButton,  'Position', [0.00, 0.00, 0.50, 0.20 ]);
    set(confirmButton, 'Position', [0.50, 0.00, 0.50, 0.20 ]);
    set(startDateTxt,   'Position', [0.00, 0.80, 0.50, 0.20 ]);
    set(endDateTxt,     'Position', [0.00, 0.60, 0.50, 0.20 ]);
    set(yMinTxt,        'Position', [0.00, 0.40, 0.50, 0.20 ]);
    set(yMaxTxt,        'Position', [0.00, 0.20, 0.50, 0.20 ]);
    set(startDateUI,   'Position', [0.50, 0.80, 0.50, 0.20 ]);
    set(endDateUI,     'Position', [0.50, 0.60, 0.50, 0.20 ]);
    set(yMinUI,        'Position', [0.50, 0.40, 0.50, 0.20 ]);
    set(yMaxUI,        'Position', [0.50, 0.20, 0.50, 0.20 ]);
    
    % enable use of return/escape to confirm/cancel dialog
    %set(f, 'WindowKeyPressFcn', @keyPressCallback);
    
    % reset back to pixel units
    set(f,             'Units', 'pixels');
    set(startDateTxt,   'Units', 'pixels');
    set(endDateTxt,     'Units', 'pixels');
    set(yMinTxt,        'Units', 'pixels');
    set(yMaxTxt,        'Units', 'pixels');
    set(startDateUI,   'Units', 'pixels');
    set(endDateUI,     'Units', 'pixels');
    set(yMinUI,        'Units', 'pixels');
    set(yMaxUI,        'Units', 'pixels');
    set(cancelButton,  'Units', 'pixels');
    set(confirmButton, 'Units', 'pixels');
    
    % set widget callbacks
    set(f,             'CloseRequestFcn', @cancelCallback);
    set(cancelButton,  'Callback',        @cancelCallback);
    set(confirmButton, 'Callback',        @confirmCallback);
    set(startDateUI,      'Callback',        @startdateCallback);
    set(endDateUI,      'Callback',        @enddateCallback);
    set(yMinUI,      'Callback',        @yminCallback);
    set(yMaxUI,       'Callback',        @ymaxCallback);
    
    tEps = 1;  %1minute minimum diff between start/end date
    xEps = 1/60/24;
    yEps = 0.1; %minimum diff between ymin/ymax
    
    set(f, 'Visible', 'on');
    uiwait(f);
end

%%
    function keyPressCallback(source,ev)
        %KEYPRESSCALLBACK Allows the user to hit the escape/return keys to
        % cancel/confirm the dialog respectively.
        
        if     strcmp(ev.Key, 'escape'), cancelCallback( source,ev);
        elseif strcmp(ev.Key, 'return'), confirmCallback(source,ev);
        end
    end

    function cancelCallback(source,ev)
        %CANCELCALLBACK Reverts user input, then closes the dialog.
        if useQCflags
            theLimits = dataLimits.QC;
        else
            theLimits = dataLimits.RAW;
        end
        userData.xMin = theLimits.xMin;
        userData.xMax = theLimits.xMax;
        userData.yMin = theLimits.yMin;
        userData.yMax = theLimits.yMax;
        
        if ~isnan(userData.yMin) || ~isnan(userData.yMax)
            set(gData.axes1,'YLim',[userData.yMin userData.yMax]);
        end
        setappdata(ancestor(source,'figure'), 'UserData', userData);
        updateDateLabel(gData.figure1,struct('Axes', gData.axes1), true);
        delete(f);
    end

    function confirmCallback(source,ev)
        %CONFIRMCALLBACK Closes the dialog.
        delete(f);
    end

    function startdateCallback(source,ev)
        %startdateCallback Called when the startdate value is changed.
        try
            xMin = datenum(get(startDateUI, 'String'));
            if xMin < userData.xMax-xEps
                userData.xMin = xMin;
                set(gData.axes1,'XLim',[userData.xMin userData.xMax]);
                setappdata(theParent, 'UserData', userData);
                updateDateLabel(gData.figure1,struct('Axes', gData.axes1), true);
            else
                set(startDateUI,'String',datestr(userData.xMin,31));
                errordlg(['There must be a ' num2str(tEps) ' minute difference between start/end date.']);
            end
        catch me
            set(startDateUI,'String',datestr(userData.xMin,31));
            errordlg('Unable to parse start date.');
        end
    end

    function enddateCallback(source,ev)
        %enddateCallback Called when the enddate value is changed.
        try
            xMax = datenum(get(endDateUI, 'String'));
            if xMax > userData.xMin+xEps
                userData.xMax = xMax;
                set(gData.axes1,'XLim',[userData.xMin userData.xMax]);
                setappdata(theParent, 'UserData', userData);
                updateDateLabel(gData.figure1,struct('Axes', gData.axes1), true);
            else
                set(endDateUI,'String',datestr(userData.xMax,31));
                errordlg(['There must be a ' num2str(tEps) ' minute difference between start/end date.']);
            end
        catch
            set(endDateUI,'String',datestr(userData.xMax,31));
            errordlg('Unable to parse end date.');
        end
    end

    function yminCallback(source,ev)
        %yminCallback Called when the ymin value is changed.
        yMin = str2num(get(yMinUI, 'String'));
        if yMin < userData.yMax-yEps
            userData.yMin = yMin;
            set(gData.axes1,'YLim',[userData.yMin userData.yMax]);
            setappdata(theParent, 'UserData', userData);
        else
            set(yMinUI, 'String', num2str(userData.yMin));
            errordlg(['There must be a ' num2str(yEps) 'difference between ymin/ymax.']);
        end
    end

    function ymaxCallback(source,ev)
        %ymaxCallback Called when the ymax value is changed.
        yMax = str2num(get(yMaxUI, 'String'));
        if yMax > userData.yMin+yEps
            userData.yMax = yMax;
            set(gData.axes1,'YLim',[userData.yMin userData.yMax]);
            setappdata(theParent, 'UserData', userData);
        else
            set(yMaxUI, 'String', num2str(userData.yMax));
            errordlg(['There must be a ' num2str(yEps) 'difference between ymin/ymax.']);
        end
    end

end
