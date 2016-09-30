%%
function utcOffsets = askUtcOffset(FILENAME)

f = figure('Position',[100 100 400 150]);
startData =  {};
for ii=1:numel(FILENAME)
    startData{ii,1} = FILENAME;
    startData{ii,2} = 0;
end
columnname =   {'Filename', 'UTC Offset'};
columnformat = {'char', 'numeric'};
columneditable =  [false  true];
myTable = uitable('Units','normalized','Position',...
    [0.1 0.1 0.9 0.9], 'Data', startData,...
    'ColumnName', columnname,...
    'ColumnFormat', columnformat,...
    'ColumnEditable', columneditable,...
    'RowName',[]);
set(h,'CloseRequestFcn',@myCloseFcn);
set(h,'Tag', 'myTag');
set(mytable,'Tag','myTableTag');
waitfor(gcf);
finalData=get(myTable,'Data');

    function myCloseFcn(~,~)
        myfigure=findobj('Tag','myTag');
        myData=get(findobj(myfigure,'Tag','myTableTag'),'Data')
        assignin('base','myTestData',myData)
        delete(myfigure)
    end

end
