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
    axH = source; % On which axes has the zoom/pan occurred
elseif isfield(source,'Axes') %called as initialize axes
    axH = source.Axes; % On which axes has the zoom/pan occurred
elseif isfield(eventData,'Axes') %called as callback from zoom/pan
    axH = eventData.Axes; % On which axes has the zoom/pan occurred
elseif isprop(eventData, 'AffectedObject') %called as a listener XLim event
    axH = eventData.AffectedObject;
else
    disp('WTF');
end

plotPanel = axH.Parent;

axesInfo = axH.UserData.axesInfo;

if all(get(axH,'xlim') == [0 1])
    set(axH, 'XLim', [floor(now) floor(now)+1]);
end

hFig = ancestor(plotPanel,'figure');
userData = getappdata(hFig, 'UserData');

% Check if this axes is a date axes. If not, do nothing more (return)
try
    if ~strcmp(axesInfo.Type, 'dateaxes')
        return;
    end
catch
    return;
end

if userData.EP_plotYearly
    if isempty(axH.XTickLabel)
        xticks('auto');
        datetick(axH, 'x', 'dd-mmm')
    else
        datetick(axH, 'x', 'dd-mmm', 'keeplimits')
    end
    %return
end

%Re-apply date ticks, but keep limits (unless called the first time)
if nargin < 3 || isempty(source) || isempty(axH.XTickLabel)
    datetick(axH, 'x', 'keeplimits');
end

xlims = get(axH,'XLim');

