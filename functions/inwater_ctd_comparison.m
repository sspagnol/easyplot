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
        
        ref_inst = struct;
        [ref_inst.time, ref_inst.data_raw, ref_inst.depth] = get_refinst_data(refinst_sam, plotVar);
        
        ref_inst_time_diff = nanmedian(diff(ref_inst.time)); % datenum format
        
        if numel(ref_inst.time) == 0
            warning('No coincident calibration data for selected period.');
            return
        end
        
        tmin = ref_inst.time(1);
        tmax = ref_inst.time(end);
        
        % index to deepest point in the cast
        new_ref_inst_depth_lpf = ezsmoothn(ref_inst.depth);
        [~, ind_min_depth] = min(new_ref_inst_depth_lpf, [], 'omitnan');
        
        cast_dn = struct;
        cast_dn.time = ref_inst.time(1:ind_min_depth);
        cast_dn.depth = ref_inst.depth(1:ind_min_depth);
        cast_dn.data_raw = ref_inst.data_raw(1:ind_min_depth);
        cast_dn.str = 'DN';
        
        cast_up = struct;
        cast_up.time = ref_inst.time(ind_min_depth:end);
        cast_up.depth = ref_inst.depth(ind_min_depth:end);
        cast_up.data_raw = ref_inst.data_raw(ind_min_depth:end);
        cast_up.str = 'UP';
        
        % time buffer (in days) at start/end of CTD cast to include in matching
        tbuffer = 30/60/24;
        
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
        
        mplots = 2;
        nplots = 5;
        axs = gobjects(mplots, nplots);
        haxs = cell(mplots, nplots);
        legText = cell(mplots, nplots);
        
        dcm_h = datacursormode(f1);
        set(dcm_h, 'UpdateFcn', @customDatacursorText)
        
        % pp=1, variable versus time, match by time
        % pp=2, ctd depth versus time, match by time
        % pp=3, ctd depth versus variable, match by time
        % pp=4, (ctd var - var) versus time, match by time
        % pp=5, variable versus time, match by depth
        % pp=6, ctd depth versus time, match by depth
        % pp=7, ctd depth versus variable, match by depth
        % pp=8, (ctd var - var) versus time, match by depth
        
        for pp = 1:mplots*nplots
            mm = div(pp-1,nplots) + 1;
            nn = mod(pp-1,nplots) + 1;
            axs(mm, nn) = subplot_tight(mplots, nplots, pp, [0.075, 0.03], 'Parent', f1);
            hold('on');
            legText{mm, nn} = {};
            grid(axs(mm, nn), 'on');
        end
        
        cfunc = @(x) colorspace('RGB->Lab',x);
        cc = distinguishable_colors(numel(data), {'w','k'}, cfunc);
        cb = distinguishable_colors(numel(udinstModels), {'w','k'}, cfunc);
        clear('h');
        clear('h2');
        mrkSymbol = {'+','o','*','.','x','s','d','^','>','<','p','h','+','o'};
        rmins = [];
        
        % plot CTD profiles, black for downcast, grey for upcast
        nn = 1;
        for mm = 1:2
            ax = axs(mm, nn);
            hold(ax, 'on');
            haxs{mm,nn}{end+1} = plot(ax, datetime(ref_inst.time(1:ind_min_depth), 'ConvertFrom', 'datenum'), ref_inst.data_raw(1:ind_min_depth), 'k-', 'linewidth', 1, 'Tag', refStrTag);
            plot(ax, datetime(ref_inst.time(ind_min_depth:end), 'ConvertFrom', 'datenum'), ref_inst.data_raw(ind_min_depth:end), 'Color', [0.75, 0.75, 0.75], 'LineStyle', '-', 'linewidth', 1, 'Tag', refStrTag);
            legText{mm,nn}{end+1} = refStrTag;
            xlabel(ax, 'Time');
            ylabel(ax, makeTexSafe(plotVar));
        end
        
        nn = 2;
        for mm = 1:2
            ax = axs(mm, nn);
            hold(ax, 'on');
            haxs{mm,nn}{end+1} = plot(ax, datetime(ref_inst.time(1:ind_min_depth), 'ConvertFrom', 'datenum'), ref_inst.depth(1:ind_min_depth), 'k-', 'linewidth', 1, 'Tag', refStrTag);
            plot(ax, datetime(ref_inst.time(ind_min_depth:end), 'ConvertFrom', 'datenum'), ref_inst.depth(ind_min_depth:end), 'Color', [0.75, 0.75, 0.75], 'LineStyle', '-', 'linewidth', 1, 'Tag', refStrTag);
            legText{mm,nn}{end+1} = refStrTag;
            xlabel(ax, 'Time');
            ylabel(ax, 'CTD EP\_DEPTH');
        end
        
        nn = 3;
        for mm = 1:2
            ax = axs(mm, nn);
            hold(ax, 'on');
            haxs{mm,nn}{end+1} = plot(ax, ref_inst.data_raw(1:ind_min_depth), ref_inst.depth(1:ind_min_depth), 'k-', 'linewidth', 1, 'Tag', refStrTag);
            plot(ax, ref_inst.data_raw(ind_min_depth:end), ref_inst.depth(ind_min_depth:end), 'Color', [0.75, 0.75, 0.75], 'LineStyle', '-', 'linewidth', 1, 'Tag', refStrTag);
            legText{mm,nn}{end+1} = refStrTag;
            xlabel(ax, makeTexSafe(plotVar));
            ylabel(ax, 'CTD EP\_DEPTH');
        end
        
        nn = 4;
        for mm = 1:2
            ax = axs(mm, nn);
            hold(ax, 'on');
            ax.XAxis = matlab.graphics.axis.decorator.DatetimeRuler;
            xlabel(ax, 'Time');
            ylabel(ax, {[plotVar ' difference'], 'Instrument - CTD'});
        end
        
        %disp(['| Instrument | Date Range | ' plotVar ' Mean(Inst - Cal Inst) |']);
        %disp('| --- | --- | --- |');
       
        for ii = 1:numel(data)
            %disp([data{ii}.meta.instrument_model ' ' data{ii}.meta.instrument_serial_no]);
            idPlotVar = getVar(data{ii}.variables, plotVar);
            if idPlotVar == 0, continue; end
            
            instStrTag = strcat(plotVar, '-', data{ii}.meta.EP_instrument_model_shortname, '-', data{ii}.meta.EP_instrument_serial_no_deployment);
            instStrTag = regexprep(instStrTag, '[^ -~]', '-'); %only printable ascii characters
            
            [inst_time, inst_data_raw, inst_depth_raw, inst_has_depth] = get_inst_data(data{ii}, plotVar);
            
            idx_inst_time_in_ref_time = (inst_time >= (tmin-tbuffer)) & (inst_time <= (tmax+tbuffer));
            %need the largest time diff between ref and each ins as timebase:
            inst_time_diff = nanmedian(diff(inst_time));
            
            for cast = [cast_dn, cast_up]
                idx_inst_time_in_cast_time = (inst_time >= (cast.time(1)-tbuffer)) & (cast.time(end) <= (tmax+tbuffer));
                if ~any(idx_inst_time_in_cast_time)
                    disp(['Unable to match ' instStrTag ' for ' cast.str ' cast']);
                    disp(['  inst time range ' datestr(inst_time(1)) ' to ' datestr(inst_time(end))]);
                    disp(['  ref  time range ' datestr(cast.time(1)) ' to ' datestr(cast.time(end))]);
                    continue;
                end
                
                % inst has faster sampling rate than the reference instrument
                faster_inst_sample = (ref_inst_time_diff >= inst_time_diff);
                % the ref sample occurs fully within inst sample period e.g.
                % 5min ctd cast versus 0.5h WQM sample period
                ref_sample_in_inst_sample = ((cast.time(end)-cast.time(1)) < inst_time_diff);
                do_tbase_swap = faster_inst_sample | ref_sample_in_inst_sample;
                
                if do_tbase_swap
                    % NOTE: not fully tested
                    disp(['Interpolating ' instStrTag ' time base onto reference instrument time base.']);
                    tbase = cast.time;
                    ref_inst_data_tbase = cast.data_raw;
                    ref_inst_depth_tbase = cast.depth;
                    inst_data = interp1(inst_time, inst_data_raw, tbase); %match_timebase(tbase, inst_time, inst_data, {'linear'});
                    if inst_has_depth
                        inst_depth = interp1(inst_time, inst_depth_raw, tbase);
                    else
                        inst_depth = NaN(size(tbase));
                    end
                    iNaN = isnan(ref_inst_data_tbase) & isnan(inst_data);
                    tbase(iNaN) = [];
                    ref_inst_data_tbase(iNaN) = [];
                    ref_inst_depth_tbase(iNaN) = [];
                    inst_data(iNaN) = [];
                    inst_depth(iNaN) = [];
                else
                    tbase = inst_time(idx_inst_time_in_ref_time);
                    inst_data = inst_data_raw(idx_inst_time_in_ref_time);
                    if inst_has_depth
                        inst_depth = inst_depth_raw(idx_inst_time_in_ref_time);
                    else
                        inst_depth = NaN(size(tbase));
                    end
                    disp(['Interpolating reference instrument time base onto ' instStrTag ' time base.']);
                    %%disp(ii)
                    if isempty(tbase)
                        disp(['Unable to match ' instStrTag]);
                        disp(['  inst time range ' datestr(inst_time(1)) ' to ' datestr(inst_time(end))]);
                        disp(['  ref  time range ' datestr(cast.time(1)) ' to ' datestr(cast.time(end))]);
                        rmins(end+1) = ii;
                        continue;
                    elseif numel(tbase) > 2
                        if inst_has_depth
                            ref_inst_depth_tbase = match_timebase(tbase, cast.time, cast.depth, {'linear'});
                            ref_inst_data_tbase = match_timebase(tbase, cast.time, cast.data_raw, {'linear'});
                            iNaN = isnan(ref_inst_depth_tbase) | isnan(ref_inst_data_tbase);
                            if all(iNaN)
                                ref_inst_depth_tbase = interp1(cast.time, cast.depth, tbase, 'nearest', 'extrap');
                                ref_inst_data_tbase = interp1(cast.time, cast.data_raw, tbase, 'nearest', 'extrap');
                                iNaN = isnan(ref_inst_depth_tbase) | isnan(ref_inst_data_tbase);
                            end
                            tbase(iNaN) = [];
                            ref_inst_depth_tbase(iNaN) = [];
                            ref_inst_data_tbase(iNaN) = [];
                            inst_data(iNaN) = [];
                            inst_depth(iNaN) = [];
                        else
                            ref_inst_data_tbase = match_timebase(tbase, cast.time, cast.data_raw, {'linear'});
                            iNaN = isnan(ref_inst_data_tbase) | isnan(inst_data);
                            tbase(iNaN) = [];
                            ref_inst_data_tbase(iNaN) = [];
                            inst_data(iNaN) = [];
                        end
                    else
                        if inst_has_depth
                            index = arrayfun(@(x) near(x-cast.depth, 0.0), inst_depth);
                            ref_inst_data_tbase = cast.data_raw(index);
                            ref_inst_depth_tbase = cast.depth(index);
                        else
                            index = arrayfun(@(x) near(x-cast.time, 0.0), tbase);
                            ref_inst_data_tbase = cast.data_raw(index);
                        end
                    end
                end
                if ~any(ref_inst_data_tbase)
                    disp(['No coincident calibration data for ' refStrTag]);
                    disp(['   Selected data range : ' char(datetime(tbase(1), 'ConvertFrom', 'datenum')) ' - ' char(datetime(tbase(end), 'ConvertFrom', 'datenum'))]);
                    disp(['   Ref Inst data range : ' char(datetime(cast.time(1), 'ConvertFrom', 'datenum')) ' - ' char(datetime(cast.time(end), 'ConvertFrom', 'datenum'))]);
                    %continue;
                end
                
                marker = mrkSymbol{max(mod(ii,numel(mrkSymbol)),1)};
                
                if inst_has_depth
                    % match by depth
                    mm = 2; % axis group index
                    [index, ~] = near(inst_depth-ref_inst_depth_tbase, 0.0, 2);
                    %index3 = cell2mat(arrayfun(@(x) near(abs(x-ref_inst.depth), 0.0, 2), inst_depth, 'UniformOutput', false));
                    match_str = ' (match by depth)';
                    insdat_caldat = nan(size(inst_depth));
                    for jj=1:numel(inst_depth)
                        idx = near(abs(inst_depth(jj)-cast.depth), 0.0, 1);
                        insdat_caldat(jj) = inst_data(jj) - cast.data_raw(idx);
                    end
                else
                    % match by time
                    mm = 1; % axis group index
                    insdat_caldat = inst_data - ref_inst_data_tbase;
                    [index, ~] = near(insdat_caldat, 0.0, 2);
                    match_str = ' (match by time)';
                    inst_depth = match_timebase(tbase, cast.time, cast.depth, {'linear'});
                end
                
                index2 = cell2mat(arrayfun(@(x) near(x-cast.time, 0.0, 2), tbase(index), 'UniformOutput', false));
                
                nn = 1;
                ax = axs(mm, nn);
                hold(ax, 'on');
                haxs{mm,nn}{end+1} = plot(ax, datetime(tbase(index), 'ConvertFrom', 'datenum'), inst_data(index), 'LineStyle', 'none', 'Marker', marker, 'MarkerSize', 10, 'color', cc(ii,:), 'Tag', instStrTag);
                legText{mm,nn}{end+1} = instStrTag;
                
                nn = 2;
                ax = axs(mm, nn);
                hold(ax, 'on');
                %haxs{mm,nn}{end+1} = plot(ax, datetime(ref_inst.time(index2), 'ConvertFrom', 'datenum'), ref_inst.depth(index2), 'LineStyle', 'none', 'Marker', marker, 'MarkerSize', 10, 'color', cc(ii,:), 'Tag', instStrTag);
                if inst_has_depth
                    haxs{mm,nn}{end+1} = plot(ax, datetime(tbase(index), 'ConvertFrom', 'datenum'), inst_depth(index), 'LineStyle', 'none', 'Marker', marker, 'MarkerSize', 10, 'color', cc(ii,:), 'Tag', instStrTag);
                else
                    haxs{mm,nn}{end+1} = plot(ax, datetime(cast.time(index2), 'ConvertFrom', 'datenum'), cast.depth(index2), 'LineStyle', 'none', 'Marker', marker, 'MarkerSize', 10, 'color', cc(ii,:), 'Tag', instStrTag);
                end
                legText{mm,nn}{end+1} = instStrTag;
                
                nn = 3;
                ax = axs(mm, nn);
                hold(ax, 'on');
                haxs{mm,nn}{end+1} = plot(ax, inst_data(index), inst_depth(index), 'LineStyle', 'none', 'Marker', marker, 'MarkerSize', 10, 'color', cc(ii,:), 'Tag', instStrTag);
                legText{mm,nn}{end+1} = instStrTag;
                
                nn = 4;
                ax = axs(mm, nn);
                hold(ax, 'on');
                haxs{mm,nn}{end+1} = plot(ax, datetime(tbase(index), 'ConvertFrom', 'datenum'), insdat_caldat(index), 'LineStyle', '-', 'Marker', marker, 'MarkerSize', 10, 'color', cc(ii,:), 'Tag', instStrTag);
                legText{mm,nn}{end+1} = instStrTag;
                
                disp(instStrTag)
                for jj = 1:numel(index)
                    indx = index(jj);
                    disp([datestr(tbase(indx)) ' Inst: ' num2str(inst_data(indx),'%10.6f') ' Ref: ' num2str(ref_inst_data_tbase(indx),'%10.6f') ' Diff: ' num2str(insdat_caldat(indx),'%10.6f') match_str ' ' cast.str]);
                end
            end
            disp(' ');
        end
        disp(' ');
        
        % remove instrument names of plots that weren't created
        dinstShortnameSerial(rmins) = [];
        dinstShortnameSerialFilename(rmins) = [];
        dinstModels(rmins) = [];
        
        f1.Visible = 'on';
        trange = [tmin-tbuffer/2; tmax+tbuffer/2];
        
        mm = 1;
        nn = 1;
        ax = axs(mm, nn);
        grid(ax, 'on');
        h = haxs{mm,nn};
        htags = cellfun(@(x) x.Tag, h, 'UniformOutput', false);
        [uhtags, IA, IC] = unique(htags, 'stable');
        hh = h(IA);
        hh_legText1 = legText{mm,nn};
        hh_legText1 = hh_legText1(IA);
        lh1 = legend([hh{:}], hh_legText1);
        title(ax, makeTexSafe({['CTD compared to instruments without pressure sensor : ' plotVar], 'matching by nearest time'}));
        ax.XLim = datetime(trange, 'ConvertFrom', 'datenum');
        
        mm = 1;
        nn = 2;
        ax = axs(mm, nn);
        grid(ax, 'on');
        ax.XLim = datetime(trange, 'ConvertFrom', 'datenum');
        
        mm = 2;
        nn = 1;
        ax = axs(mm, nn);
        grid(ax, 'on');
        h = haxs{mm,nn};
        htags = cellfun(@(x) x.Tag, h, 'UniformOutput', false);
        [uhtags, IA, IC] = unique(htags, 'stable');
        hh = h(IA);
        hh_legText2 = legText{mm,nn};
        hh_legText2 = hh_legText2(IA);
        lh2 = legend([hh{:}], hh_legText2);
        title(ax, makeTexSafe({['CTD compared to instruments with a pressure sensor : ' plotVar], 'matching by nearest CTD EP_DEPTH'}));
        ax.XLim = datetime(trange, 'ConvertFrom', 'datenum');
        
        mm = 2;
        nn = 2;
        ax = axs(mm, nn);
        grid(ax, 'on');
        ax.XLim = datetime(trange, 'ConvertFrom', 'datenum');
        
        mm = 1;
        nn = 3;
        ax = axs(mm, nn);
        grid(ax, 'on');
        
        mm = 2;
        nn = 3;
        ax = axs(mm, nn);
        grid(ax, 'on');
        
        mm = 1;
        nn = 4;
        ax = axs(mm, nn);
        grid(ax, 'on');
        ax.XLim = datetime(trange, 'ConvertFrom', 'datenum');
        
        mm = 2;
        nn = 4;
        ax = axs(mm, nn);
        grid(ax, 'on');
        ax.XLim = datetime(trange, 'ConvertFrom', 'datenum');
        
        % nn = 5 subplot purely used to display a legend for previous plots
        % so as not to obscure them. So create fake plot and copy legend
        % entries
        mm = 1;
        nn = 5;
        ax = axs(mm, nn);
        for ii=1:numel(haxs{1,1})
            h = haxs{1,1}{ii};
            ph(ii) = plot(ax, 1, nan, 'Marker', h.Marker, 'MarkerSize', h.MarkerSize, 'LineStyle', h.LineStyle, 'LineWidth', h.LineWidth, 'Color', h.Color, 'Tag', h.Tag)    ;
        end
        % get unique legend entries and reuse legend text from first plot
        htags = arrayfun(@(x) x.Tag, ph, 'UniformOutput', false);
        [uhtags, IA, IC] = unique(htags, 'stable');
        hh = ph(IA);
        hh1 = legend(hh, hh_legText1, 'location', 'northwest');
        drawnow();
        set(ax, 'Visible', 'off');
        lh1.Visible = 'off';
        
        % nn = 5 subplot purely used to display a legend for previous plots
        % so as not to obscure them. So create fake plot and copy legend
        % entries
        mm = 2;
        nn = 5;
        ax = axs(mm, nn);
        for ii=1:numel(haxs{2,1})
            h = haxs{2,1}{ii};
            ph(ii) = plot(ax, 1, nan, 'Marker', h.Marker, 'MarkerSize', h.MarkerSize, 'LineStyle', h.LineStyle, 'LineWidth', h.LineWidth, 'Color', h.Color, 'Tag', h.Tag)    ;
        end
        % get unique legend entries and reuse legend text from first plot
        htags = arrayfun(@(x) x.Tag, ph, 'UniformOutput', false);
        [uhtags, IA, IC] = unique(htags, 'stable');
        hh = ph(IA);
        hh2 = legend(hh, hh_legText2, 'location', 'northwest');
        drawnow();
        set(ax, 'Visible', 'off');
        lh2.Visible = 'off';
        
        linkaxes([axs(1, 1), axs(1, 2), axs(1, 4), axs(2, 1), axs(2, 2), axs(2, 4)], 'x');
        linkaxes([axs(1, 1), axs(2, 1)], 'y');
        linkaxes([axs(1, 2), axs(2, 2), axs(1, 3), axs(2, 3)], 'y');
        linkaxes([axs(1, 4), axs(2, 4)], 'y');
        %linkaxes([axs(1, 1), axs(1, 2), axs(1, 4), axs(2, 1), axs(2, 2), axs(2, 4)], 'x');
        linkaxes([axs(1, 1), axs(1, 2), axs(2, 1), axs(2, 2)], 'x');
        
    end

