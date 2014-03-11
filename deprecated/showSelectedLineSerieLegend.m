%this procedure is to be used in parrale with the plot browser.
%Every time you hide/show propertie of a line series, this function also change the 'being visble in legend' property.
%then, to update the legend, use the "insert legend" button of the figure window

%Mederic MAINSON, 04/04/2013.



h_hidenLineSerie = findobj(get(gca,'Children'),'Visible','off');
for i=1:length(h_hidenLineSerie)
    set(get(get(h_hidenLineSerie(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end

h_shownLineSerie = findobj(get(gca,'Children'),'Visible','on');
for i=1:length(h_shownLineSerie)
    set(get(get(h_shownLineSerie(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
end

clear  h_hidenLineSerie i hAnnotation hLegendEntry h_shownLineSerie