function inwater_ctd_comparison(userData, plotVar)
% INWATER_CTD_COMPARISON plot comparison data from user selected CTD and the
% rest of the instruments.
%
% Return two plots of the difference from the reference CTD
%
% Inputs:
%   userData : contains all the data relevant to the instruments loaded
%   plotVar : the variable to plot
%
% Modified from BathCals.m by Rebecca Cowley <rebecca.cowley@csiro.au>
% October, 2015
%
% Simon Spagnol <s.spagnol@aims.gov.au>
% TODO:
%   - do matching on the up and down portion of a ctd cast 

hg2flag = ~verLessThan('matlab', '8.4.0');

%Get the instrument list: use sample_data structures
instModels = cellfun(@(x) x.meta.instrument_model, userData.sample_data, 'UniformOutput', false)';
instShortname = cellfun(@(x) x.meta.EP_instrument_model_shortname, userData.sample_data, 'UniformOutput', false)';
instSerials = cellfun(@(x) x.meta.instrument_serial_no, userData.sample_data, 'UniformOutput', false)';
instFile = cellfun(@(x) x.EP_inputFile, userData.sample_data, 'UniformOutput', false)';
instFileExt = cellfun(@(x) x.EP_inputFileExt, userData.sample_data, 'UniformOutput', false)';

iSet = cellfun(@(x) getVar(x.variables, plotVar) ~= 0, userData.sample_data, 'UniformOutput', false)';
iSet=[iSet{:}]';

instShortnameSerial = strcat(instShortname, '# ', instSerials);
instShortnameSerialFilename = strcat(instShortname, '#', instSerials, ' (', instFile, instFileExt, ')');

% create the dialog box, get index into  sample_data of reference
% CTD instrument
[refinst, ok] = listdlg('PromptString','Choose the CTD instrument',...
    'SelectionMode','single',...
    'ListSize', [400,250],...
    'ListString',instShortnameSerialFilename,...
    'Name', 'Reference instrument');

if ok == 0 % no instrument chosen
    return;
end

userData.refInst = refinst;
% reset instList so that it doesn't include the reference instrument
instShortnameSerial(refinst) = [];
instShortnameSerialFilename(refinst) = [];
instModels(refinst) = [];
iSet(refinst) = [];

% select the instruments that user wishes to compare against, by default
% all other instruments with the appropriate variable are autoselected
f = figure(...
    'Name',        'Select in-water Instruments',...
    'Visible',     'off',...
    'MenuBar'  ,   'none',...
    'Resize',      'off',...
    'WindowStyle', 'Modal',...
    'NumberTitle', 'off');

cancelButton  = uicontrol('Style',  'pushbutton', 'String', 'Cancel');
confirmButton = uicontrol('Style',  'pushbutton', 'String', 'Ok');

setCheckboxes  = [];

for k = 1:numel(instShortnameSerialFilename)
    setCheckboxes(k) = uicontrol(...
        'Style',    'checkbox',...
        'String',   instShortnameSerialFilename{k},...
        'Value',    iSet(k), ...
        'UserData', k);
end

% set all widgets to normalized for positioning
set(f,              'Units', 'normalized');
set(cancelButton,   'Units', 'normalized');
set(confirmButton,  'Units', 'normalized');
set(setCheckboxes,  'Units', 'normalized');

set(f,             'Position', [0.2 0.35 0.6 0.5]);
set(cancelButton,  'Position', [0.0 0.0  0.5 0.1]);
set(confirmButton, 'Position', [0.5 0.0  0.5 0.1]);

rowHeight = 0.9 / numel(instShortnameSerialFilename);
for k = 1:numel(instShortnameSerialFilename)
    rowStart = 1.0 - k * rowHeight;
    set(setCheckboxes (k), 'Position', [0.0 rowStart 0.6 rowHeight]);
end

% set back to pixels
set(f,              'Units', 'normalized');
set(cancelButton,   'Units', 'normalized');
set(confirmButton,  'Units', 'normalized');
set(setCheckboxes,  'Units', 'normalized');

% set widget callbacks
set(f,             'CloseRequestFcn',   @cancelCallback);
set(f,             'WindowKeyPressFcn', @keyPressCallback);
set(setCheckboxes, 'Callback',          @checkboxCallback);
set(cancelButton,  'Callback',          @cancelCallback);
set(confirmButton, 'Callback',          @confirmCallback);

set(f, 'Visible', 'on');

uiwait(f);

plot_ctd_comparison(userData, plotVar);

