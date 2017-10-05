%%
function plotData(hObject)
%PLOTDATA plot marked variables in sample_data
%
% Inputs:
%   hObject - handle to figure

% set re-entrancy flag
persistent hash;
if isempty(hash)
    hash = java.util.Hashtable;
end
if ~isempty(hash.get(hObject))
    return;
end
hash.put(hObject,1);
if isempty(hObject), return; end

hFig = ancestor(hObject,'figure');
if isempty(hFig), return; end

userData = getappdata(hFig, 'UserData');
if isempty(userData.sample_data), return; end

% retrieve good flag values
qcSet     = str2double(readProperty('toolbox.qc_set'));
rawFlag   = imosQCFlag('raw', qcSet, 'flag');
goodFlag  = imosQCFlag('good', qcSet, 'flag');
%pGoodFlag = imosQCFlag('probablyGood', qcSet, 'flag');
goodFlags = [rawFlag, goodFlag]; %, pGoodFlag];

figure(hFig); %make figure current
gData = guidata(hFig);

%% testing number of subplots calculation
% VARS_OVERLAY : one plot with all vars
% VARS_STACKED : subplots with common vars per subplot
% VARS_SINGLE : subplot per var, not implemented yet
% for each marked variable assign it an subplot/axis number
switch upper(userData.plotType)
    case 'VARS_OVERLAY'
        %userData.plotVarNames
        nSubPlots = 1;
        for ii=1:numel(userData.sample_data) % loop over files
            userData.sample_data{ii}.axisIndex = zeros(size(userData.sample_data{ii}.plotThisVar));
            iVars = find(userData.sample_data{ii}.plotThisVar)';
            %markedVarNames = arrayfun(@(x) userData.sample_data{ii}.variables{x}.name, iVars, 'UniformOutput', false);
            userData.sample_data{ii}.axisIndex(iVars) = 1;
        end
        
    case 'VARS_STACKED'
        %userData.plotVarNames
        nSubPlots = numel(userData.plotVarNames);
        for ii=1:numel(userData.sample_data) % loop over files
            userData.sample_data{ii}.axisIndex = zeros(size(userData.sample_data{ii}.plotThisVar));
            iVars = find(userData.sample_data{ii}.plotThisVar)';
            markedVarNames = arrayfun(@(x) userData.sample_data{ii}.variables{x}.name, iVars, 'UniformOutput', false);
            userData.sample_data{ii}.axisIndex(iVars) = cell2mat(arrayfun(@(x) find(strcmp(x,userData.plotVarNames)), markedVarNames, 'UniformOutput', false));
        end
        
    otherwise
        disp('help');
end


%% determine QC use
try
    useQCflags = userData.plotQC;
catch
    useQCflags = false;
end
useFlags = 'RAW';
if useQCflags, useFlags='QC'; end

%% create list of variable names that will be plotted
varNames={};
for ii=1:numel(userData.sample_data)
    iVars = find(userData.sample_data{ii}.plotThisVar)';
    for jj = iVars
        theVar = userData.sample_data{ii}.variables{jj}.name;
        varNames{end+1}=theVar;
    end
end
varNames=unique(varNames);
userData.dataLimits=findVarExtents(userData.sample_data, varNames);

%% Create a string for legend
legendStr={};

%% delete old plots
children = findobj(gData.plotPanel,'Type','axes');
if ~isempty(children)
    xlimits = get(children(1), 'XLim');
    userData.plotLimits.TIME.xMin = xlimits(1);
    userData.plotLimits.TIME.xMax = xlimits(2);
    delete(children);
end

