function updateLegends( hObject )
%updateLegends update legends with custom string
%   Detailed explanation goes here

hFig = ancestor(hObject,'figure');
if isempty(hFig), return; end

gData = guidata(hFig);
hAx = findobj(gData.plotPanel,'Type','axes');

for ii = 1:numel(hAx)
    %[legend_h,object_h,plot_h,text_str]=legend(hAx,legendStr,'Location','Best', 'FontSize', 8);
    %[legend_h,object_h,plot_h,text_str]=legend(hAx(ii),legendStr{ii});
    
    %[legend_h,object_h,plot_h,text_str] = legend(hAx(ii), hAx(ii).UserData.LegendStrings);
    %set(legend_h, 'FontSize', 8);
    
    legendStrings = {};
    hLines = findobj(hAx,'Type','line');
    for jj = 1:numel(hLines)
       legendStrings{end+1} = strrep(hLines(jj).Tag,'_','\_');
    end
    [legend_h, ~, ~, ~] = legend(hAx(ii), legendStrings);
    set(legend_h, 'FontSize', 8);
    
    % legendflex still has problems
    %[legend_h,object_h,plot_h,text_str]=legendflex(hAx, legendStr, 'ref', hAx, 'xscale', 0.5, 'FontSize', 8);
end

end