%%
    function plot_ctd_comparison(userData, plotVar)
        % PLOT_CTD_COMPARISON plot instrument data against a ctd data set
        %
        % Modified from BathCals code from Rebecca Cowley (O&A, Hobart) <Rebecca.Cowley@csiro.au>
        
        refinst_sam = userData.sample_data{refinst};
        refStrTag = strcat(plotVar, '-', refinst_sam.meta.EP_instrument_model_shortname, '-', refinst_sam.meta.EP_instrument_serial_no_deployment);
        refStrTag = regexprep(refStrTag, '[^ -~]', '-');
        %refinst_data = refinst_sam.variables{refinst_sam.EP_variablePlotStatus>0}.data;
        idPlotVar = getVar(refinst_sam.variables, plotVar);
        refinst_data = refinst_sam.variables{idPlotVar}.data;
        
        idTime  = getVar(refinst_sam.dimensions, 'TIME');
        refinst_time = getXdata(refinst_sam.dimensions{idTime});

        % time buffer at start/end to include in matching
        tbuffer = 1/24;
        
        idEP_DEPTH  = getVar(refinst_sam.variables, 'EP_DEPTH');
        idDEPTH  = getVar(refinst_sam.variables, 'DEPTH');
        if idEP_DEPTH ~= 0
            refinst_depth = refinst_sam.variables{idEP_DEPTH}.data;
        elseif idDEPTH ~= 0
            idDEPTH  = getVar(refinst_sam.variables, 'DEPTH');
            refinst_depth = -refinst_sam.variables{idDEPTH}.data;
        else
            warning('CTD does not have recognized pressure variable.');
            return;
        end
        
        % workaround any non-monotonic time issues
        [~, ind] = unique(refinst_time);
        refinst_time = refinst_time(ind); % datenum format
        refinst_data = refinst_data(ind);
        refinst_depth = refinst_depth(ind);
        iNaN = isnan(refinst_data) | isnan(refinst_depth);
        refinst_time(iNaN) = [];
        refinst_data(iNaN) = [];
        refinst_depth(iNaN) = [];
            
        ctd_in_water = refinst_depth < -3;
        refinst_time(~ctd_in_water) = [];
        refinst_data(~ctd_in_water) = [];
        refinst_depth(~ctd_in_water) = [];
        
        refinst_timediff = nanmedian(diff(refinst_time)); % datenum format
        tmin = refinst_time(1);
        tmax = refinst_time(end);
        [~, ind_min_depth] = min(refinst_depth, [], 'omitnan');
        
        if numel(refinst_time) == 0
            warning('No coincident calibration data for selected period.');
            return
        end
        
        data = userData.sample_data;
        data(refinst) = []; % remove reference instrument
        data = data(iSet); % keep only user selected instruments
        
        dinstShortnameSerial = instShortnameSerial(iSet);
        dinstShortnameSerialFilename = instShortnameSerialFilename(iSet);
        dinstModels = instModels(iSet);
        udinstModels = unique(dinstModels, 'stable');
        
        % inst variable versus time:
        f1 = figure('visible', 'off');
        clf(f1);
        ax1 = subplot(2,2,1, 'Parent', f1);
        hold('on');
        dcm_h = datacursormode(f1);
        set(dcm_h, 'UpdateFcn', @customDatacursorText)
        ax1_legText = {};
        
        % ctd depth versus time:
        ax2 = subplot(2,2,2, 'Parent', f1);
        hold('on');
        ax2_legText = {};
        
        ax3 = subplot(2,2,3, 'Parent', f1);
        hold('on');
        ax3_legText = {};
        
        ax4 = subplot(2,2,4, 'Parent', f1);
        hold('on');
        ax4_legText = {};
        
        f2 = figure('visible', 'off');
        clf(f2);
        dcm_f2_h = datacursormode(f2);
        set(dcm_f2_h, 'UpdateFcn', @customDatacursorText)
        f2_ax1 = subplot(1,2,1, 'Parent', f2);
        hold(f2_ax1, 'on');
        f2_ax1_legText = {};
        
        f2_ax2 = subplot(1,2,2, 'Parent', f2);
        hold(f2_ax2, 'on');
        f2_ax2_legText = {};
        
        cc = distinguishable_colors(numel(data), {'w','k'});
        cb = distinguishable_colors(numel(udinstModels), {'w','k'});
        clear('h');
        clear('h2');
        mrkSymbol = {'+','o','*','.','x','s','d','^','>','<','p','h','+','o'};
        rmins = [];
        
        % arrays to hold plot handles to allow control of legend entries
        h1 = [];
        h2 = [];
        h3 = [];
        h4 = [];
        f2_h1 = [];
        f2_h2 = [];
        
        %disp(['| Instrument | Date Range | ' plotVar ' Mean(Inst - Cal Inst) |']);
        %disp('| --- | --- | --- |');
        for ii = 1:numel(data)
            %disp([data{ii}.meta.instrument_model ' ' data{ii}.meta.instrument_serial_no]);
            idPlotVar = getVar(data{ii}.variables, plotVar);
            if idPlotVar == 0, continue; end

            instStrTag = strcat(plotVar, '-', data{ii}.meta.EP_instrument_model_shortname, '-', data{ii}.meta.EP_instrument_serial_no_deployment);
            instStrTag = regexprep(instStrTag, '[^ -~]', '-'); %only printable ascii characters
            
            idTime  = getVar(data{ii}.dimensions, 'TIME');
            inst_time = getXdata(data{ii}.dimensions{idTime});
            inst_data = data{ii}.variables{idPlotVar}.data;
            
            % workaround any non-monotonic time issues
            [~, ind] = unique(inst_time);
            inst_time = inst_time(ind);
            inst_data = inst_data(ind);
            
            idDEPTH  = getVar(data{ii}.variables, 'EP_DEPTH');
            inst_has_depth = false;
            inst_depth = [];
            if idDEPTH ~= 0
                inst_has_depth = true;
                inst_depth = data{ii}.variables{idDEPTH}.data;
                inst_depth = inst_depth(ind);
            end
            
            igIns1 = (inst_time >= (tmin-tbuffer)) & (inst_time <= (tmax+tbuffer));
            %need the largest time diff between ref and each ins as timebase:
            inst_timediff = nanmedian(diff(inst_time));
            %nanmean(diff(inst_time))
            do_tbase_swap = false;
            if (refinst_time(end)-refinst_time(1)) < inst_timediff
               disp('here'); 
               do_tbase_swap = true;
            end
            if (refinst_timediff >= inst_timediff)
                % inst has faster sampling rate than the reference
                % instrument
                % NOTE: not tested fully
                tbase = refinst_time;
                refinst_caldata = refinst_data;
                refinst_caldep = refinst_depth;
                if inst_has_depth
                    insdep = inst_depth;
                end                
                insdat = interp1(inst_time, inst_data, tbase); %match_timebase(tbase, inst_time, inst_data, 'linear');
                iNaN = isnan(refinst_caldata) & isnan(insdat);
                tbase(iNaN) = [];
                refinst_caldata(iNaN) = [];
                refinst_caldep(iNaN) = [];
                insdat(iNaN) = [];
                insdep(iNaN) = [];
            else
                % referenst inst has faster sampling rate than
                % instrument to compare against
                tbase = inst_time(igIns1);
                insdat = inst_data(igIns1);
                if inst_has_depth
                    insdep = inst_depth(igIns1);
                end
                
                %%disp(ii)
                if isempty(tbase)
                    disp(['Unable to match ' instStrTag]);
                    rmins(end+1) = ii;
                    continue;
                elseif numel(tbase) > 2
                    if inst_has_depth
                        refinst_caldep = match_timebase(tbase, refinst_time, refinst_depth, {'linear'});
                        refinst_caldata = match_timebase(tbase, refinst_time, refinst_data, {'linear'});
                        iNaN = isnan(refinst_caldep) | isnan(refinst_caldata);
                        if all(iNaN)
                            refinst_caldep = interp1(refinst_time, refinst_depth, tbase, 'nearest', 'extrap');
                            refinst_caldata = interp1(refinst_time, refinst_data, tbase, 'nearest', 'extrap');
                            iNaN = isnan(refinst_caldep) | isnan(refinst_caldata);
                        end
                        tbase(iNaN) = [];
                        refinst_caldep(iNaN) = [];
                        refinst_caldata(iNaN) = [];
                        insdat(iNaN) = [];
                        insdep(iNaN) = [];
                    else
                        refinst_caldata = match_timebase(tbase, refinst_time, refinst_data, 'linear');
                        iNaN = isnan(refinst_caldata) | isnan(insdat);
                        tbase(iNaN) = [];
                        refinst_caldata(iNaN) = [];
                        insdat(iNaN) = [];
                    end
                else
                    if inst_has_depth
                        index = arrayfun(@(x) near(x-refinst_depth, 0.0), insdep);
                        refinst_caldata = refinst_data(index);
                        refinst_caldep = refinst_depth(index);
                    else
                        index = arrayfun(@(x) near(x-refinst_time, 0.0), tbase);
                        refinst_caldata = refinst_data(index);
                    end
                end
                
                if ~any(refinst_caldata)
                    disp(['No coincident calibration data for ' refStrTag]);
                    disp(['   Selected data range : ' char(datetime(tbase(1), 'ConvertFrom', 'datenum')) ' - ' char(datetime(tbase(end), 'ConvertFrom', 'datenum'))]);
                    disp(['   Ref Inst data range : ' char(datetime(refinst_time(1), 'ConvertFrom', 'datenum')) ' - ' char(datetime(refinst_time(end), 'ConvertFrom', 'datenum'))]);
                    %continue;
                end
                
                %ik = find(strcmp(dinstModels{ii}, udinstModels));
                marker = mrkSymbol{max(mod(ii,numel(mrkSymbol)),1)};
                
                if ii == 1
                    hold(ax1, 'on');
                    h1(end+1) = plot(ax1, datetime(refinst_time(1:ind_min_depth), 'ConvertFrom', 'datenum'), refinst_data(1:ind_min_depth), 'k-', 'linewidth', 1, 'Tag', refStrTag);
                    plot(ax1, datetime(refinst_time(ind_min_depth:end), 'ConvertFrom', 'datenum'), refinst_data(ind_min_depth:end), 'Color', [0.75, 0.75, 0.75], 'LineStyle', '-', 'linewidth', 1, 'Tag', refStrTag);
                    ax1_legText{end+1} = refStrTag;
                    
                    hold(ax2, 'on');
                    h2(end+1) = plot(ax2, datetime(refinst_time(1:ind_min_depth), 'ConvertFrom', 'datenum'), refinst_depth(1:ind_min_depth), 'k-', 'linewidth', 1, 'Tag', refStrTag);
                    plot(ax2, datetime(refinst_time(ind_min_depth:end), 'ConvertFrom', 'datenum'), refinst_depth(ind_min_depth:end), 'Color', [0.75, 0.75, 0.75], 'LineStyle', '-', 'linewidth', 1, 'Tag', refStrTag);
                    ax2_legText{end+1} = refStrTag;
                    
                    hold(ax3, 'on');
                    h3(end+1) = plot(ax3, datetime(refinst_time(1:ind_min_depth), 'ConvertFrom', 'datenum'), refinst_data(1:ind_min_depth), 'k-', 'linewidth', 1, 'Tag', refStrTag);
                    plot(ax3, datetime(refinst_time(ind_min_depth:end), 'ConvertFrom', 'datenum'), refinst_data(ind_min_depth:end), 'Color', [0.75, 0.75, 0.75], 'LineStyle', '-', 'linewidth', 1, 'Tag', refStrTag);
                    ax3_legText{end+1} = refStrTag;
                    
                    hold(ax4, 'on');
                    h4(end+1) = plot(ax4, datetime(refinst_time(1:ind_min_depth), 'ConvertFrom', 'datenum'), refinst_depth(1:ind_min_depth), 'k-', 'linewidth', 1, 'Tag', refStrTag);
                    plot(ax4, datetime(refinst_time(ind_min_depth:end), 'ConvertFrom', 'datenum'), refinst_depth(ind_min_depth:end), 'Color', [0.75, 0.75, 0.75], 'LineStyle', '-', 'linewidth', 1, 'Tag', refStrTag);
                    ax4_legText{end+1} = refStrTag;
                    
                    hold(f2_ax1, 'on');
                    f2_h1(end+1) = plot(f2_ax1, refinst_data(1:ind_min_depth), refinst_depth(1:ind_min_depth), 'k-', 'linewidth', 1, 'Tag', refStrTag);
                    plot(f2_ax1, refinst_data(ind_min_depth:end), refinst_depth(ind_min_depth:end), 'Color', [0.75, 0.75, 0.75], 'LineStyle', '-', 'linewidth', 1, 'Tag', refStrTag);
                    f2_ax1_legText{end+1} = refStrTag;
                end
                
                if inst_has_depth
                    hold(ax3, 'on');
                    index = near(insdep-refinst_caldep, 0.0, 2);
                    h3(end+1) = plot(ax3, datetime(tbase(index), 'ConvertFrom', 'datenum'), insdat(index), 'LineStyle', 'none', 'Marker', marker, 'MarkerSize', 10, 'color', cc(ii,:), 'Tag', instStrTag);
                    ax3_legText{end+1} = instStrTag;
                    
                    hold(ax4, 'on');
                    %index2 = arrayfun(@(x) near(x-refinst_time, 0.0), tbase(index));
                    index2 = cell2mat(arrayfun(@(x) near(x-refinst_depth, 0.0, 2), insdep(index), 'UniformOutput', false));
                    %plot(ax4, datetime(refinst_time(index2), 'ConvertFrom', 'datenum'), refinst_depth(index2), 'LineStyle', 'none', 'Marker', marker, 'MarkerSize', 10, 'color', cc(ii,:), 'Tag', instStrTag);
                    h4(end+1) = plot(ax4, datetime(tbase(index), 'ConvertFrom', 'datenum'), insdep(index), 'LineStyle', 'none', 'Marker', marker, 'MarkerSize', 10, 'color', cc(ii,:), 'Tag', instStrTag);
                    ax4_legText{end+1} = instStrTag;
                    
                    hold(f2_ax1, 'on');
                    f2_h1(end+1) = plot(f2_ax1, insdat(index), insdep(index), 'LineStyle', 'none', 'Marker', marker, 'MarkerSize', 10, 'color', cc(ii,:), 'Tag', instStrTag);
                    f2_ax1_legText{end+1} = instStrTag;
                else
                    hold(ax1, 'on');
                    insdat_caldat = insdat-refinst_caldata;
                    [index, ~] = near(insdat_caldat, 0.0, 2);
                    h1(end+1) = plot(ax1, datetime(tbase(index), 'ConvertFrom', 'datenum'), insdat(index), 'LineStyle', 'none', 'Marker', marker, 'MarkerSize', 10, 'color', cc(ii,:), 'Tag', instStrTag);
                    ax1_legText{end+1} = instStrTag;
                    
                    hold(ax2, 'on');
                    index2 = cell2mat(arrayfun(@(x) near(x-refinst_time, 0.0, 2), tbase(index), 'UniformOutput', false));
                    h2(end+1) = plot(ax2, datetime(refinst_time(index2), 'ConvertFrom', 'datenum'), refinst_depth(index2), 'LineStyle', 'none', 'Marker', marker, 'MarkerSize', 10, 'color', cc(ii,:), 'Tag', instStrTag);
                    ax2_legText{end+1} = instStrTag;
                end
                
                hold(f2_ax2, 'on');
                insdat_caldat = insdat-refinst_caldata;
                [index, ~] = near(insdat_caldat, 0.0, 2);
                f2_h2(end+1) = plot(f2_ax2, datetime(tbase(index), 'ConvertFrom', 'datenum'), insdat_caldat(index), 'LineStyle', '-', 'Marker', marker, 'MarkerSize', 10, 'color', cc(ii,:), 'Tag', instStrTag);
                f2_ax2_legText{end+1} = instStrTag;
                
                %                 diffdat = insdat-refinst_caldata;
                %                 STATS = statistic(diffdat);
                %                 inststr = [data{ii}.meta.instrument_make '-' data{ii}.meta.instrument_model '-' data{ii}.meta.instrument_serial_no];
                %                 str = ['| ' inststr ' | ' datestr(tbase(istart)) ' -- ' datestr(tbase(iend)) ' | ' num2str(STATS.MEAN) ' |'];
                %                 disp(str);
                %                 if size(userData.calx, 1) > 1
                %                     hh2(ii) = plot(ax2, caldat2,insdat2-caldat2, 'Marker', mrkSymbol{mod(ik,numel(mrkSymbol))}, 'Color',cb(ik,:), 'DisplayName', udinstModels{ik});
                %                     XData = get(hh2(ii), 'XData');
                %                     YData = get(hh2(ii), 'YData');
                %                     iend = find(~isnan(XData) & ~isnan(YData), 1, 'last');
                %                     istart = find(~isnan(XData) & ~isnan(YData), 1, 'first');
                %                     text(ax2, double(XData(iend)),double(YData(iend)),...
                %                         data{ii}.meta.instrument_serial_no); %iu{ik}); %
                %                     diffdat = insdat2-caldat2;
                %                     STATS = statistic(diffdat);
                %                     str = ['| ' inststr ' | ' datestr(tbase2(istart)) ' -- ' datestr(tbase2(iend)) ' | ' num2str(STATS.MEAN) ' |'];
                %                     disp(str);
                %                 end
            end
        end
        disp(' ');
        
        % remove instrument names of plots that weren't created
        dinstShortnameSerial(rmins) = [];
        dinstShortnameSerialFilename(rmins) = [];
        dinstModels(rmins) = [];
        
        f1.Visible = 'on';
        
        legText = [refStrTag; dinstShortnameSerial];
        grid(ax1, 'on');
        xlabel(ax1, 'Time');
        ylabel(ax1, makeTexSafe(plotVar));
        legend(h1, ax1_legText);
        title(ax1, makeTexSafe({['CTD compared to other instruments (without a pressure sensor) : ' plotVar], 'matching by nearest time'}));
        ax1.XLim = datetime([tmin-tbuffer; tmax+tbuffer], 'ConvertFrom', 'datenum');
        
        grid(ax2, 'on');
        xlabel(ax2, 'Time');
        ylabel(ax2, 'EP\_DEPTH');
        legend(h2, ax2_legText);
        ax2.XLim = datetime([tmin-tbuffer; tmax+tbuffer], 'ConvertFrom', 'datenum');
        
        grid(ax3, 'on');
        xlabel(ax3, 'Time');
        ylabel(ax3, makeTexSafe(plotVar));
        legend(h3, ax3_legText);
        title(ax3, makeTexSafe({['CTD compared to other instruments (with a pressure sensor) : ' plotVar], 'matching by nearest EP_DEPTH'}));
        ax3.XLim = datetime([tmin-tbuffer; tmax+tbuffer], 'ConvertFrom', 'datenum');
        
        grid(ax4, 'on');
        xlabel(ax4, 'Time');
        ylabel(ax4, 'EP\_DEPTH');
        legend(h4, ax4_legText);
        ax4.XLim = datetime([tmin-tbuffer; tmax+tbuffer], 'ConvertFrom', 'datenum');
        
        linkaxes([ax1, ax3], 'xy');
        linkaxes([ax2, ax4], 'xy');
        
        f2.Visible = 'on';
        
        ax = f2_ax1;
        grid(ax, 'on');
        xlabel(ax, plotVar);
        ylabel(ax, 'EP\_DEPTH');
        legend(f2_h1, f2_ax1_legText);
        title(ax, makeTexSafe({['CTD compared to other instruments (with a pressure sensor) : ' plotVar], 'matching by nearest EP_DEPTH'}));
        
        ax = f2_ax2;
        grid(ax, 'on');
        xlabel(ax, 'Time');
        ylabel(ax, {[plotVar ' difference'], 'Instrument - CTD'});
        legend(f2_h2, f2_ax2_legText);
        ax.XLim = datetime([tmin-tbuffer; tmax+tbuffer], 'ConvertFrom', 'datenum');
    end

