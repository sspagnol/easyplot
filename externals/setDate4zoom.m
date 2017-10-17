function setDate4zoom
% Listen to zoom events
h = zoom;

set(h,'ActionPostCallback',@mypostcallback);
set(h,'Enable','on');
%

function mypostcallback(obj,evd)
newLim = get(evd.Axes,'XLim');
timeScale=newLim(2)-newLim(1);
if timeScale >= 60 
    datetick('x','dd-mmm-yyyy','keeplimits')
elseif timeScale >= 2
    datetick('x','dd-mmm-yyyy HH:MM','keeplimits')
% elseif timeScale >= 2/24
%     datetick('x','dd-mmm HHPM','keeplimits')
else
    datetick('x','dd-mmm-yyyy HH:MM','keeplimits')
end