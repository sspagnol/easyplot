%%
function updateDateLabel(source, eventData, varargin)
% UPDATEDATELABEL Update dateticks on zoom/pan.
%
% Code from dynamicDateTicks



keepLimits=false;
% The following is mess of code but was of a result of trying to use the
% call function for setup, callback and listener. Since I'm only doing
% setup and listener could probably clean up, but keeping it around for
% reference.
if isgraphics(source,'Axes')
    %disp('updateDateLabel init')
    axH = source; % On which axes has the zoom/pan occurred
elseif isfield(source,'Axes') %called as initialize axes
    %disp('updateDateLabel init')
    axH = source.Axes; % On which axes has the zoom/pan occurred
elseif isfield(eventData,'Axes') %called as callback from zoom/pan
    %disp('updateDateLabel callback')
    axH = eventData.Axes; % On which axes has the zoom/pan occurred
elseif isprop(eventData, 'AffectedObject') %called as a listener XLim event
    %disp('updateDateLabel listener');
    axH = eventData.AffectedObject;
else
    disp('WTF');
end

plotPanel = axH.Parent;

%axesInfo = get(axH, 'UserData');
axesInfo = axH.UserData.axesInfo;

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

%Re-apply date ticks, but keep limits (unless called the first time)
if nargin < 3 || isempty(source) || isempty(axH.XTickLabel)
    datetick(axH, 'x', 'keeplimits');
end

% Get the current axes ticks & labels
ticks  = get(axH, 'XTick');
labels = get(axH, 'XTickLabel');

% Sometimes the first tick can be outside axes limits. If so, remove it & its label
%if all(ticks(1) < get(axH,'xlim'))
%    ticks(1) = [];
%    labels(1,:) = [];
%end
xlims = get(axH,'xlim');
if ticks(1) < xlims(1)
    ticks(1) = [];
    labels(1,:) = [];
end
if ticks(end) > xlims(2)
    ticks(end) = [];
    labels(end,:) = [];
end

[yr, mo, da] = datevec(ticks); % Extract year & day information (necessary for ticks on the boundary)
newlabels = cell(size(labels,1), 1); % Initialize cell array of new tick label information

doMultiline = true;

if regexpi(labels(1,:), '[a-z]{3}', 'once') % Tick format is mmm
    % Add year information to first tick & ticks where the year changes
    ind = [1 find(diff(yr))+1];
    
    if doMultiline
        newlabels(ind) = cellstr(datestr(ticks(ind), 'yyyy'));
        labels=cellfun(@(x,y) {x y}, cellstr(labels), newlabels, 'UniformOutput', false);
        labels=cellfun(@(x) x(~cellfun(@isempty,x)), labels, 'UniformOutput', false);
    else
        newlabels(ind) = cellstr(datestr(ticks(ind), '-yyyy'));
        labels = strcat(labels, newlabels);
    end
elseif regexpi(labels(1,:), '\d\d/\d\d', 'once') % Tick format is mm/dd
    % Change mm/dd to dd/mm if necessary
    labels = datestr(ticks, axesInfo.mdformat);
    % Add year information to first tick & ticks where the year changes
    ind = [1 find(diff(yr))+1];
    % multiline
    if doMultiline
        newlabels(ind) = cellstr(datestr(ticks(ind), 'yyyy' ));
        labels=cellfun(@(x,y) {x y}, cellstr(labels), newlabels, 'UniformOutput', false);
        labels=cellfun(@(x) x(~cellfun(@isempty,x)), labels, 'UniformOutput', false);
    else
        newlabels(ind) = cellstr(datestr(ticks(ind), '-yyyy'));
        labels = strcat(labels, newlabels);
    end
elseif any(labels(1,:) == ':') % Tick format is HH:MM
    % Add month/day/year information to the first tick and month/day to other ticks where the day changes
    ind = find(diff(da))+1;
    if doMultiline
        newlabels{1}   = datestr(ticks(1), [axesInfo.mdformat '-yyyy']);
        newlabels(ind) = cellstr(datestr(ticks(ind), axesInfo.mdformat ));
        labels=cellfun(@(x,y) {x y}, cellstr(labels), newlabels, 'UniformOutput', false);
        labels=cellfun(@(x) x(~cellfun(@isempty,x)), labels, 'UniformOutput', false);
    else
        newlabels{1}   = datestr(ticks(1), [axesInfo.mdformat '-yyyy']); % Add month/day/year to first tick
        newlabels(ind) = cellstr(datestr(ticks(ind), [axesInfo.mdformat '-'])); % Add month/day to ticks where day changes
        labels = strcat(newlabels, labels);
    end
end

graphs = findobj(plotPanel,'Type','axes');
for ii=1:numel(graphs)
    grid(graphs(ii), 'on');
    if doMultiline
        ht = my_xticklabels(graphs(ii), ticks, labels);
    else
        set(graphs(ii), 'XTick', ticks, 'XTickLabel', labels);
    end
end

end

