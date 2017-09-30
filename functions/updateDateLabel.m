%%
function updateDateLabel(source, eventData, varargin)
% UPDATEDATELABEL Update dateticks on zoom/pan.
%
% Code from dynamicDateTicks

%if isMultipleCall();  return;  end
theParent = ancestor(source,'figure');
gData = guidata(theParent);
keepLimits=false;
% The following is mess of code but was of a result of trying to use the
% call function for setup, callback and listener. Since I'm only doing
% setup and listener could probably clean up, but keeping it around for
% reference.
if isgraphics(source,'Axes')
    %disp('updateDateLabel init')
    axH = source; % On which axes has the zoom/pan occurred
    axesInfo = get(source, 'UserData');
    keepLimits=true;
elseif isfield(source,'Axes') %called as initialize axes
    %disp('updateDateLabel init')
    axH = source.Axes; % On which axes has the zoom/pan occurred
    axesInfo = get(source.Axes, 'UserData');
    keepLimits=true;
elseif isfield(eventData,'Axes') %called as callback from zoom/pan
    try
        %disp('updateDateLabel callback')
        axH = eventData.Axes; % On which axes has the zoom/pan occurred
        userData=getappdata(source, 'UserData');
        axesInfo = userData.axesInfo;
        keepLimits=true;
        %set(source,'Interruptible','off');
    catch
        source, eventData, varargin
        get(source)
        get(eventData)
    end
else %called as a listener XLim event
    %disp('updateDateLabel listener');
    userData=getappdata(get(eventData.AffectedObject,'Parent'), 'UserData');
    axesInfo = userData.axesInfo;
    axH = handle(gca);
    %If I ever figure out why UserData wasn't being passed on
    %ax1=get(hParent,'CurrentAxes');
    %axesInfo = get(ax1,'UserData'); %
    keepLimits=true;
end

if all(get(axH,'xlim') == [0 1])
    set(axH, 'XLim', [floor(now) floor(now)+1]);
end
% Check if this axes is a date axes. If not, do nothing more (return)
try
    if ~strcmp(axesInfo.Type, 'dateaxes')
        return;
    end
catch
    return;
end

% Re-apply date ticks, but keep limits (unless called the first time)
% if nargin < 3
%     datetick(ax1, 'x', 'keeplimits');
% end

%if keepLimits
datetick(axH, 'x', 'keeplimits');
%datetick(axH, 'x');
%else
%    datetick(ax1, 'x');
%end

% Get the current axes ticks & labels
ticks  = get(axH, 'XTick');
labels = get(axH, 'XTickLabel');

% Sometimes the first tick can be outside axes limits. If so, remove it & its label
if all(ticks(1) < get(axH,'xlim'))
    ticks(1) = [];
    labels(1,:) = [];
end

[yr, mo, da] = datevec(ticks); % Extract year & day information (necessary for ticks on the boundary)
newlabels = cell(size(labels,1), 1); % Initialize cell array of new tick label information

if regexpi(labels(1,:), '[a-z]{3}', 'once') % Tick format is mmm
    % Add year information to first tick & ticks where the year changes
    ind = [1 find(diff(yr))+1];
    newlabels(ind) = cellstr(datestr(ticks(ind), '-yyyy'));
    labels = strcat(labels, newlabels);
elseif regexpi(labels(1,:), '\d\d/\d\d', 'once') % Tick format is mm/dd
    % Change mm/dd to dd/mm if necessary
    labels = datestr(ticks, axesInfo.mdformat);
    % Add year information to first tick & ticks where the year changes
    ind = [1 find(diff(yr))+1];
    newlabels(ind) = cellstr(datestr(ticks(ind), '-yyyy'));
    labels = strcat(labels, newlabels);
elseif any(labels(1,:) == ':') % Tick format is HH:MM
    % Add month/day/year information to the first tick and month/day to other ticks where the day changes
    ind = find(diff(da))+1;
    newlabels{1}   = datestr(ticks(1), [axesInfo.mdformat '-yyyy-']); % Add month/day/year to first tick
    newlabels(ind) = cellstr(datestr(ticks(ind), [axesInfo.mdformat '-'])); % Add month/day to ticks where day changes
    labels = strcat(newlabels, labels);
end
% for ii=1:numel(axesInfo.Linked)
%     if ishghandle(axesInfo.Linked(ii))
%         set(axesInfo.Linked(ii), 'XTick', ticks, 'XTickLabel', labels);
%     end
% end

children = findobj(gData.plotPanel,'Type','axes');
for ii=1:numel(children)
    set(children(ii), 'XTick', ticks, 'XTickLabel', labels);
end

end