%%
    function [refinst_time, refinst_data, refinst_depth] = get_refinst_data(refinst_sam, plotVar)
        
        idPlotVar = getVar(refinst_sam.variables, plotVar);
        refinst_data = refinst_sam.variables{idPlotVar}.data;
        
        idTime  = getVar(refinst_sam.dimensions, 'TIME');
        refinst_time = getXdata(refinst_sam.dimensions{idTime});
        
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
        
        %         % try to keep only down/up cast data
        %         ctd_in_water = refinst_depth < -2;
        %         refinst_time(~ctd_in_water) = [];
        %         refinst_data(~ctd_in_water) = [];
        %         refinst_depth(~ctd_in_water) = [];
        
        % smooth data and obtain index to deepest point in the cast
        new_ref_inst_depth_lpf = ezsmoothn(refinst_depth);
        [~, ind_min_depth] = min(new_ref_inst_depth_lpf, [], 'omitnan');
        ind1 = find(new_ref_inst_depth_lpf(1:ind_min_depth) > -3.0, 1, 'last');
        ind2 = find(new_ref_inst_depth_lpf(ind_min_depth:end) > -3.0, 1, 'first') + ind_min_depth - 1;
        
        % Extend out indexes by 5 seconds, more to help visual
        % confirmation that have complete down/up case data
        % If this one day starts looking messy consider commenting out
        % these lines
        tbuffer = 5/60/60/24;
        if isempty(ind1)
            ind1 = 1; 
        else
            [ind1, ~] = near(refinst_time, refinst_time(ind1)-tbuffer, 1);
        end

        if isempty(ind2)
            ind2 = numel(refinst_time);
        else
            [ind2, ~] = near(refinst_time, refinst_time(ind2)+tbuffer, 1);
        end
        
        % keep only down/up cast data
        refinst_time = refinst_time(ind1:ind2);
        refinst_data = refinst_data(ind1:ind2);
        refinst_depth = refinst_depth(ind1:ind2);
    end

