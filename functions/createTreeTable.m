%%
function jtable = createTreeTable(treePanel)
% NOTE: Java 0-based indexing

persistent hash;
if isempty(hash)
    hash = java.util.Hashtable;
end
if ~isempty(hash.get(treePanel))
    return;
end
hash.put(treePanel,1);

tUserData = getappdata(treePanel, 'UserData');

% {leafIcon, folderClosedIcon, folderOpenIcon}
base_path = 'C:\Program Files\MATLAB\R2018b\toolbox\matlab\uitools\uifigureappjs\release\dijit\themes\tundra\images';
IconFilenames = { fullfile(base_path, []), ...
    fullfile(base_path, 'folderOpened.gif'), ...
    fullfile(base_path, 'folderClosed.gif') };

if ~exist(IconFilenames{2}, 'file')
    IconFilenames = {fullfile(matlabroot,'/toolbox/matlab/icons/greenarrowicon.gif'), ...
        fullfile(matlabroot,'/toolbox/matlab/icons/file_open.png'), ...
        fullfile(matlabroot,'/toolbox/matlab/icons/foldericon.gif'), ...
        };
end

jtable = TreeTable(treePanel, ...
    tUserData.treePanelHeader, ...
    tUserData.treePanelData, ... %    'IconFilenames',{[],[],[]}, ...
    'IconFilenames', IconFilenames, ...
    'ColumnTypes', tUserData.treePanelColumnTypes, ...
    'ColumnGroupBy', tUserData.treePanelColumnGroupBy, ...
    'ColumnEditable', tUserData.treePanelColumnEditable);
pause(0.01);

% Make 'Show' column width small as practible
jtable.JTable.getColumnModel.getColumn(1).setMinWidth(40);
jtable.JTable.getColumnModel.getColumn(1).setMaxWidth(50);
pause(0.01);

% Make 'Slice' column width small as practible
jtable.JTable.getColumnModel.getColumn(2).setMinWidth(40);
jtable.JTable.getColumnModel.getColumn(2).setMaxWidth(50);
pause(0.01);

original_model = getOriginalModel(jtable.JTable);
set(handle(original_model, 'CallbackProperties'), 'TableChangedCallback', {@tableChanged_Callback, treePanel});

tUserData.jtable = jtable;
setappdata(treePanel, 'UserData', tUserData);

% release rentrancy flag
hash.remove(treePanel);

end
