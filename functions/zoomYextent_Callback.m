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

if ~isfield(userData,'sample_data'), return; end

try
    useQCflags = userData.plotQC;
catch
    useQCflags = false;
end
useFlags = 'RAW';
if useQCflags, useFlags='QC'; end

dataLimits=findVarExtents(userData.sample_data, userData.plotVarNames);
axH = gca;
switch upper(userData.plotType)
    case 'VARS_OVERLAY'
        yMin = NaN;
        yMax = NaN;
        theLimits = dataLimits.MULTI.(useFlags);
        
    case 'VARS_STACKED'
        % have made choice that y-zoom is applied to last plot to have
        % focus
        theVar = axH.Tag;
        theLimits = dataLimits.(theVar).(useFlags);
end

userData.xMin = dataLimits.TIME.RAW.xMin;
userData.xMax = dataLimits.TIME.RAW.xMax;
userData.yMin = theLimits.yMin;
userData.yMax = theLimits.yMax;

if ~isnan(userData.yMin) || ~isnan(userData.yMax)
    set(axH,'YLim',[userData.yMin userData.yMax]);
end

setappdata(ancestor(hObject,'figure'), 'UserData', userData);

for ii = 1:numel(userData.axisHandles)
    updateDateLabel(gData.plotPanel,struct('Axes', userData.axisHandles(ii)), true);
end

end


