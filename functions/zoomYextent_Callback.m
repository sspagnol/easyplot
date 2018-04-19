%%
function zoomYextent_Callback(hObject, eventdata, oldHandles)
%zoomYextent_Callback : Y-Zoom to data extents
%
% --- Executes on button press in zoomYextent.

% hObject    handle to zoomYextent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hFig = ancestor(hObject,'figure');
userData=getappdata(hFig, 'UserData');

if ~isfield(userData,'sample_data'), return; end

plotPanel = findobj(hFig, 'Tag','plotPanel');

try
    useQCflags = userData.EP_plotQC;
catch
    useQCflags = false;
end
useFlags = 'RAW';
if useQCflags, useFlags='QC'; end

dataLimits=findVarExtents(userData.sample_data, userData.plotVarNames);
axH = gca;
switch upper(userData.EP_plotType)
    case 'VARS_OVERLAY'
        theVar = 'MULTI';
        
    case 'VARS_STACKED'
        % have made choice that y-zoom is applied to last plot to have
        % focus
        theVar = axH.Tag;
end
theLimits = dataLimits.(theVar).(useFlags);
userData.plotLimits.(theVar).yMin = theLimits.yMin;
userData.plotLimits.(theVar).yMax = theLimits.yMax;

if ~isnan(theLimits.yMin) || ~isnan(theLimits.yMax)
    set(axH,'YLim',[theLimits.yMin theLimits.yMax]);
end

setappdata(hFig, 'UserData', userData);

end


