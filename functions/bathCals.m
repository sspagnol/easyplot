function bathCals(userData)
% BATHCALS plot the bath calibration information from the post-retrieval on board
% calibration bath.
%
% Return plots of the difference from the reference SBE unit and a table of
% means and standard deviations over the period selected.
%
% Inputs:
%       userData  contains all the data relevant to the instruments
%                   loaded
%
% Rebecca Cowley <rebecca.cowley@csiro.au>
% October, 2015
%
% Simon Spagnol <s.spagnol@aims.gov.au>

hg2flag = ~verLessThan('matlab', '8.4.0');

%
plotVar = char(userData.plotVarNames);

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

%create the dialog box, get index into  sample_data of reference
%instrument
[refinst, ok] = listdlg('PromptString','Choose the reference instrument',...
    'SelectionMode','single',...
    'ListSize', [400,250],...
    'ListString',instShortnameSerialFilename,...
    'Name', 'Reference instrument');

if ok == 0 % no instrument chosen
    return;
end

userData.refInst = refinst;
%reset instList so that it doesn't include the reference instrument
instShortnameSerial(refinst) = [];
instShortnameSerialFilename(refinst) = [];
instModels(refinst) = [];
iSet(refinst) = [];

%ref instrument chosen, now ask to select the instruments that were in the
%bath:
%make another input box:
f = figure(...
    'Name',        'Select the Bath Calibrated Instruments',...
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

%now we know which instruments are in the cal bath ('sets').
% and we know the time range for checking the offsets (calx,caly)
% and we know the reference unit ('refinst').
plotcals(userData);

%%
    function plotcals(userData)
        % PLOTCALS plot instrument data against a reference data set
        %
        % now put them onto the same timebase to compare the temp offsets:
        %
        % Original code from Rebecca Cowley (O&A, Hobart) <Rebecca.Cowley@csiro.au>
        
        ref = userData.sample_data{refinst};
        refStrTag = strcat(plotVar, '-', ref.meta.EP_instrument_model_shortname, '-', ref.meta.EP_instrument_serial_no_deployment);
        refStrTag = regexprep(refStrTag, '[^ -~]', '-');
        refData = ref.variables{ref.EP_variablePlotStatus>0}.data;
        refTime = ref.dimensions{1}.data;
        refTimeDiff = nanmedian(diff(refTime));
        tmin1 = userData.calx(1);
        tmax1 = userData.calx(2);
        if isdatetime(tmin1)
            tmin1 = datenum(tmin1);
            tmax1 = datenum(tmax1);
        end        
		igRef1 = refTime >= tmin1 & refTime <= tmax1;
        if sum(igRef1) == 0
           warning('No coincident calibration data for selected period.');
           return
        end
        if isfield(userData,'calx2')
            tmin2 = userData.calx2(1);
            tmax2 = userData.calx2(2);
            if isdatetime(tmin2)
                tmin2 = datenum(tmin2);
                tmax2 = datenum(tmax2);
            end
            igRef2 = refTime >= tmin2 & refTime <= tmax2;
        end
        
        data = userData.sample_data;
        data(refinst) = []; % remove reference instrument
        data = data(iSet); % keep only user selected instruments

        dinstShortnameSerial = instShortnameSerial(iSet);
        dinstShortnameSerialFilename = instShortnameSerialFilename(iSet);
        dinstModels = instModels(iSet);
        udinstModels = unique(dinstModels, 'stable');
        
        % plot test tank data by time:
        f1 = figure('visible', 'off');
        clf;
        ax1 = axes(f1);
        hold('on');
        dcm_h = datacursormode(f1);
        set(dcm_h, 'UpdateFcn', @customDatacursorText)

        
        % plot difference to reference instrument coloured by instrument type
        f2 = figure('visible', 'off');
        clf;
        ax2 = axes(f2);
        hold('on');
        dcm_h = datacursormode(f2);
        set(dcm_h, 'UpdateFcn', @customDatacursorText)
        
        % plot difference to reference instrument by time:
        f3 = figure('visible', 'off');
        clf;
        ax3 = axes(f3);
        hold('on');
        dcm_h = datacursormode(f3);
        set(dcm_h, 'UpdateFcn', @customDatacursorText)
      
        cc = parula(numel(data));
        cb = parula(size(udinstModels,1));
        clear('h');
        clear('h2');
        mrkSymbol = {'+','o','*','.','x','s','d','^','>','<','p','h','+','o'};
        rmins = [];

        % handles of plot that potentially be created
        if hg2flag
            h1 = gobjects(size(data));
            h2 = gobjects(size(data));
            hh1 = gobjects(size(data));
            hh2 = gobjects(size(data));
        else
            h1 = NaN(size(data));
            h2 = NaN(size(data));
            hh1 = NaN(size(data));
            hh2 = NaN(size(data));
        end
        
        disp(['| Instrument | Date Range | ' plotVar ' Mean(Inst - Cal Inst) |']);
        disp('| --- | --- | --- |');
        for ii = 1:numel(data)
            %disp([data{ii}.meta.instrument_model ' ' data{ii}.meta.instrument_serial_no]);
            instStrTag = strcat(plotVar, '-', data{ii}.meta.EP_instrument_model_shortname, '-', data{ii}.meta.EP_instrument_serial_no_deployment);
            instStrTag = regexprep(instStrTag, '[^ -~]', '-'); %only printable ascii characters
        
            instTime = data{ii}.dimensions{1}.data;
            if ~any(data{ii}.EP_variablePlotStatus>0), continue; end
            instData = data{ii}.variables{data{ii}.EP_variablePlotStatus>0}.data;
            igIns1 = (instTime >= tmin1) & (instTime <= tmax1);
            if isfield(userData, 'calx2')
                igIns2 = (instTime >= tmin2) & (instTime <= tmax2);
            end
            if sum(igIns1) > 5
                %need the largest time diff between ref and each ins as timebase:
                insdif = nanmedian(diff(instTime));
                if refTimeDiff >= insdif
                    tbase = refTime(igRef1);
                    caldat = refData(igRef1);
                    insdat = match_timebase(tbase, instTime(igIns1), instData(igIns1));
                    iNaN = isnan(caldat) & isnan(insdat);
                    tbase(iNaN) = [];
                    caldat(iNaN) = [];
                    insdat(iNaN) = [];
                    if isfield(userData, 'calx2')
                        tbase2 = refTime(igRef2);
                        caldat2 = refData(igRef2);
                        insdat2 = match_timebase(tbase2, instTime(igIns2), instData(igIns2));
                    end
                else
                    tbase = instTime(igIns1);
                    insdat = instData(igIns1);
                    caldat = match_timebase(tbase, refTime(igRef1), refData(igRef1));
                    iNaN = isnan(caldat) & isnan(insdat);
                    tbase(iNaN) = [];
                    caldat(iNaN) = [];
                    insdat(iNaN) = [];
                    if isfield(userData,'calx2')
                        tbase2 = instTime(igIns2);
                        insdat2 = instData(igIns2);
                        caldat2 = match_timebase(tbase2, refTime(igRef2), refData(igRef2));
                    end
                end
                
                if ~any(caldat)
                   disp(['No coincident calibration data for ' refStrTag]);
                   disp(['   Selected data range : ' char(datetime(tbase(1), 'ConvertFrom', 'datenum')) ' - ' char(datetime(tbase(end), 'ConvertFrom', 'datenum'))]);
                   disp(['   Ref Inst data range : ' char(datetime(refTime(1), 'ConvertFrom', 'datenum')) ' - ' char(datetime(refTime(end), 'ConvertFrom', 'datenum'))]);
                   %continue;
                end
                %plot only the regions of comparison
                %axes(ax1);
                hold(ax1, 'on');
                if ii == 1
                    h1(ii) = plot(ax1, datetime(tbase, 'ConvertFrom', 'datenum'), caldat, 'kx-', 'linewidth', 2, 'Tag', refStrTag);
                end
                h1(ii) = plot(ax1, datetime(tbase, 'ConvertFrom', 'datenum'), insdat, 'x-', 'color', cc(ii,:), 'Tag', instStrTag);
                
                if isfield(userData,'calx2')
                    if ii == 1
                        h2(ii) = plot(ax1, datetime(tbase2, 'ConvertFrom', 'datenum'), caldat2, 'kx-', 'linewidth', 2);
                    end
                    h2(ii) = plot(ax1, datetime(tbase2, 'ConvertFrom', 'datenum'), insdat2, 'x-', 'color', cc(ii,:), 'Tag', instStrTag);
                end
                
                %plot differences by instrument type
                %axes(ax2);
                hold(ax2, 'on');
                ik = find(strcmp(dinstModels{ii}, udinstModels));
                hh1(ii) = plot(ax2, caldat, insdat-caldat, 'Marker',mrkSymbol{ik}, 'Color', cb(ik,:), 'DisplayName', udinstModels{ik}, 'Tag', instStrTag);
                XData = get(hh1(ii), 'XData');
                YData = get(hh1(ii), 'YData');
                iend = find(~isnan(XData) & ~isnan(YData), 1, 'last');
                istart = find(~isnan(XData) & ~isnan(YData), 1, 'first');
                text(ax2, double(XData(iend)),double(YData(iend)),...
                    data{ii}.meta.instrument_serial_no); %iu{ik}); %
 
                %plot difference to ref inst
                %axes(ax3);
                hold(ax3, 'on');
                plot(ax3, datetime(tbase, 'ConvertFrom', 'datenum'), insdat-caldat, 'x-', 'color', cc(ii,:), 'Tag', instStrTag);
                if isfield(userData,'calx2')
                    plot(ax3, datetime(tbase2, 'ConvertFrom', 'datenum'), insdat2-caldat2, 'x-', 'color', cc(ii,:), 'Tag', instStrTag);
                end
                
                diffdat = insdat-caldat;
                STATS = statistic(diffdat);
                inststr = [data{ii}.meta.instrument_make '-' data{ii}.meta.instrument_model '-' data{ii}.meta.instrument_serial_no];
                str = ['| ' inststr ' | ' datestr(tbase(istart)) ' -- ' datestr(tbase(iend)) ' | ' num2str(STATS.MEAN) ' |'];
                disp(str);
                if isfield(userData,'calx2')
                    hh2(ii) = plot(ax2, caldat2,insdat2-caldat2, 'Marker',mrkSymbol{ik}, 'Color',cb(ik,:), 'DisplayName', udinstModels{ik});
                    XData = get(hh2(ii), 'XData');
                    YData = get(hh2(ii), 'YData');
                    iend = find(~isnan(XData) & ~isnan(YData), 1, 'last');
                    istart = find(~isnan(XData) & ~isnan(YData), 1, 'first');
                    text(ax2, double(XData(iend)),double(YData(iend)),...
                        data{ii}.meta.instrument_serial_no); %iu{ik}); %
                    diffdat = insdat2-caldat2;
                    STATS = statistic(diffdat);
                    str = ['| ' inststr ' | ' datestr(tbase2(istart)) ' -- ' datestr(tbase2(iend)) ' | ' num2str(STATS.MEAN) ' |'];
                    disp(str);
                end
            else
                rmins = [rmins; ii];
            end
        end
        disp(' ');
        
        % remove handles of plots that weren't created (indicated by NaN)
        h1(rmins) = [];
        h2(rmins) = [];
        hh1(rmins) = [];
        hh2(rmins) = [];
        dinstShortnameSerial(rmins) = [];
        dinstShortnameSerialFilename(rmins) = [];
        dinstModels(rmins) = [];
        
        if exist('h1','var')
            %figure(f1);
            f1.Visible = 'on';
            legText = dinstShortnameSerial;
            grid(ax1, 'on');
            xlabel(ax1, 'Time');
            ylabel(ax1, makeTexSafe(plotVar));
            legend(ax1, legText);
            title(ax1, makeTexSafe(['Test tank ' plotVar]));
            
            %figure(f2);
            f2.Visible = 'on';
            legText = dinstModels;
            %legText(rmins) = [];
            [legText, IA, IC] = unique(legText);
            legend(ax2, hh1(IA));
            title(ax2, makeTexSafe(['Test tank ' plotVar ' offsets from reference instrument']));
            xlabel(ax2, makeTexSafe(['Bath ' plotVar]));
            ylabel(ax2, makeTexSafe([plotVar ' offset']));
            grid(ax2, 'on');
  
            %figure(f3);
            f3.Visible = 'on';
            legText = dinstShortnameSerial;
            grid(ax3, 'on');
            xlabel(ax3, 'Time');
            ylabel(ax3, makeTexSafe([plotVar ' offset']));
            legend(ax3, legText);
            title(ax3, makeTexSafe(['Test tank ' plotVar ' offsets from reference instrument']));
        end
    end


    function keyPressCallback(source,ev)
        %KEYPRESSCALLBACK If the user pushes escape/return while the dialog has
        % focus, the dialog is cancelled/confirmed. This is done by delegating
        % to the cancelCallback/confirmCallback functions.
        %
        if     strcmp(ev.Key, 'escape'), cancelCallback( source,ev);
        elseif strcmp(ev.Key, 'return'), confirmCallback(source,ev);
        end
    end

    function cancelCallback(source,ev)
        %CANCELCALLBACK Cancel button callback. Discards user input and closes the
        % dialog .
        %
        iSet(:)    = false;
        delete(f);
    end

    function confirmCallback(source,ev)
        %CONFIRMCALLBACK. Confirm button callback. Closes the dialog.
        %
        delete(f);
    end

    function checkboxCallback(source, ev)
        %CHECKBOXCALLBACK Called when a checkbox selection is changed.
        %
        idx = get(source, 'UserData');
        val = get(source, 'Value');
        
        iSet(idx) = logical(val);
    end

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
        datacursorText{end+1} = ['Inst: ', eventdata.Target.Tag];
    end

end

