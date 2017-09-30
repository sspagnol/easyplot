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
    useQCflags = userData.plotQC;
catch
    useQCflags = false;
end

if isfield(userData,'sample_data')
    dataLimits=findVarExtents(userData.sample_data, userData.plotVarNames);
    switch upper(userData.plotType)
        case 'VARS_OVERLAY'
            yMin = NaN;
            yMax = NaN;
            for ii=1:numel(userData.plotVarNames)
                theVar = char(userData.plotVarNames{ii});
                if useQCflags
                    yMin = min(yMin, dataLimits.(theVar).QC.yMin);
                    yMax = max(yMax, dataLimits.(theVar).QC.yMax);
                else
                    yMin = min(yMin, dataLimits.(theVar).RAW.yMin);
                    yMax = max(yMax, dataLimits.(theVar).RAW.yMax);
                end
            end
            theLimits.yMin = yMin;
            theLimits.yMax = yMax;
            
        case 'VARS_STACKED'
            gca
            theVar = x;
            if useQCflags
                theLimits = dataLimits.(theVar).QC;
            else
                theLimits = dataLimits.(theVar).RAW;
            end
    end
    userData.xMin = dataLimits.TIME.RAW.xMin;
    userData.xMax = dataLimits.TIME.RAW.xMax;
    userData.yMin = theLimits.yMin;
    userData.yMax = theLimits.yMax;
    
    if ~isnan(userData.yMin) || ~isnan(userData.yMax)
        set(gca,'YLim',[userData.yMin userData.yMax]);
    end
        
    setappdata(ancestor(hObject,'figure'), 'UserData', userData);
    
    for ii = 1:numel(userData.axisHandles)
        updateDateLabel(gData.figure1,struct('Axes', userData.axisHandles{ii}), true);
    end
    
    
end
end


