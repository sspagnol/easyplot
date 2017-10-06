function updateLegends( hObject )
%updateLegends update legends with custom string
%   Detailed explanation goes here

hFig = ancestor(hObject,'figure');
if isempty(hFig), return; end

gData = guidata(hFig);
hAx = findobj(gData.plotPanel,'Type','axes');

for ii = 1:numel(hAx)
    legendStrings = {};
    hLines = findobj(hAx(ii),'Type','line');
    for jj = 1:numel(hLines)
       legendStrings{end+1} = strrep(hLines(jj).Tag,'_','\_');
    end
    [hLegend, ~, ~, ~] = legend(hAx(ii), legendStrings);
    set(hLegend, 'FontSize', 8);
    
    % legendflex still has problems
    %[legend_h,object_h,plot_h,text_str]=legendflex(hAx, legendStr, 'ref', hAx, 'xscale', 0.5, 'FontSize', 8);
end

end

