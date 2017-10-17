%%
function jtable = createTreeTable(panel, userData)

%'IconFilenames'  => filepath strings      (default={leafIcon,folderClosedIcon,folderOpenIcon}

jtable = treeTable(panel, ...
    userData.treePanelHeader,...
    userData.treePanelData,...
    'IconFilenames',{[],[],[]},...
    'ColumnTypes',userData.treePanelColumnTypes,...
    'ColumnEditable',userData.treePanelColumnEditable);

% Make 'Visible' column width small as practible
jtable.getColumnModel.getColumn(2).setMaxWidth(45);

%jtable.getColumnModel.getColumn(3).setMinWidth(30);

% right-align second column
renderer = jtable.getColumnModel.getColumn(1).getCellRenderer;
renderer.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
jtable.getColumnModel.getColumn(1).setCellRenderer(renderer);

set(handle(getOriginalModel(jtable),'CallbackProperties'), 'TableChangedCallback', {@tableVisibilityCallback, panel});

end
