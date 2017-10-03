%%
function zoomXextent_Callback(hObject, eventdata, oldHandles)
%zoomXextent_Callback : X-Zoom to data extents
%
% --- Executes on button press in zoomXextent.

% hObject    handle to zoomXextent (see GCBO)
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

dataLimits=findVarExtents(userData.sample_data, userData.plotVarNames);
userData.plotLimits.TIME.xMin = dataLimits.TIME.RAW.xMin;
userData.plotLimits.TIME.xMax = dataLimits.TIME.RAW.xMax;

if ~isnan(userData.plotLimits.TIME.xMin) || ~isnan(userData.plotLimits.TIME.xMax)
    set(gca,'XLim',[userData.plotLimits.TIME.xMin userData.plotLimits.TIME.xMax]);
end

setappdata(ancestor(hObject,'figure'), 'UserData', userData);

children = findobj(gData.plotPanel,'Type','axes');
for ii = 1:numel(children)
    updateDateLabel(gData.plotPanel,struct('Axes', children(ii)), true);
end

end


