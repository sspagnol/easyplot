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

% release rentrancy flag
hash.remove(treePanel);

end