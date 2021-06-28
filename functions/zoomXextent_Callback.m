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

if userData.EP_plotYearly
    set(gca,'XLim', [1 367]);
    set(gca, 'XTick', [1 32  60 91 121 152 182 213 244 274 305 335]);
    datetick(gca, 'x', 'dd-mmm', 'keepticks');
else
    try
        useQCflags = userData.EP_plotQC;
    catch
        useQCflags = false;
    end
    
    userData.plotLimits.TIME.xMin = userData.dataLimits.TIME.RAW.xMin;
    userData.plotLimits.TIME.xMax = userData.dataLimits.TIME.RAW.xMax;
    
    if ~isnan(userData.plotLimits.TIME.xMin) || ~isnan(userData.plotLimits.TIME.xMax)
        set(gca,'XLim',datetime([userData.plotLimits.TIME.xMin userData.plotLimits.TIME.xMax], 'ConvertFrom', 'datenum'));
    end
end

setappdata(hFig, 'UserData', userData);

% since don't have listener, update date labels manually
%updateDateLabel(hFig,struct('Axes', gca), true);

end