%%
    function keyPressCallback(source,ev)
        %KEYPRESSCALLBACK If the user pushes escape/return while the dialog has
        % focus, the dialog is cancelled/confirmed. This is done by delegating
        % to the cancelCallback/confirmCallback functions.
        %
        if     strcmp(ev.Key, 'escape'), cancelCallback( source,ev);
        elseif strcmp(ev.Key, 'return'), confirmCallback(source,ev);
        end
    end

%%
    function cancelCallback(source,ev)
        %CANCELCALLBACK Cancel button callback. Discards user input and closes the
        % dialog .
        %
        iSet(:)    = false;
        delete(f);
    end

%%
    function confirmCallback(source,ev)
        %CONFIRMCALLBACK. Confirm button callback. Closes the dialog.
        %
        delete(f);
    end

%%
    function checkboxCallback(source, ev)
        %CHECKBOXCALLBACK Called when a checkbox selection is changed.
        %
        idx = get(source, 'UserData');
        val = get(source, 'Value');
        
        iSet(idx) = logical(val);
    end

%%
    function datacursorText = customDatacursorText(hObject, eventdata)
        %dataIndex = get(eventdata,'DataIndex');
        pos = get(eventdata,'Position');
        datacursorText = {};
        if isa(eventdata.Target.Parent.XAxis,'matlab.graphics.axis.decorator.DatetimeRuler')
            datacursorText{end+1} = ['X: ' char(num2ruler(pos(1),eventdata.Target.Parent.XAxis))];
        else
            datacursorText{end+1} = ['X: ' num2str(pos(1), '%10.4f')];
        end
        datacursorText{end+1} = ['Y: ', num2str(pos(2), '%10.4f')];
        datacursorText{end+1} = ['Inst: ', makeTexSafe(eventdata.Target.Tag)];
    end

end

