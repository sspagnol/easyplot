%%
function zoomYextent_Callback(hObject, eventdata, oldHandles)
%zoomYextent_Callback : Y-Zoom to data extents
%
% --- Executes on button press in zoomYextent.

% hObject    handle to zoomYextent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
theParent = ancestor(hObject,'figure');
userData=getappdata(theParent, 'UserData');
gData = guidata(theParent);

try
    useQCflags = logical(gData.plotQC.Value);
catch
    useQCflags = false;
end

if isfield(userData,'sample_data')
    dataLimits=findVarExtents(userData.sample_data);
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
    setappdata(ancestor(hObject,'figure'), 'UserData', userData);
    updateDateLabel(gData.figure1,struct('Axes', gData.axes1), true);
end
end


