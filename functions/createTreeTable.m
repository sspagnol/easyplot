%%
function jtable = createTreeTable(treePanel)
% NOTE: Java 0-based indexing

tUserData = getappdata(treePanel, 'UserData');

jtable = TreeTable(treePanel, ...
    tUserData.treePanelHeader, ...
    tUserData.treePanelData, ...
    'IconFilenames',{[],[],[]}, ...
    'ColumnTypes', tUserData.treePanelColumnTypes, ...
    'ColumnGroupBy', tUserData.treePanelColumnGroupBy, ...
    'ColumnEditable', tUserData.treePanelColumnEditable);

% Make 'Show' column width small as practible
jtable.JTable.getColumnModel.getColumn(1).setMinWidth(40);
jtable.JTable.getColumnModel.getColumn(1).setMaxWidth(50);

% Make 'Slice' column width small as practible
jtable.JTable.getColumnModel.getColumn(2).setMinWidth(40);
jtable.JTable.getColumnModel.getColumn(2).setMaxWidth(50);

set(handle(getOriginalModel(jtable.JTable),'CallbackProperties'), 'TableChangedCallback', {@tableChanged_Callback, treePanel});

tUserData.jtable = jtable;
setappdata(treePanel, 'UserData', tUserData);

end
