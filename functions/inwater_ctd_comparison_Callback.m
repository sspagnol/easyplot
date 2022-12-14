function inwater_ctd_comparison_Callback(hObject, eventdata, handles)
% --- Executes on button press in inwater_ctd_comparison.
% hObject    handle to BathCals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hFig = ancestor(hObject,'figure');
userData=getappdata(hFig, 'UserData');

if ~isfield(userData, 'sample_data'), return; end

helpdlg({'Data matching routines are not very smart. Interpretation is required so consider the plots an in-field guideline only.'}, 'ATTENTION');
uiwait();

plotVar = {'TEMP'};
varList = {'TEMP', 'CNDC', 'EP_PSAL'};
title = 'Variable to plot?';
prompt = 'Variable List';
defaultanswer = 1;
plotVar = optionDialog( title, prompt, varList, defaultanswer );
pause(0.1);

if isempty(plotVar), return; end

inwater_ctd_comparison(userData, plotVar);

end
