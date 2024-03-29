%%
function datacursorText = customDatacursorText(hObject, eventdata)
%customDatacursorText : custom data tip display

% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).
% event_obj

hFig = ancestor(hObject,'figure');
userData = getappdata(hFig, 'UserData');
if isempty(hFig)
    return;
end
if isempty(userData)
    return;
end

dataIndex = get(eventdata,'DataIndex');
pos = get(eventdata,'Position');

if userData.EP_plotYearly
    datacursorText = {['Day: ', pos(1)],...
        ['Y: ',num2str(pos(2), '%10.4f')]};
else
    xpos = eventdata.Target.XData(dataIndex);
    datacursorText = {['Time: ', datestr(xpos,'yyyy-mm-dd HH:MM:SS.FFF')],...
        ['Y: ',num2str(pos(2), '%10.4f')]};
end
% If there is a Z-coordinate in the position, display it as well
if length(pos) > 2
    datacursorText{end+1} = ['Z: ',num2str(pos(3),6)];
end

try
    p=get(eventdata,'Target');
    datacursorText{end+1} = ['DisplayName: ',get(p,'DisplayName')];
    datacursorText{end+1} = ['FileName: ', strrep(p.UserData.fileName, '_', '\_')];
end

end