% attempt to have better x-tick/label spacing
% stnj=xlims(1);
% finj=xlims(2);
% xextent = xlims(2)-xlims(1);
% daystnj=fix(stnj);
% dayfinj=ceil(finj);
% xextent = xlims(2)-xlims(1);
% if xextent  < 1	% = 1 day HOURLY ticks
%     xticks = daystnj:1/12:dayfinj;	% hourly ticks
%     dateform = 'HH:MM dd/mm/yyyy';
%     shortdateform = 'HH:MM';
% elseif xextent  < 7	% = 1 weeks	DAILY TICKS
%     xticks = daystnj:0.5:dayfinj;	% 12 hourly ticks
%     dateform = 'HH:MM dd/mm/yyyy';
%     shortdateform = 'HH:MM';
% elseif xextent  < 28	% = 4 weeks	DAILY TICKS
%     xticks = daystnj:0.5:dayfinj;	% 12 hourly ticks
%     dateform = 'HH:MM dd/mm/yyyy';
%     shortdateform = 'HH:MM';
% elseif xextent < 56 % = 8 weeks WEEKLY TICKS
%     weekstnj = daystnj;
%     weekfinj = daystnj + 7*ceil((dayfinj-daystnj)/7);
%     xticks = weekstnj:7:weekfinj;
%     dateform = 'dd-mmm yyyy';
%     shortdateform = 'dd-mmm';
% elseif xextent < 196 % = 6 months MONTHLY TICKS
%     [xstart.year,xstart.month] = datevec(daystnj); % discard day hour
%     monthstnj = datenum(xstart.year,xstart.month,1); % 1st of the month
%     [xend.year,xend.month] = datevec(dayfinj); % discard day hour
%     monthfinj = datenum(xend.year,xend.month+1,1); % Additional month
%     % find the number of months
%     nmonth = xend.month + (xend.year-xstart.year)*12 -xstart.month + 1;
%     monthdomain = xstart.month:nmonth:xend.month;
%     xticks = datenum(xstart.year,xstart.month:1:(xstart.month+nmonth),1);
%     dateform = 'dd-mmm yyyy';
%     shortdateform = 'mmm-dd';
% elseif xextent < 364 % = 12 months bi-MONTHLY TICKS
%     disp('plot domain <36 months using MONTHLY TICKS');
%     [xstart.year,xstart.month] = datevec(daystnj); % discard day hour
%     monthstnj = datenum(xstart.year,xstart.month,1); % 1st of the month
%     [xend.year,xend.month] = datevec(dayfinj); % discard day hour
%     monthfinj = datenum(xend.year,xend.month+1,1); % Additional month
%     % find the number of months
%     nmonth = xend.month + (xend.year-xstart.year)*12 -xstart.month + 1;
%     monthdomain = xstart.month:nmonth:xend.month;
%     xticks = datenum(xstart.year,xstart.month:2:(xstart.month+nmonth),1);
%     dateform = 'yyyy-mm-dd';
%     shortdateform = 'mmm-dd';
% elseif xextent < 1080 % = 36 months 4-MONTHLY TICKS
%     [xstart.year,xstart.month] = datevec(daystnj); % discard day hour
%     monthstnj = datenum(xstart.year,xstart.month,1); % 1st of the month
%     [xend.year,xend.month] = datevec(dayfinj); % discard day hour
%     monthfinj = datenum(xend.year,xend.month+1,1); % Additional month
%     % find the number of months
%     nmonth = xend.month + (xend.year-xstart.year)*12 -xstart.month + 1;
%     monthdomain = xstart.month:nmonth:xend.month;
%     xticks = datenum(xstart.year,xstart.month:4:(xstart.month+nmonth),1);
%     dateform = 'yyyy-mm-dd';
%     shortdateform = 'mmm-dd';
% else %  xextent >=1080 = 36 months	ANNUAL TICKS
%     [xstart.year,xstart.month] = datevec(daystnj); % discard day hour
%     yearstnj = datenum(xstart.year,1,1); % 1st of the month
%     [xend.year,xend.month] = datevec(daystnj); % discard day hour
%     yearfinj = datenum(xend.year+1,1,1); % Additional year
%     xticks = datenum(xstart.year:(xend.year+1),1,1);
%     dateform = 'yyyy';
%     shortdateform = 'yyyy';
% end
% switch dateform
%     case 'dd-mmm-yyyy HH:MM:SS', dateChoice = 'yqmwdHMS';
%     case 'dd-mmm-yyyy', dateChoice = 'yqmwd';
%     case 'mm/dd/yy', dateChoice = 'yqmwd';
%     case 'mmm', dateChoice = 'yqm';
%     case 'm', dateChoice = 'yqm';
%     case 'mm', dateChoice = 'yqm';
%     case 'mm/dd', dateChoice = 'yqmwd';
%     case 'dd', dateChoice = 'yqmwd';
%     case 'ddd', dateChoice = 'yqmwd';
%     case 'd', dateChoice = 'yqmwd';
%     case 'yyyy', dateChoice = 'y';
%     case 'yy', dateChoice = 'y';
%     case 'mmmyy', dateChoice = 'yqm';
%     case 'HH:MM:SS', dateChoice = 'yqmwdHMS';
%     case 'HH:MM:SS PM', dateChoice = 'yqmwdHMS';
%     case 'HH:MM', dateChoice = 'yqmwdHMS';
%     case 'HH:MM PM', dateChoice = 'yqmwdHMS';
%     case 'QQ-YY', dateChoice = 'yq';
%     case 'QQ', dateChoice = 'yq';
%     case 'dd/mm', dateChoice = 'yqmwd';
%     case 'dd/mm/yy', dateChoice = 'yqmwd';
%     case 'mmm.dd,yyyy HH:MM:SS', dateChoice = 'yqmwdHMS';
%     case 'mmm.dd,yyyy', dateChoice = 'yqmwd';
%     case 'mm/dd/yyyy', dateChoice = 'yqmwd';
%     case 'dd/mm/yyyy', dateChoice = 'yqmwd';
%     case 'yy/mm/dd', dateChoice = 'yqmwd';
%     case 'yyyy/mm/dd', dateChoice = 'yqmwd';
%     case 'QQ-YYYY', dateChoice = 'yq';
%     case 'mmmyyyy', dateChoice = 'yqm';
%     case 'yyyy-mm-dd', dateChoice = 'yqmwd';
%     case 'yyyymmddTHHMMSS', dateChoice = 'yqmwdHMS';
%     case 'yyyy-mm-dd HH:MM:SS', dateChoice = 'yqmwdHMS';
%     otherwise
%         dateChoice = localParseCustomDateForm(dateform);
% end
% xlabel = cellstr(datestr(xticks,dateform));
% [ticks,labelformat] = dateTickPicker(axH,xlims,shortdateform,dateChoice,0);
% axH.XTick = ticks;
% axH.XTickLabel = [];
% labels = regexprep(cellstr(datestr(ticks,'mm/dd')),'\s','\\n');

%axH.XTickLabel = [];
%datetick(axH, 'x', shortdateform);

% Get the current axes ticks & labels
ticks  = get(axH, 'XTick');
labels = get(axH, 'XTickLabel');
labels = cellstr(labels);
axH.XTickLabel = [];

% Sometimes the first tick can be outside axes limits. If so, remove it & its label
%if all(ticks(1) < get(axH,'xlim'))
%    ticks(1) = [];
%    labels(1,:) = [];
%end

