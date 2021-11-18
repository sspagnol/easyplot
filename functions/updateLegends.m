function updateLegends( hObject )
%UPDATELEGENDS update Easyplot legends with custom string
%   Update Easyplot legends with custom string set in Tag item. 
%   If matlab >= R2018b use newer multicolumn legend.

hFig = ancestor(hObject,'figure');
if isempty(hFig), return; end

plotPanel = findobj(hFig, 'Tag','plotPanel');
graphs = findobj(plotPanel,'Type','axes','-not','tag','legend','-not','tag','Colobar');

for ii = 1:numel(graphs)
    %axes(graphs(ii));
    legend(graphs(ii), 'off');
    
    legendStrings = {};
    hLines = findobj(graphs(ii).Children,'Type','Line');
    
    %legendStrings = strrep({hLines.Tag}, '_', '\_');
    % can have multiple lines per instrument when EP_plotYearly = true
    % make unique strings and get indexing
    [uStrings, IA, IC] = unique(legendStrings, 'stable');
    
    if verLessThan('matlab', '9.5')
        % older style legend, but no multicolumn available
        [hLegend, object_h,plot_h,text_str] = legend(graphs(ii).Children(IA), legendStrings(IA), 'FontSize', 8, 'Interpreter', 'none', 'Location','northeast');
        set(object_h,'linewidth',2.0);
        Htext = findobj(object_h, 'Type', 'Text');
        Hline = findobj(object_h, 'Type', 'Line');
        for jj=1:numel(Htext)
            p1 = Htext(jj).Position;
            Htext(jj).Position = [0.25 p1(2) 0];
            HtextTag = Htext(jj).String;
            HlineTags = {Hline.Tag};
            for kk = find(ismember(HlineTags, HtextTag))
                if numel(Hline(kk).XData) > 1
                    Hline(kk).XData = [0.05 0.2];
                end
            end
        end
    else
        % newer multicolumn legend but not sure how kosher legend
        % linewidths code is
        hLegend = legend(graphs(ii).Children(IA), legendStrings(IA), 'FontSize', 8, 'Interpreter', 'none', 'Location','NorthEast', 'NumColumns', 5);
        hLegend.ItemTokenSize = [15, 36]; % default [30 18]
    end
end
drawnow;
pause(0.01);

end
