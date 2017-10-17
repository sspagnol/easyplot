function updateLegends( hObject )
%updateLegends update legends with custom string
%   Detailed explanation goes here

hFig = ancestor(hObject,'figure');
if isempty(hFig), return; end

plotPanel = findobj(hFig, 'Tag','plotPanel');
graphs = findobj(plotPanel,'Type','axes','-not','tag','legend','-not','tag','Colobar');

for ii = 1:numel(graphs)
    axes(graphs(ii));
    legend('off');
   
    legendStrings = {};
    hLines = findobj(graphs(ii).Children,'Type','Line');
    %legendStrings = {hLines.Tag};
    legendStrings = strrep({hLines.Tag}, '_', '\_');
    %legendStrings = sort(legendStrings);
    [hLegend, object_h,plot_h,text_str] = legend(graphs(ii), legendStrings); %, 'FontSize', 8, 'Interpreter', 'none');
    hLegend.Interpreter = 'none';
    hLegend.FontSize = 8;
    iSort=cellfun(@(x) find(strcmp(x, text_str)), {plot_h.Tag}, 'UniformOutput', false);
    iSort=[iSort{:}];
    legend(text_str(iSort));
    %legend('toggle');
    
    % legendflex still has problems
    %[legend_h,object_h,plot_h,text_str]=legendflex(hAx, legendStr, 'ref', hAx, 'xscale', 0.5, 'FontSize', 8);
end

end

