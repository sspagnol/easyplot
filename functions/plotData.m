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
switch upper(userData.plotType)
    case 'VARS_OVERLAY'
        %userData.plotVarNames
        nSubPlots = 1;
        for ii=1:numel(userData.sample_data) % loop over files
            userData.sample_data{ii}.axisIndex = zeros(size(userData.sample_data{ii}.plotThisVar));
            iVars = find(userData.sample_data{ii}.plotThisVar)';
            markedVarNames = arrayfun(@(x) userData.sample_data{ii}.variables{x}.name, iVars, 'UniformOutput', false);
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


%%
try
    useQCflags = userData.plotQC;
catch
    useQCflags = false;
end

%Create a string for legend
legendStr={};

children = findobj(gData.plotPanel,'Type','axes');
if ~isempty(children)
    delete(children);
end

varNames={};
hAx=gobjects(nSubPlots,1);
legendStr = cell(nSubPlots,1);
for ii=1:numel(userData.sample_data) % loop over files
    iVars = find(userData.sample_data{ii}.plotThisVar)';
    for jj = iVars
        ihAx = userData.sample_data{ii}.axisIndex(jj);
        hAx(ihAx) = subplot(nSubPlots,1,ihAx,'Parent',gData.plotPanel);
        %hAx(ihAx) = subplot_tight(nSubPlots,1,ihAx,[0.02 0.02],'Parent',gData.plotPanel);
        %axes(hAx(ihAx));
        switch upper(userData.plotType)
            case 'VARS_OVERLAY'
                hAx(ihAx).Tag = 'MULTI';
                
            case 'VARS_STACKED'
                hAx(ihAx).Tag = userData.sample_data{ii}.variables{jj}.name;
        end
        
        if strcmp(userData.sample_data{ii}.variables{jj}.name,'EP_TIMEDIFF')
            lineStyle='none';
            markerStyle='.';
        else
            lineStyle='-';
            markerStyle='none';
        end
        
        if strfind(userData.sample_data{ii}.variables{jj}.name, 'EP_LPF')
            idTime  = getVar(userData.sample_data{ii}.dimensions, 'LPFTIME');
        else
            idTime  = getVar(userData.sample_data{ii}.dimensions, 'TIME');
        end
        
        instStr=strcat(userData.sample_data{ii}.variables{jj}.name, '-',userData.sample_data{ii}.meta.instrument_model,'-',userData.sample_data{ii}.meta.instrument_serial_no);
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
                    'DisplayName', instStr, 'Tag', tagStr);
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
                    'DisplayName', instStr, 'Tag', tagStr);
            end
        catch
            error('PLOTDATA: plot failed.');
        end
        hold(hAx(ihAx),'on');
        legendStr{ihAx}{end+1}=strrep(instStr,'_','\_');
        varNames{end+1}=userData.sample_data{ii}.variables{jj}.name;
        set(gData.progress,'String',strcat('Plot : ', instStr));
        %setappdata(ancestor(hObject,'figure'), 'UserData', userData);
        %drawnow;
    end
end

linkaxes(hAx,'x');

varNames=unique(varNames);
userData.dataLimits=findVarExtents(userData.sample_data, varNames);
useFlags = 'RAW';
if useQCflags, useFlags='QC'; end

for ii = 1:nSubPlots
    theVar = char(userData.plotVarNames{ii});
    %userData.plotLimits.TIME.xMin = dataLimits.TIME.RAW.xMin;
    %userData.plotLimits.TIME.xMax = dataLimits.TIME.RAW.xMax;
    switch upper(userData.plotType)
        case 'VARS_OVERLAY'
            userData.plotLimits.MULTI.yMin = userData.dataLimits.MULTI.(useFlags).yMin;
            userData.plotLimits.MULTI.yMax = userData.dataLimits.MULTI.(useFlags).yMax;
        case 'VARS_STACKED'
            if ~isfield(userData.plotLimits, theVar)
                userData.plotLimits.(theVar).yMin = userData.dataLimits.(theVar).(useFlags).yMin;
                userData.plotLimits.(theVar).yMax = userData.dataLimits.(theVar).(useFlags).yMax;
            end
    end
    
    if userData.firstPlot
        set(hAx(ii),'XLim',[userData.dataLimits.TIME.RAW.xMin userData.dataLimits.TIME.RAW.xMax]);
        set(hAx(ii),'YLim',[userData.dataLimits.MULTI.RAW.yMin userData.dataLimits.MULTI.RAW.yMax]);
        userData.firstPlot=false;
    end
    
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
    
    updateDateLabel(hFig,struct('Axes', hAx(ii)), true);
end

set(gData.progress,'String','Done');
setappdata(hFig, 'UserData', userData);

drawnow;

% release rentrancy flag
hash.remove(hObject);

end
