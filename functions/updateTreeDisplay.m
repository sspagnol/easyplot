function updateTreeDisplay(treePanel, treePanelData)

tUserData = getappdata(treePanel, 'UserData');
tUserData.treePanelData = treePanelData;

jtable = tUserData.jtable;
if isempty(jtable)
   jtable = createTreeTable(treePanel);
end
jtable.setTableData(treePanelData);

% Make 'Show' column width small as practible
jtable.JTable.getColumnModel.getColumn(1).setMinWidth(40);
jtable.JTable.getColumnModel.getColumn(1).setMaxWidth(50);

% Make 'Slice' column width small as practible
tUserData.jtable.JTable.getColumnModel.getColumn(2).setMinWidth(40);
tUserData.jtable.JTable.getColumnModel.getColumn(2).setMaxWidth(50);

% set callback
set(handle(getOriginalModel(jtable.JTable),'CallbackProperties'), 'TableChangedCallback', {@tableChanged_Callback, treePanel});

tUserData.jtable = jtable;
setappdata(treePanel, 'UserData', tUserData);

end