%%
% loop over sample_data and plot the marked variables into previously
% calculated subplot/axis number
%varNames={};
hAx=gobjects(nSubPlots,1);
legendStr = cell(nSubPlots,1);
for ii=1:numel(userData.sample_data)
    iVars = find(userData.sample_data{ii}.plotThisVar)';
    for jj = iVars
        theVar = userData.sample_data{ii}.variables{jj}.name;
        ihAx = userData.sample_data{ii}.axisIndex(jj);
        hAx(ihAx) = subplot(nSubPlots,1,ihAx,'Parent',gData.plotPanel);
        %hAx(ihAx) = subplot_tight(nSubPlots,1,ihAx,[0.02 0.02],'Parent',gData.plotPanel);
        %axes(hAx(ihAx));
        % for each subplot set a tag and xlim/ylim
        switch upper(userData.plotType)
            case 'VARS_OVERLAY'
                hAx(ihAx).Tag = 'MULTI';
                if isfield(userData.plotLimits, 'TIME') & isfinite(userData.plotLimits.TIME.xMin) & isfinite(userData.plotLimits.TIME.xMax)
                    set(hAx(ihAx),'XLim',[userData.plotLimits.TIME.xMin userData.plotLimits.TIME.xMax]);
                else
                    set(hAx(ihAx),'XLim',[userData.dataLimits.TIME.RAW.xMin userData.dataLimits.TIME.RAW.xMax]);
                end
                if ~isfield(userData.plotLimits, 'MULTI')
                    userData.plotLimits.MULTI.yMin = userData.dataLimits.MULTI.(useFlags).yMin;
                    userData.plotLimits.MULTI.yMax = userData.dataLimits.MULTI.(useFlags).yMax;
                end
                
            case 'VARS_STACKED'
                hAx(ihAx).Tag = theVar;
                if isfield(userData.plotLimits, 'TIME') & isfinite(userData.plotLimits.TIME.xMin) & isfinite(userData.plotLimits.TIME.xMax)
                    set(hAx(ihAx),'XLim',[userData.plotLimits.TIME.xMin userData.plotLimits.TIME.xMax]);
                else
                    set(hAx(ihAx),'XLim',[userData.dataLimits.TIME.RAW.xMin userData.dataLimits.TIME.RAW.xMax]);
                end
                if ~isfield(userData.plotLimits, theVar)
                    userData.plotLimits.(theVar).yMin = userData.dataLimits.(theVar).(useFlags).yMin;
                    userData.plotLimits.(theVar).yMax = userData.dataLimits.(theVar).(useFlags).yMax;
                end
                set(hAx(ihAx),'YLim',[userData.plotLimits.(theVar).yMin userData.plotLimits.(theVar).yMax]);
        end
        
        if strcmp(userData.sample_data{ii}.variables{jj}.name,'EP_TIMEDIFF')
            lineStyle='none';
            markerStyle='.';
        else
            lineStyle='-';
            markerStyle='none';
        end
        
        if strfind(theVar, 'EP_LPF')
            idTime  = getVar(userData.sample_data{ii}.dimensions, 'LPFTIME');
        else
            idTime  = getVar(userData.sample_data{ii}.dimensions, 'TIME');
        end
        
        instStr=strcat(theVar, '-',userData.sample_data{ii}.meta.instrument_model,'-',userData.sample_data{ii}.meta.instrument_serial_no);
        %disp(['Size : ' num2str(size(handles.sample_data{ii}.variables{jj}.data))]);
        %[PATHSTR,NAME,EXT] = fileparts(userData.sample_data{ii}.toolbox_input_file);
        tagStr = [userData.sample_data{ii}.inputFile userData.sample_data{ii}.inputFileExt];
        try
            if isvector(userData.sample_data{ii}.variables{jj}.data)
                % 1D var
                ydataVar = userData.sample_data{ii}.variables{jj}.data;
                if useQCflags & isfield(userData.sample_data{ii}.variables{jj}, 'flags')
                    varFlags = userData.sample_data{ii}.variables{jj}.flags;
                    iGood = ismember(varFlags, goodFlags);
                    ydataVar(~iGood) = NaN;
                end
                line('Parent',hAx(ihAx),'XData',userData.sample_data{ii}.dimensions{idTime}.data, ...
                    'YData',ydataVar, ...
                    'LineStyle',lineStyle, 'Marker', markerStyle,...
                    'DisplayName', instStr, 'Tag', instStr);
            else
                % 2D var
                iSlice = userData.sample_data{ii}.variables{jj}.iSlice;
                ydataVar = userData.sample_data{ii}.variables{jj}.data(:,iSlice);
                if useQCflags & isfield(userData.sample_data{ii}.variables{jj}, 'flags')
                    varFlags = userData.sample_data{ii}.variables{jj}.flags(:,iSlice);
                    iGood = ismember(varFlags, goodFlags);
                    ydataVar(~iGood) = NaN;
                end
                line('Parent',hAx(ihAx),'XData',userData.sample_data{ii}.dimensions{idTime}.data, ...
                    'YData',ydataVar, ...
                    'LineStyle',lineStyle, 'Marker', markerStyle,...
                    'DisplayName', instStr, 'Tag', instStr);
            end
        catch
            error('PLOTDATA: plot failed.');
        end
        hold(hAx(ihAx),'on');
        legendStr{ihAx}{end+1}=strrep(instStr,'_','\_');
        %varNames{end+1}=theVar;
        set(gData.progress,'String',strcat('Plot : ', instStr));
        %setappdata(ancestor(hObject,'figure'), 'UserData', userData);
        %drawnow;
    end
