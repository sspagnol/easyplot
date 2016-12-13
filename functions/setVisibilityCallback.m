%%
function setVisibilityCallback(hObject,toggle)
% setVisibilityCallback toggle callback on jtable, not used anymore
hFig=ancestor(hObject,'figure');
userData=guidata(hFig);
if ~isempty(userData)
    if isfield(userData,'jtable')
        if toggle
            %disp('Turning ON tableVisibilityCallback');
            set(handle(getOriginalModel(userData.jtable),'CallbackProperties'), 'TableChangedCallback', {@tableVisibilityCallback, hFig});
        else
            %disp('Turning OFF tableVisibilityCallback');
            set(handle(getOriginalModel(userData.jtable),'CallbackProperties'), 'TableChangedCallback', []);
        end
    end
end

end


