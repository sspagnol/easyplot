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
gData = guidata(theParent);

try
    useQCflags = userData.plotQC;
catch
    useQCflags = false;
end

if isfield(userData,'sample_data')
    dataLimits=findVarExtents(userData.sample_data, userData.plotVarNames);
    %     if useQCflags
    %        theLimits = dataLimits.QC;
    %     else
    %         theLimits = dataLimits.RAW;
    %     end
    userData.xMin = dataLimits.TIME.RAW.xMin;
    userData.xMax = dataLimits.TIME.RAW.xMax;
    %userData.yMin = theLimits.yMin;
    %userData.yMax = theLimits.yMax;
    if ~isnan(userData.xMin) || ~isnan(userData.xMax)
        set(gca,'XLim',[userData.xMin userData.xMax]);
    end
    setappdata(ancestor(hObject,'figure'), 'UserData', userData);
    for ii = 1:numel(userData.axisHandles)
        updateDateLabel(gData.plotPanel,struct('Axes', userData.axisHandles(ii)), true);
    end
end

end


