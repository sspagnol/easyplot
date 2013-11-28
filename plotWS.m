varList=whos;

%ask for a string in order to filter variable to plot
%stringFilter = input('Do you want a filter? Y/N [N]: ', 's');

% selVarInd=variableSelectionGUI1(varList);
% selVarInd = sscanf(selVarInd, '%d');
selVarInd=1:length(varList);


%set plot figure and toolbar
hFigure=figure('Visible','off','ToolBar','figure');
%create a toolbar and a toggle button to display or not the legend
%toggleLegend(hFigure);

%Create a string for the plot and legend
plotStr=[];
legendStr=[];
for i=1:length(selVarInd)
    
    %only plot if variables is a time serie... ie has two colunm and his double, 
    if varList(selVarInd(i)).size(2)==2 &&  strcmp(varList(selVarInd(i)).class,'double');   
        plotStr=[plotStr varList(selVarInd(i)).name '(:,1),' varList(selVarInd(i)).name '(:,2),' ];
        legendStr=[legendStr '''' varList(selVarInd(i)).name '''' ',' ];
    end
end

%finishing off plotStr syntax
plotStr=['plot(' plotStr(1:end-1) ')'];
%evaluate plotStr
eval(plotStr);

%finishing off legendStr syntax
legendStr=['hLegend=legend(' legendStr(1:end-1) ');'];
%evaluate legendStr
eval(legendStr)

datetick('x','dd-mmm')
xlabel('Time (UTC)')
setDate4zoom
set(hFigure,'Visible','on');
set(hLegend,'Interpreter','none');
legend('off')


clear hfigure i selVarInd plotStr legendStr varList hLegend