%%
function jtable = createTreeTable(panel, userData)

% NOTE: Java 0-based indexing

%'IconFilenames'  => filepath strings      (default={leafIcon,folderClosedIcon,folderOpenIcon}

treePanelHeader = {'Instrument','File','Serial','Variable','Show','Slice'};
% must group by from LHS only?
treePanelColumnGroupBy = {true, true, true, false, false, false};
treePanelColumnTypes = {'', '', '', 'char', 'logical', 'integer'};
treePanelColumnEditable = {'', '', '', false, true, true};

jtable = treeTable(panel, ...
    treePanelHeader,...
    userData.treePanelData,...
    'IconFilenames',{[],[],[]},...
    'ColumnTypes', treePanelColumnTypes,...
    'ColumnGroupBy', treePanelColumnGroupBy,...
    'ColumnEditable', treePanelColumnEditable);

% Make 'Show' column width small as practible
jtable.getColumnModel.getColumn(1).setMinWidth(40);
jtable.getColumnModel.getColumn(1).setMaxWidth(50);

% Make 'Slice' column width small as practible
jtable.getColumnModel.getColumn(2).setMinWidth(40);
jtable.getColumnModel.getColumn(2).setMaxWidth(50);

% right-align second column
% renderer = jtable.getColumnModel.getColumn(0).getCellRenderer;
% renderer.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
% jtable.getColumnModel.getColumn(0).setCellRenderer(renderer);

% already group on Instrument (0), add File (1) and Serial (2)
% model = jtable.getModel.getActualModel;
% model.addGroupColumn(1);
% model.addGroupColumn(2);
% model.groupAndRefresh;
% jtable.repaint;
 
set(handle(getOriginalModel(jtable),'CallbackProperties'), 'TableChangedCallback', {@tableChanged_Callback, panel});

end
