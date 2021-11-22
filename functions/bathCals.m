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
[refinst,ok] = listdlg('PromptString','Choose the reference instrument',...
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
        %PLOTCALS plot the bath calibration data as a comparison
        %return the handle to the figure, h
        % now put them onto the same timebase to compare the temp offsets:
        %use the cal bath interval:
        
        ref = userData.sample_data{refinst};
        refTemp = ref.variables{ref.EP_variablePlotStatus>0}.data;
        refTime = ref.dimensions{1}.data;
        refTimeDiff = nanmedian(diff(refTime));
        tmin1 = userData.calx(1);
        tmax1 = userData.calx(2);
        if isdatetime(tmin1)
            tmin1 = datenum(tmin1);
            tmax1 = datenum(tmax1);
        end        
		igRef1 = refTime >= tmin1 & refTime <= tmax1;
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
        
        %plot calibration data for all temperature ranges by time:
        f1 = figure;
        clf;
        hold('on');
        
        %plot difference to reference instrument coloured by instrument type:
        f2 = figure;
        clf;
        hold('on');
        
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
            instTime = data{ii}.dimensions{1}.data;
            if ~any(data{ii}.EP_variablePlotStatus>0), continue; end
            instTemp = data{ii}.variables{data{ii}.EP_variablePlotStatus>0}.data;
            igIns1 = (instTime >= tmin1) & (instTime <= tmax1);
            if isfield(userData, 'calx2')
                igIns2 = (instTime >= tmin2) & (instTime <= tmax2);
            end
            if sum(igIns1) > 5
                %need the largest time diff between ref and each ins as timebase:
                insdif = nanmedian(diff(instTime));
                if refTimeDiff >= insdif
                    tbase = refTime(igRef1);
                    caldat = refTemp(igRef1);
                    insdat = match_timebase(tbase,instTime(igIns1),instTemp(igIns1));
                    if isfield(userData, 'calx2')
                        tbase2 = refTime(igRef2);
                        caldat2 = refTemp(igRef2);
                        insdat2 = match_timebase(tbase2,instTime(igIns2),instTemp(igIns2));
                    end
                else
                    tbase = instTime(igIns1);
                    insdat = instTemp(igIns1);
                    caldat = match_timebase(tbase,refTime(igRef1),refTemp(igRef1));
                    if isfield(userData,'calx2')
                        tbase2 = instTime(igIns2);
                        insdat2 = instTemp(igIns2);
                        caldat2 = match_timebase(tbase2,refTime(igRef2),refTemp(igRef2));
                    end
                end
                
                %plot only the regions of comparison
                figure(f1);
                if ii == 1
                    h1(ii) = plot(datetime(tbase, 'ConvertFrom', 'datenum'), caldat,'kx-', 'linewidth',2);
                end
                h1(ii) = plot(datetime(tbase, 'ConvertFrom', 'datenum'), insdat,'x-','color',cc(ii,:));
                
                if isfield(userData,'calx2')
                    if ii == 1
                        h2(ii) = plot(datetime(tbase2, 'ConvertFrom', 'datenum'), caldat2, 'kx-', 'linewidth',2);
                    end
                    h2(ii) = plot(datetime(tbase2, 'ConvertFrom', 'datenum'), insdat2, 'x-', 'color', cc(ii,:));
                end
                
                %plot differences by instrument type
                figure(f2);
                ik = find(strcmp(dinstModels{ii}, udinstModels));
                hh1(ii) = plot(caldat,insdat-caldat, 'Marker',mrkSymbol{ik}, 'Color',cb(ik,:), 'DisplayName', udinstModels{ik});
                XData = get(hh1(ii), 'XData');
                YData = get(hh1(ii), 'YData');
                iend = find(~isnan(XData) & ~isnan(YData), 1, 'last');
                istart = find(~isnan(XData) & ~isnan(YData), 1, 'first');
                text(double(XData(iend)),double(YData(iend)),...
                    data{ii}.meta.instrument_serial_no); %iu{ik}); %
                diffdat = insdat-caldat;
                STATS = statistic(diffdat);
                inststr = [data{ii}.meta.instrument_make '-' data{ii}.meta.instrument_model '-' data{ii}.meta.instrument_serial_no];
                str = ['| ' inststr ' | ' datestr(tbase(istart)) ' -- ' datestr(tbase(iend)) ' | ' num2str(STATS.MEAN) ' |'];
                disp(str);
                if isfield(userData,'calx2')
                    hh2(ii) = plot(caldat2,insdat2-caldat2, 'Marker',mrkSymbol{ik}, 'Color',cb(ik,:), 'DisplayName', udinstModels{ik});
                    XData = get(hh2(ii), 'XData');
                    YData = get(hh2(ii), 'YData');
                    iend = find(~isnan(XData) & ~isnan(YData), 1, 'last');
                    istart = find(~isnan(XData) & ~isnan(YData), 1, 'first');
                    text(double(XData(iend)),double(YData(iend)),...
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
            figure(f1);
            legText = dinstShortnameSerial;
            %legText(rmins) = [];
            grid('on');
            xlabel('Time');
            ylabel(makeTexSafe(plotVar));
            %datetick;
            legend(h1,legText);
            title('Bath Calibrations');
            
            figure(f2);
            legText = dinstModels;
            %legText(rmins) = [];
            [legText, IA, IC] = unique(legText);
            legend(hh1(IA));
            title(makeTexSafe(['Calibration bath ' plotVar ' offsets from reference instrument']));
            xlabel(makeTexSafe(['Bath ' plotVar]));
            ylabel(makeTexSafe([plotVar ' offset']));
            grid('on');
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

end