%%
    function [inst_time, inst_data, inst_depth, inst_has_depth] = get_inst_data(sam, plotVar)
        idTime  = getVar(sam.dimensions, 'TIME');
        inst_time = getXdata(sam.dimensions{idTime});
        
        idPlotVar = getVar(sam.variables, plotVar);
        inst_data = sam.variables{idPlotVar}.data;
        
        % workaround any non-monotonic time issues
        [~, indx] = unique(inst_time);
        inst_time = inst_time(indx);
        inst_data = inst_data(indx);
        
        inst_has_depth = false;
        idDEPTH  = getVar(sam.variables, 'EP_DEPTH');
        depth_conversion = 1;
        if idDEPTH == 0
            idDEPTH  = getVar(sam.variables, 'DEPTH');
            depth_conversion = -1;
        end
        if idDEPTH ~= 0
            inst_has_depth = true;
        end
        
        if inst_has_depth
            inst_depth = depth_conversion * sam.variables{idDEPTH}.data;
            inst_depth = inst_depth(indx); % workaround any non-monotonic time issues
            idx_inst_in_water = inst_depth < 0;
            if any(idx_inst_in_water)
                inst_time(~idx_inst_in_water) = [];
                inst_depth(~idx_inst_in_water) = [];
                inst_data(~idx_inst_in_water) = [];
            else
                % something is wrong here, maybe you have added pressure to
                % an instrument that doesn't have a pressure sensor
                inst_depth = nan(size(sam.variables{idDEPTH}.data));
                inst_has_depth = false;
            end
        else
            inst_depth = nan(size(inst_time));
        end
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