if ticks(1) < xlims(1)
    ticks(1) = [];
    labels(1,:) = [];
end
if ticks(end) > xlims(2)
    ticks(end) = [];
    labels(end,:) = [];
end

%doMultiline = false;
if axesInfo.doMultilineXLabel
    labels = makeLabelsMultiline( ticks, labels, axesInfo.mdformat);
else
    labels = makeLabels( ticks, labels, axesInfo.mdformat);
end

graphs = findobj(plotPanel,'Type','axes');
for ii=1:numel(graphs)
    grid(graphs(ii), 'on');
    if userData.EP_plotYearly
        datetick(graphs(ii), 'x', 'dd-mmm', 'keeplimits')
    else
        if axesInfo.doMultilineXLabel
            ht = my_xticklabels(graphs(ii), ticks, labels);
        else
            set(graphs(ii), 'XTick', ticks, 'XTickLabel', labels);
        end
    end
end

% if axesInfo.doMultilineXLabel
%     ht = my_xticklabels(axH, ticks, labels);
% else
%     set(axH, 'XTick', ticks, 'XTickLabel', labels);
% end

    function labels = makeLabels( ticks, labels, mdformat)
        [yr, mo, da] = datevec(ticks); % Extract year & day information (necessary for ticks on the boundary)
        newlabels = cell(size(labels,1), 1); % Initialize cell array of new tick label information
        if regexpi(labels{1,:}, '[a-z]{3}', 'once') % Tick format is mmm
            % Add year information to first tick & ticks where the year changes
            ind = [1 find(diff(yr))+1];
            newlabels(ind) = cellstr(datestr(ticks(ind), '-yyyy'));
            labels = strcat(labels, newlabels);
            return;
        elseif regexpi(labels{1,:}, '\d\d/\d\d', 'once') % Tick format is mm/dd
            % Change mm/dd to dd/mm if necessary
            labels = datestr(ticks, mdformat);
            % Add year information to first tick & ticks where the year changes
            ind = [1 find(diff(yr))+1];
            newlabels(ind) = cellstr(datestr(ticks(ind), '-yyyy'));
            labels = strcat(labels, newlabels);
            return;
        elseif any(labels{1,:} == ':') % Tick format is HH:MM
            % Add month/day/year information to the first tick and month/day to other ticks where the day changes
            ind = find(diff(da))+1;
            newlabels{1}   = datestr(ticks(1), [mdformat '-yyyy']); % Add month/day/year to first tick
            newlabels(ind) = cellstr(datestr(ticks(ind), [mdformat '-'])); % Add month/day to ticks where day changes
            labels = strcat(newlabels, labels);
        end
    end

    function labels = makeLabelsMultiline( ticks, labels, mdformat)
        [yr, mo, da] = datevec(ticks); % Extract year & day information (necessary for ticks on the boundary)
        newlabels = cell([size(labels,1), 1]); % Initialize cell array of new tick label information
        if regexpi(labels{1,:}, '[a-z]{3}', 'once') % Tick format is mmm
            % Add year information to first tick & ticks where the year changes
            ind = [1 find(diff(yr))+1];
            newlabels(ind) = cellstr(datestr(ticks(ind), 'yyyy'));
        elseif regexpi(labels{1,:}, '\d\d/\d\d', 'once') % Tick format is mm/dd
            % Change mm/dd to dd/mm if necessary
            labels = datestr(ticks, mdformat);
            % Add year information to first tick & ticks where the year changes
            ind = [1 find(diff(yr))+1];
            newlabels(ind) = cellstr(datestr(ticks(ind), 'yyyy' ));
        elseif any(labels{1,:} == ':') % Tick format is HH:MM
            % Add month/day/year information to the first tick and month/day to other ticks where the day changes
            ind = find(diff(da))+1;
            newlabels{1}   = datestr(ticks(1), [mdformat '-yyyy']);
            newlabels(ind) = cellstr(datestr(ticks(ind), mdformat ));
        end
        %tic
        %alabels=cellfun(@(x,y) {x y}, cellstr(labels), ~isempty(newlabels), 'UniformOutput', false);
        %alabels=cellfun(@(x) x(~cellfun(@isempty,x)), alabels, 'UniformOutput', false);
        %toc
        labels = [cellstr(labels), newlabels];
        ind=~cellfun(@isempty,newlabels);
        labels{ind} = {labels{ind} newlabels{ind}};
    end

end

