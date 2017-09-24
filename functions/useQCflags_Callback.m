function [ output_args ] = useQCflags_Callback( hObject, eventdata, handles )
%USEQCFLAGS_CALLBACK Easyplot | Use QC flags callback

%   Detailed explanation goes here

theParent = ancestor(hObject,'figure');
userData=getappdata(theParent, 'UserData');
gData = guidata(theParent);

if strcmp(get(hObject,'Checked'),'on')
    set(hObject,'Checked','off');
    userData.plotQC = false;
else 
    set(hObject,'Checked','on');
    userData.plotQC = true;
end

end

