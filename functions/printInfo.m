%%
function printInfo(hObject, eventdata)
%printInfo : display info on currently plotted data at user selected time
%
% User can visually select a time (via shift + left mouse click), display
% some info in a table

hFig=ancestor(hObject,'figure');
userData=getappdata(hFig, 'UserData');

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
    
    tableFig = figure('Name', 'Measured Data', ...
        'NumberTitle', 'off', ...
        'Position', [200 200 800 150], ...
        'Interruptible', 'off', ...
        'WindowStyle', 'modal');
    set(tableFig, 'Toolbar', 'none');
    
    % uitable with some JIDE customization
    columnname =   {'Variable', 'Instrument', 'Start Date', 'End Date', 'Selected Date', 'Value'};
    columnformat = {'char', 'char', 'char', 'char', 'char', 'numeric'};
    tablePos = posUi2(tableFig, 100, 100,   1:100,  1:100,  0, 'normalized');
    mtable = uitable('Parent', tableFig,...
        'Units', 'normalized', ...
        'Position', tablePos,...
        'Data', listData,...
        'ColumnName', columnname,...
        'ColumnFormat', columnformat,...
        'RowName',[]);
    
    jscrollpane = findjobj(mtable);
    jtable = jscrollpane.getViewport.getView;
    % Now turn the JIDE sorting on
    jtable.setSortable(true);		% or: set(jtable,'Sortable','on');
    jtable.setAutoResort(true);
    jtable.setMultiColumnSortable(false);
    jtable.setPreserveSelectionsAfterSorting(true);
    jtable.setColumnAutoResizable(true);
    jtable.setAutoResizeMode(jtable.AUTO_RESIZE_ALL_COLUMNS);
    
    % external package
    %mtable = createTable('Container',tableFig,'Data',listData, 'Headers',columnname, 'Buttons','off');
    
end

end

