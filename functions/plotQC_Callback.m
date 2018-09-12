%%
function plotQC_Callback(hObject, eventdata, handles)
%plotQC_Callback : set flag for later plotting routine to use IMOS qc flags
%
% --- Executes on button press in manualAxisLimits.

% hObject    handle to zoomXextent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%
hFig = ancestor(hObject,'figure');
userData=getappdata(hFig, 'UserData');
msgPanel = findobj(hFig, 'Tag','msgPanel');
msgPanelText = findobj(msgPanel, 'Tag','msgPanelText');
set(msgPanelText, 'String', 'plotQC_Callback');

%set(otherRadio, 'Value', 0);
if isfield(userData,'sample_data')
plotData(hFig);
%replot_Callback(hObject, eventdata, handles)
end

end
