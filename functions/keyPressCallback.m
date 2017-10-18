function keyPressCallback(source,ev)
%KEYPRESSCALLBACK Called when the WindowKeyPressFcn function is called.
% Keyboard shortcuts to zoom/pan on current axis and uses
% zoomPostCallback to update any linked plots.
%
% Keys you can use are:
% z, Z: zoom in, zoom out, in both dimensions
% x, X: zoom in, zoom out, x dimension only (for all plots)
% y, Y: zoom in, zoom out, y dimension only (only current selected plot)
% arrow keys: pan the data (only current selected plot), shift
% arrow increase panning factor
% a: axis auto
%
% Idea borrowed from https://github.com/gulley/Ax-Drag

theChar = get(gcbf,'CurrentCharacter');
%theChar = sprintf('%c',ev.Character);
isControl = any(cell2mat(regexpi(ev.Modifier, 'control')));
isShift = any(cell2mat(regexpi(ev.Modifier, 'shift')));
isAlt = any(cell2mat(regexpi(ev.Modifier, 'alt')));

% Use these variables to change the zoom and pan amounts
zoomFactor = 0.9;
panFactor = 0.02;

theYLabel = get(get(gca, 'YLabel'),'String');
if ~iscell(theYLabel), theYLabel={theYLabel}; end
if any(cell2mat(regexpi(theYLabel{1}, {'PRES', 'DEPTH'})))
    panFactor = -panFactor;
end

if isShift
    panFactor = 10*panFactor;
end

switch theChar
    case 'a'
        %axis('auto');
        xlim('auto');
        ylim('auto');
        
    case 'n'
        %axis('normal');
        xlim('auto');
        ylim('auto');
        
    case {'x', 'X'}
        if theChar == 'X',
            zoomFactor=1/zoomFactor;
        end
        xLim=get(gca,'XLim');
        xLimNew = [0 zoomFactor*diff(xLim)] + xLim(1) + (1-zoomFactor)*diff(xLim)/2;
        set(gca,'XLim',xLimNew);
        
    case {'y', 'Y'}
        if theChar == 'Y'
            zoomFactor=1/zoomFactor;
        end
        yLim=get(gca,'YLim');
        yLimNew = [0 zoomFactor*diff(yLim)] + yLim(1) + (1-zoomFactor)*diff(yLim)/2;
        set(gca,'YLim',yLimNew);
        
    case {'z', 'Z'}
        if theChar == 'Z'
            zoomFactor=1/zoomFactor;
        end
        xLim=get(gca,'XLim');
        yLim=get(gca,'YLim');
        xLimNew = [0 zoomFactor*diff(xLim)] + xLim(1) + (1-zoomFactor)*diff(xLim)/2;
        yLimNew = [0 zoomFactor*diff(yLim)] + yLim(1) + (1-zoomFactor)*diff(yLim)/2;
        set(gca,'XLim',xLimNew,'YLim',yLimNew);
        
    case {'leftarrow', 28} % arrow left
        xLim=get(gca,'XLim');
        xLimNew = xLim + panFactor*diff(xLim);
        set(gca,'XLim',xLimNew);
        
    case {'rightarrow', 29} % arrow right
        xLim=get(gca,'XLim');
        xLimNew = xLim - panFactor*diff(xLim);
        set(gca,'XLim',xLimNew);
        
    case {'uparrow', 30} % arrow up
        yLim=get(gca,'YLim');
        yLimNew = yLim - panFactor*diff(yLim);
        set(gca,'YLim',yLimNew);
        
    case {'downarrow', 31} % arrow down
        yLim=get(gca,'YLim');
        yLimNew = yLim + panFactor*diff(yLim);
        set(gca,'YLim',yLimNew);
        
end

%updateDateLabel(gca, gca, true);

end

