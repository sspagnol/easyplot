varList=whos;

%ask for a string in order to filter variable to plot
%stringFilter = input('Do you want a filter? Y/N [N]: ', 's');

% selVarInd=variableSelectionGUI1(varList);
% selVarInd = sscanf(selVarInd, '%d');
selVarInd=1:length(varList);

%Create a string for legend
legendStr={};

mp = get(0, 'MonitorPositions');
screen_size = mp(1,:);
screen_size = [0 0 mp(1,3) mp(1,4) ] .* 0.80 + 50;
%create a toolbar and a toggle button to display or not the legend
%toggleLegend(hFigure);
%fh_overlay=figure('Position',screen_size, 'Visible','off');
fh_overlay=figure('Position',screen_size,'Visible','off','ToolBar','figure');
figure(fh_overlay);
%set(fh_overlay, 'Visible', 'off');
set(fh_overlay,'Color',[1 1 1]);
hold('on');

ii=1;
for i=1:length(selVarInd)
    %only plot if variables is a time serie... ie has two colunm and his double,
    if varList(selVarInd(i)).size(2)==2 &&  strcmp(varList(selVarInd(i)).class,'double');
        theData=eval(varList(selVarInd(i)).name);
        plot(theData(:,1), theData(:,2));
        legendStr{ii}=strrep(varList(selVarInd(i)).name, '_', '\_');
        ii=ii+1;
    end
end

h = findobj(gca,'Type','line');
mapping = round(linspace(1,64,length(h)))';
colors = colormap('jet');
for j = 1:length(h)
    try
        set(h(j),'Color',colors( mapping(j),: ));
    catch e
        fprintf('Error changing plot colours in plot %s \n',get(gcf,'Name'));
        disp(e.message);
    end
end

datetick('x','dd-mmm-yyyy');
xlabel('Time (UTC)');
setDate4zoom;
set(fh_overlay,'Visible','on');
%set(hLegend,'Interpreter','none');
legend(legendStr);

clear hfigure i selVarInd plotStr legendStr varList hLegend