%%
function manualAxisLimits_Callback(hObject,eventdata,hObjectGUIdata)
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

if ~isfield(userData,'sample_data')
    return
end

try
    useQCflags = userData.plotQC;
catch
    useQCflags = false;
end
useFlags = 'RAW';
if useQCflags, useFlags='QC'; end

dataLimits=findVarExtents(userData.sample_data, userData.plotVarNames);

nSubPlots = numel(userData.axisHandles);
tableData = {};
switch upper(userData.plotType)
    case 'VARS_OVERLAY'
        theVar = 'MULTI';
        tableData{1,1} = theVar;
        tableData{1,2} = dataLimits.(theVar).(useFlags).yMin;
        tableData{1,3} = dataLimits.(theVar).(useFlags).yMax;
        
    case 'VARS_STACKED'
        for ii=1:nSubPlots
            theVar = char(userData.plotVarNames{ii});
            tableData{ii,1} = theVar;
            tableData{ii,2} = dataLimits.(theVar).(useFlags).yMin;
            tableData{ii,3} = dataLimits.(theVar).(useFlags).yMax;
        end
        tableData
end

% dialog figure
f = figure('Name',        'Enter limits', ...
    'Visible',     'on',...
    'MenuBar',     'none',...
    'Resize',      'off',...
    'WindowStyle', 'Modal',...
    'NumberTitle', 'off');

topPanel = uipanel('Parent', f, 'Position',[0.00 0.75 1.00 0.25], 'Title', '', 'BorderType', 'line');
midPanel = uipanel('Parent', f, 'Position',[0.00 0.20 1.00 0.55], 'Title', '', 'BorderType', 'line');
botPanel = uipanel('Parent', f, 'Position',[0.00 0.00 1.00 0.20], 'Title', '', 'BorderType', 'line');

% create widgets
startDateTxt = uicontrol('Parent', topPanel, 'Style','text', 'String','Start Date');
endDateTxt   = uicontrol('Parent', topPanel,'Style','text', 'String','End Date');
startDateUI = uicontrol('Parent', topPanel,'Style','edit', 'String',datestr(dataLimits.TIME.RAW.xMin,31));
endDateUI   = uicontrol('Parent', topPanel,'Style','edit', 'String',datestr(dataLimits.TIME.RAW.xMax,31));

t = uitable(midPanel);
t.Data = tableData;
t.ColumnName = {'Variable','yMin','yMax'};
t.ColumnEditable = [false true true];
t.CellEditCallback = @tableData_Callback;

confirmButton = uicontrol('Parent', botPanel,'Style', 'pushbutton', 'String', 'Ok');
cancelButton  = uicontrol('Parent', botPanel,'Style', 'pushbutton', 'String', 'Cancel');

% use normalized units
set(f,             'Units', 'normalized');
set(startDateTxt,   'Units', 'normalized');
set(endDateTxt,     'Units', 'normalized');
set(startDateUI,   'Units', 'normalized');
set(endDateUI,     'Units', 'normalized');
set(t,     'Units', 'normalized');
set(cancelButton,  'Units', 'normalized');
set(confirmButton, 'Units', 'normalized');

% position figure and widgets
set(f,             'Position', [0.40, 0.46, 0.25, 0.25]);

set(startDateTxt,   'Position', [0.00, 0.50, 0.50, 0.50 ]);
set(startDateUI,   'Position', [0.50, 0.50, 0.50, 0.50 ]);
set(endDateTxt,     'Position', [0.00, 0.00, 0.50, 0.50 ]);
set(endDateUI,     'Position', [0.50, 0.00, 0.50, 0.50 ]);

set(t, 'Position', [0.00, 0.00, 1.00, 1.00 ]);
%t.Position(3:4) = t.Extent(3:4);

set(cancelButton,  'Position', [0.00, 0.00, 0.50, 1.00 ]);
set(confirmButton, 'Position', [0.50, 0.00, 0.50, 1.00 ]);

% enable use of return/escape to confirm/cancel dialog
%set(f, 'WindowKeyPressFcn', @keyPressCallback);

% reset back to pixel units
set(f,             'Units', 'pixels');
set(startDateTxt,   'Units', 'pixels');
set(endDateTxt,     'Units', 'pixels');
set(startDateUI,   'Units', 'pixels');
set(endDateUI,     'Units', 'pixels');

set(t,  'Units', 'pixels');

set(cancelButton,  'Units', 'pixels');
set(confirmButton, 'Units', 'pixels');

% set widget callbacks
set(f,             'CloseRequestFcn', @cancelCallback);
set(cancelButton,  'Callback',        @cancelCallback);
set(confirmButton, 'Callback',        @confirmCallback);
set(startDateUI,   'Callback',        @startdateCallback);
set(endDateUI,     'Callback',        @enddateCallback);

tEps = 1;  %1minute minimum diff between start/end date
xEps = 1/60/24;
yEps = 0.1; %minimum diff between ymin/ymax

