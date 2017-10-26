%%
function zoomXextent_Callback(hObject, eventdata, oldHandles)
%zoomXextent_Callback : X-Zoom to data extents
%
% --- Executes on button press in zoomXextent.

% hObject    handle to zoomXextent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hFig = ancestor(hObject,'figure');
userData=getappdata(hFig, 'UserData');

if ~isfield(userData,'sample_data'), return; end

plotPanel = findobj(hFig, 'Tag','plotPanel');

try
    useQCflags = userData.plotQC;
catch
    useQCflags = false;
end

dataLimits=findVarExtents(userData.sample_data, userData.plotVarNames);
userData.plotLimits.TIME.xMin = dataLimits.TIME.RAW.xMin;
userData.plotLimits.TIME.xMax = dataLimits.TIME.RAW.xMax;

if ~isnan(userData.plotLimits.TIME.xMin) || ~isnan(userData.plotLimits.TIME.xMax)
    set(gca,'XLim',[userData.plotLimits.TIME.xMin userData.plotLimits.TIME.xMax]);
end

setappdata(hFig, 'UserData', userData);

% since don't have listener, update date labels manually
%updateDateLabel(hFig,struct('Axes', gca), true);

end


