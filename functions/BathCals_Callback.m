% --- Executes on button press in BathCals.
function BathCals_Callback(hObject, eventdata, handles)
% hObject    handle to BathCals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%have to first make sure that temperature is plotted:
hFig = ancestor(hObject,'figure');
userData=getappdata(hFig, 'UserData');

if ~isfield(userData, 'sample_data'), return; end

plotPanel = findobj(hFig, 'Tag','plotPanel');
treePanel = findobj(hFig, 'Tag','treePanel');

plotVar = {'TEMP'};
varList = {'TEMP', 'CNDC', 'PRES', 'PRES_REL', 'EP_DEPTH', 'LPF_EP_DEPTH'};
title = 'Variable to plot?';
prompt = 'Variable List';
defaultanswer = 1;
plotVar = optionDialog( title, prompt, varList, defaultanswer );

pause(0.1);
if isempty(plotVar), return; end

userData.sample_data = markPlotVar(userData.sample_data, plotVar, true(size(userData.sample_data)));
userData.treePanelData = generateTreeData(userData.sample_data);
%userData.jtable = createTreeTable(treePanel);
updateTreeDisplay(treePanel, userData.treePanelData);
userData.plotVarNames = {plotVar};
setappdata(hFig, 'UserData', userData);
plotData(hFig);
%zoomYextent_Callback(hObject);
%zoomXextent_Callback(hObject);

% Create the UICONTEXTMENU
uic = uicontextmenu(hFig);
% Create the parent menu
bathcalmenu = uimenu(uic,'label',[plotVar ' Bath Calibrations']);
% Create the submenus
m1 = uimenu(bathcalmenu,'label','Select Bound Box',...
    'Callback',{@selectPoints_Callback, 'bathCals'});

%children = findobj(plotPanel,'Type','axes');
children = findobj(plotPanel,'Type','axes','-not','tag','legend','-not','tag','Colobar');
for ii=1:numel(children)
    set(children(ii), 'UIContextMenu', uic);
end

zoom('off');
pan('off');

% for ii=1:numel(children)
% % https://au.mathworks.com/matlabcentral/answers/463333-how-to-deselect-toolbarstatebutton-without-clicking-on-it
% % Properly deselects any state button in the toolbar
% tb = axtoolbar(children(ii), 'default');
% tb.Visible = 'on';
% for k = 1:numel(tb.Children)
%     if isa(tb.Children(k),'matlab.ui.controls.ToolbarStateButton')
%         if strcmp(tb.Children(k).Value,'on')
%             e = tb.Children(k);
%             d = struct;
%             d.Source = e;
%             d.Axes = handles.Axes1;
%             d.EvenName = 'ValueChanged';
%             d.Value = 'off';
%             d.PreviousValue = 'on';
%             feval(tb.Children(k).ValueChangedFcn,e,d);
%         end
%     end
% end
% end

%uic.HandleVisibility = 'off';
%theParent.uic.HandleVisibility = 'on';

h = helpdlg(['Select the region to use for bath calibrations by ' ...
    'zooming in and then use the UIContextMenu ''Select Bound Box''.', ...
    'Calibration selection']);
uiwait(h);
%zoom('on');

end