set(f, 'Visible', 'on');
uiwait(f);

%%
    function keyPressCallback(source,ev)
        %KEYPRESSCALLBACK Allows the user to hit the escape/return keys to
        % cancel/confirm the dialog respectively.
        
        if     strcmp(ev.Key, 'escape'), cancelCallback( source,ev);
        elseif strcmp(ev.Key, 'return'), confirmCallback(source,ev);
        end
    end

%%
    function cancelCallback(source,ev)
        %CANCELCALLBACK Reverts user input, then closes the dialog.
        %         if useQCflags
        %             theLimits = dataLimits.QC;
        %         else
        %             theLimits = dataLimits.RAW;
        %         end
        
        switch upper(userData.plotType)
            case 'VARS_OVERLAY'
                theVar = 'MULTI';
                if ~isnan(dataLimits.(theVar).(useFlags).yMin) || ~isnan(dataLimits.(theVar).(useFlags).yMax)
                    set(userData.axisHandles(1),'YLim',[dataLimits.(theVar).(useFlags).yMin dataLimits.(theVar).(useFlags).yMax]);
                end
                
            case 'VARS_STACKED'
                for ii=1:numel(userData.axisHandles)
                    theVar = char(userData.plotVarNames{ii});
                    if ~isnan(dataLimits.(theVar).(useFlags).yMin) || ~isnan(dataLimits.(theVar).(useFlags).yMax)
                        set(userData.axisHandles(ii),'YLim',[dataLimits.(theVar).(useFlags).yMin dataLimits.(theVar).(useFlags).yMax]);
                    end
                end
        end
            
        for ii=1:numel(userData.axisHandles)
            set(userData.axisHandles(ii),'XLim',[dataLimits.TIME.RAW.yMin dataLimits.TIME.RAW.yMax]);
            updateDateLabel(gData.plotPanel,struct('Axes', userData.axisHandles(ii)), true);
        end
        setappdata(ancestor(source,'figure'), 'UserData', userData);
        delete(f);
    end

%%
    function confirmCallback(source,ev)
        %CONFIRMCALLBACK Closes the dialog.
        delete(f);
    end

%%
    function startdateCallback(source,ev)
        %startdateCallback Called when the startdate value is changed.
        try
            xMin = datenum(get(startDateUI, 'String'));
            if xMin < dataLimits.TIME.RAW.xMax-xEps
                userData.plotLimits.TIME.xMin = xMin;
                for ii=1:numel(userData.axisHandles)
                    set(userData.axisHandles(ii),'XLim',[xMin dataLimits.TIME.RAW.xMax]);
                    updateDateLabel(gData.plotPanel,struct('Axes', userData.axisHandles(ii)), true);
                end
                %setappdata(theParent, 'UserData', userData);
                
            else
                set(startDateUI,'String',datestr(userData.plotLimits.TIME.xMin,31));
                errordlg(['There must be a ' num2str(tEps) ' minute difference between start/end date.']);
            end
        catch me
            set(startDateUI,'String',datestr(userData.plotLimits.TIME.xMin,31));
            errordlg('Unable to parse start date.');
        end
    end

%%
    function enddateCallback(source,ev)
        %enddateCallback Called when the enddate value is changed.
        try
            xMax = datenum(get(endDateUI, 'String'));
            if xMax > dataLimits.TIME.RAW.xMin+xEps
                userData.plotLimits.TIME.xMax = xMax;
                for ii=1:numel(userData.axisHandles)
                    set(userData.axisHandles(ii),'XLim',[dataLimits.TIME.RAW.xMin xMax]);
                    updateDateLabel(gData.plotPanel,struct('Axes', userData.axisHandles(ii)), true);
                end
                setappdata(theParent, 'UserData', userData);
                
            else
                set(endDateUI,'String',datestr(userData.plotLimits.TIME.xMax,31));
                errordlg(['There must be a ' num2str(tEps) ' minute difference between start/end date.']);
            end
        catch
            set(endDateUI,'String',datestr(userData.xMax,31));
            errordlg('Unable to parse end date.');
        end
    end

%%
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

%%
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

%%
    function tableData_Callback(hObject,callbackdata)
        disp('tableDataCallback');
        iRow = callbackdata.Indices(1);
        iCol = callbackdata.Indices(2);
        axH = userData.axisHandles(iRow);
        switch iCol
            case 2 % yMin
                if callbackdata.NewData > hObject.Data{iRow,3}
                    hObject.Data{iRow,iCol} = callbackdata.PreviousData;
                    return
                end
                set(userData.axisHandles(iRow), 'YLim', [callbackdata.NewData hObject.Data{iRow,3}]);
                
            case 3 % yMax
                if callbackdata.NewData < hObject.Data{iRow,2}
                    hObject.Data{iRow,iCol} = callbackdata.PreviousData;
                    return
                end
                set(userData.axisHandles(iRow), 'YLim', [hObject.Data{iRow,2} callbackdata.NewData ]);
        end
    end
end
