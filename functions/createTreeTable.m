%%
function jtable = createTreeTable(panel, userData)

% NOTE: Java 0-based indexing

%'IconFilenames'  => filepath strings      (default={leafIcon,folderClosedIcon,folderOpenIcon}

treePanelHeader = {'Instrument','File','Serial','Variable','Show','Slice'};
% must group by from LHS only?
treePanelColumnGroupBy = {true, true, true, false, false, false};
treePanelColumnTypes = {'', '', '', 'char', 'logical', 'integer'};
treePanelColumnEditable = {'', '', '', false, true, true};

% I can't work out how to reuse existing jtable and setModelData so just
% delete the old one
if isfield(userData, 'jtable') 
    if ~isempty(userData.jtable)
        % clear tree table
        % https://undocumentedmatlab.com/blog/treetable#comment-308645
        jtree = userData.jtable;
        jtreePanel = jtree.getParent.getParent.getParent;
        if ~isempty(jtreePanel)
            jtreePanelParent = jtreePanel.getParent;
            if ~isempty(jtreePanelParent)
                jtreePanelParent.remove(jtreePanel);
                jtreePanelParent.repaint;
            end
        end
    end
end

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

% update model data tests
%     % doesn't work
%     %set(userData.jtable, 'Data', userData.treePanelData);
%     userData.jtable.setModel(javax.swing.table.DefaultTableModel(userData.treePanelData, treePanelHeader));
%     model = MultiClassTableModel(userData.treePanelData, treePanelHeader)
%     model = com.jidesoft.grid.DefaultGroupTableModel(model)
%     userData.jtable.setModel(model);
%     
%     model = userData.jtable.getModel.getActualModel;
%     model.groupAndRefresh;
%     jtable.repaint;
%     drawnow; pause(0.05);


end
