function [ output_args ] = useQCflags_Callback( hObject, eventdata, handles )
%USEQCFLAGS_CALLBACK Easyplot | Use QC flags callback

%   Detailed explanation goes here

theParent = ancestor(hObject,'figure');
userData=getappdata(theParent, 'UserData');

if strcmp(get(hObject,'Checked'),'on')
    set(hObject,'Checked','off');
    userData.EP_plotQC = false;
else 
    set(hObject,'Checked','on');
    userData.EP_plotQC = true;
end
userData.EP_redoPlots = true;
setappdata(theParent, 'UserData', userData);
if isfield(userData,'sample_data')
    plotData(theParent);
end
end

