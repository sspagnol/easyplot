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

if ~isfield(userData,'sample_data'), return; end

gData = guidata(theParent);

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
        theVar = 'MULTI';
        theLimits = dataLimits.MULTI.(useFlags);
        
    case 'VARS_STACKED'
        % have made choice that y-zoom is applied to last plot to have
        % focus
        theVar = axH.Tag;
        theLimits = dataLimits.(theVar).(useFlags);
end

userData.plotLimits.TIME.xMin = dataLimits.TIME.RAW.xMin;
userData.plotLimits.TIME.xMax = dataLimits.TIME.RAW.xMax;
userData.plotLimits.MULTI.yMin = theLimits.yMin;
userData.plotLimits.MULTI.yMax = theLimits.yMax;
userData.plotLimits.(theVar).yMin = theLimits.yMin;
userData.plotLimits.(theVar).yMax = theLimits.yMax;

if ~isnan(theLimits.yMin) || ~isnan(theLimits.yMax)
    set(axH,'YLim',[theLimits.yMin theLimits.yMax]);
end

setappdata(ancestor(hObject,'figure'), 'UserData', userData);

children = findobj(gData.plotPanel,'Type','axes');
for ii = 1:numel(children)
    updateDateLabel(gData.plotPanel,struct('Axes', children(ii)), true);
end

end