end

%% link all/any subplot axes
linkaxes(hAx,'x');

%% set ylabels and legends
for ii = 1:nSubPlots
    if isempty(varNames)
        ylabel(hAx(ii),'No Variables');
        %    elseif numel(varNames)==1
    else
        switch upper(userData.plotType)
            case 'VARS_OVERLAY'
                if numel(varNames)==1
                    short_name = char(varNames{ii});
                    long_name = imosParameters( short_name, 'long_name' );
                    try      uom = ['(' imosParameters(short_name, 'uom') ')'];
                    catch e, uom = '';
                    end
                    ylabelStr = makeYlabel( short_name, long_name, uom );
                    %ii
                    %hAx(ii)
                    %ylabelStr
                    ylabel(hAx(ii), ylabelStr);
                else
                    ylabel(hAx,'Multiple Variables');
                end
                
            case 'VARS_STACKED'
                short_name = char(varNames{ii});
                long_name = imosParameters( short_name, 'long_name' );
                try      uom = ['(' imosParameters(short_name, 'uom') ')'];
                catch e, uom = '';
                end
                ylabelStr = makeYlabel( short_name, long_name, uom );
                %ii
                %hAx(ii)
                %ylabelStr
                ylabel(hAx(ii), ylabelStr);
        end
    end
    
    grid(hAx(ii),'on');
    
    h = findobj(hAx(ii),'Type','line','-not','tag','legend','-not','tag','Colobar');
    
    % mapping = round(linspace(1,64,length(h)))';
    % colors = colormap('jet');
    %   func = @(x) colorspace('RGB->Lab',x);
    %   c = distinguishable_colors(25,'w',func);
    cfunc = @(x) colorspace('RGB->Lab',x);
    colors = distinguishable_colors(length(h),'white',cfunc);
    for jj = 1:length(h)
        %dstrings{jj} = get(h(jj),'DisplayName');
        try
            %set(h(jj),'Color',colors( mapping(j),: ));
            set(h(jj),'Color',colors(jj,:));
        catch e
            fprintf('Error changing plot colours in plot %s \n',get(gcf,'Name'));
            disp(e.message);
        end
    end
    
    %[legend_h,object_h,plot_h,text_str]=legend(hAx,legendStr,'Location','Best', 'FontSize', 8);
    [legend_h,object_h,plot_h,text_str]=legend(hAx(ii),legendStr{ii});
    set(legend_h, 'FontSize', 8);
    
    % legendflex still has problems
    %[legend_h,object_h,plot_h,text_str]=legendflex(hAx, legendStr, 'ref', hAx, 'xscale', 0.5, 'FontSize', 8);
end

%% update xlabels (linked so only have to do one)
updateDateLabel(hFig,struct('Axes', hAx(1)), true);

set(gData.progress,'String','Done');
setappdata(hFig, 'UserData', userData);

drawnow;

% release rentrancy flag
hash.remove(hObject);

end
