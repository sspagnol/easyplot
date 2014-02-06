kk=1;
for ii=1:length(sample_data)
   for kk=1:length(sample_data{ii}.variables)
   varList{kk}=sample_data{ii}.variables{kk}.name;
   kk=kk+1;
   end
end
varList=unique(varList);

disp(sprintf('%s ','Variable list = ',varList{:}));

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

kk=1;
for ii=1:numel(sample_data)
    for jj=1:numel(varList)
        varInd=getVar(sample_data{ii}.variables, char(varList(jj)));
        if varInd~=0
            idTime  = getVar(sample_data{ii}.dimensions, 'TIME');
            plot(sample_data{ii}.dimensions{idTime}.data, sample_data{ii}.variables{varInd}.data);
            legendStr{kk}=strcat(strrep(char(varList(jj)),'_','\_'),'-',sample_data{ii}.meta.instrument_model,'\_',sample_data{ii}.meta.instrument_serial_no);
            kk=kk+1;
        end
    end
end

h = findobj(gca,'Type','line');
% mapping = round(linspace(1,64,length(h)))';
% colors = colormap('jet');
colors = distinguishable_colors(length(h),'white');
for j = 1:length(h)
    try
        %set(h(j),'Color',colors( mapping(j),: ));
        set(h(j),'Color',colors(j,:));
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