function updateTreeDisplay(treePanel, treePanelData)

persistent hash;
if isempty(hash)
    hash = java.util.Hashtable;
end
if ~isempty(hash.get(treePanel))
    return;
end
hash.put(treePanel,1);

tUserData = getappdata(treePanel, 'UserData');
tUserData.treePanelData = treePanelData;

jtable = tUserData.jtable;
if isempty(jtable)
   jtable = createTreeTable(treePanel);
   pause(0.01);
end
jtable.setTableData(treePanelData);
pause(0.01);

% Make 'Show' column width small as practible
jtable.JTable.getColumnModel.getColumn(1).setMinWidth(40);
jtable.JTable.getColumnModel.getColumn(1).setMaxWidth(50);
pause(0.01);

% Make 'Slice' column width small as practible
tUserData.jtable.JTable.getColumnModel.getColumn(2).setMinWidth(40);
tUserData.jtable.JTable.getColumnModel.getColumn(2).setMaxWidth(50);
pause(0.01);

% set callback
original_model = getOriginalModel(jtable.JTable);
set(handle(original_model, 'CallbackProperties'), 'TableChangedCallback', {@tableChanged_Callback, treePanel});

tUserData.jtable = jtable;
setappdata(treePanel, 'UserData', tUserData);

% release rentrancy flag
hash.remove(treePanel);

end