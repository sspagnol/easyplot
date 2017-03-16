%%
function plotQC_Callback(hObject,eventdata, gData)
%plotQC_Callback : set flag for later plotting routine to use IMOS qc flags
%
% --- Executes on button press in manualAxisLimits.

% hObject    handle to zoomXextent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%
theParent = ancestor(hObject,'figure');
userData=getappdata(theParent, 'UserData');
gData = guidata(theParent);
set(gData.progress, 'String', 'plotQC_Callback');

%set(otherRadio, 'Value', 0);
if isfield(userData,'sample_data')
plotData(theParent);
end

end
