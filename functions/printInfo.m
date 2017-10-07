%%
function printInfo(hObject, eventdata)
%printInfo : display info on currently plotted data at user selected time
%
% User can visually select a time (via shift + left mouse click), display
% some info in a table

theParent=ancestor(hObject,'figure');
userData=getappdata(theParent, 'UserData');
gData = guidata(theParent);
axH = gca;

% is the current pointer within the bounds of the axes?
if localInBounds(axH)
    
    listData=cell(0,6);
    currentPosition = get(axH, 'CurrentPoint');
    
    for ii=1:numel(userData.sample_data) % loop over files
        for jj=1:numel(userData.sample_data{ii}.variables)
            if userData.sample_data{ii}.variablePlotStatus(jj) > 0
                idTime  = getVar(userData.sample_data{ii}.dimensions, 'TIME');
                tData=userData.sample_data{ii}.dimensions{idTime}.data;
                [index,distance]=near(tData,currentPosition(1),1);
                listData(end+1,:)={userData.sample_data{ii}.variables{jj}.name,...
                    strcat(userData.sample_data{ii}.meta.instrument_model,'-',userData.sample_data{ii}.meta.instrument_serial_no),...
                    datestr(tData(1),'yyyy-mm-dd HH:MM:SS.FFF'),...
                    datestr(tData(end),'yyyy-mm-dd HH:MM:SS.FFF'),...
                    datestr(tData(index),'yyyy-mm-dd HH:MM:SS.FFF'),...
                    userData.sample_data{ii}.variables{jj}.data(index)};
            end
        end
    end
    
    tableFig = figure('Position',[200 200 800 150],'Interruptible','off');
    columnname =   {'Variable', 'Instrument', 'Start', 'End', 'User Date', 'Value'};
    %     columnformat = {'char', 'char', 'char', 'numeric'};
    %     columneditable =  [false false false false];
    %% could not get uitable to correctly set auto column width
    %     mtable = uitable('Parent', tableFig,...
    %         'Units', 'normalized', 'Position', [0.1 0.1 0.9 0.9],...
    %         'Data', listData,...
    %         'ColumnName', columnname,...
    %         'ColumnFormat', columnformat,...
    %         'ColumnEditable', columneditable,...
    %         'RowName',[],...
    %         'ColumnWidth','auto');
    %     jscrollpane = findjobj(mtable);
    %     jtable = jscrollpane.getViewport.getView;
    %     % Now turn the JIDE sorting on
    %     jtable.setSortable(true);		% or: set(jtable,'Sortable','on');
    %     jtable.setAutoResort(true);
    %     jtable.setMultiColumnSortable(false);
    %     jtable.setPreserveSelectionsAfterSorting(true);
    %     jtable.setColumnAutoResizable(true);
    %     hButton = uicontrol('Parent', tableFig,...
    %         'Units', 'normalized', 'Position',[0.45 0.05 0.2 0.1],...
    %         'String','Continue',...
    %         'Callback','uiresume(gcbf)');
    
    mtable = createTable('Container',tableFig,'Data',listData, 'Headers',columnname, 'Buttons','off');
    
end

end

