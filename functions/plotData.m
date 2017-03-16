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
hAx=gData.axes1;

useQCflags = logical(gData.plotQC.Value);

%Create a string for legend
legendStr={};

%legend(hAx,'off');
if isfield(userData,'legend_h')
    if ~isempty(userData.legend_h),  delete(userData.legend_h); end
end
%children = get(handles.axes1, 'Children');
children = findobj(gData.axes1,'Type','line');
if ~isempty(children)
    delete(children);
end

varNames={};
%allVarInd=cellfun(@(x) cellfun(@(y) getVar(x.variables, char(y)), varName,'UniformOutput',false), handles.sample_data,'UniformOutput',false);

for ii=1:numel(userData.sample_data) % loop over files
    iVars = find(userData.sample_data{ii}.plotThisVar)';
    for jj = iVars
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
                if useQCflags & isfield(userData.sample_data{ii}.variables{jj}, 'flags');
                    varFlags = userData.sample_data{ii}.variables{jj}.flags;
                    iGood = ismember(varFlags, goodFlags);
                    ydataVar(~iGood) = NaN;
                end
                line('Parent',hAx,'XData',userData.sample_data{ii}.dimensions{idTime}.data, ...
                    'YData',ydataVar, ...
                    'LineStyle',lineStyle, 'Marker', markerStyle,...
                    'DisplayName', instStr, 'Tag', tagStr);
            else
                % 2D var
                iSlice = userData.sample_data{ii}.variables{jj}.iSlice;
                ydataVar = userData.sample_data{ii}.variables{jj}.data(:,iSlice);
                if useQCflags & isfield(userData.sample_data{ii}.variables{jj}, 'flags');
                    varFlags = userData.sample_data{ii}.variables{jj}.flags(:,iSlice);
                    iGood = ismember(varFlags, goodFlags);
                    ydataVar(~iGood) = NaN;
                end
                line('Parent',hAx,'XData',userData.sample_data{ii}.dimensions{idTime}.data, ...
                    'YData',ydataVar, ...
                    'LineStyle',lineStyle, 'Marker', markerStyle,...
                    'DisplayName', instStr, 'Tag', tagStr);
            end
        catch
            error('PLOTDATA: plot failed.');
        end
        hold(hAx,'on');
        legendStr{end+1}=strrep(instStr,'_','\_');
        varNames{end+1}=userData.sample_data{ii}.variables{jj}.name;
        set(gData.progress,'String',strcat('Plot : ', instStr));
        %setappdata(ancestor(hObject,'figure'), 'UserData', userData);
        %drawnow;
    end
end

varNames=unique(varNames);
dataLimits=findVarExtents(userData.sample_data);
if useQCflags
    theLimits = dataLimits.QC;
else
    theLimits = dataLimits.RAW;
end
userData.xMin = theLimits.xMin;
userData.xMax = theLimits.xMax;
userData.yMin = theLimits.yMin;
userData.yMax = theLimits.yMax;
if userData.firstPlot
    set(hAx,'XLim',[userData.xMin userData.xMax]);
    set(hAx,'YLim',[userData.yMin userData.yMax]);
    userData.firstPlot=false;
end

if isempty(varNames)
    ylabel(hAx,'No Variables');
elseif numel(varNames)==1
    short_name = char(varNames{1});
    long_name = imosParameters( short_name, 'long_name' );
    uom = imosParameters( short_name, 'uom' );
    ylabel(hAx,{strrep(short_name,'_','\_'), [strrep(long_name,'_','\_') ' (' strrep(uom,'_','\_') ')']});
else
    ylabel(hAx,'Multiple Variables');
end

grid(hAx,'on');

h = findobj(hAx,'Type','line','-not','tag','legend','-not','tag','Colobar');

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
[legend_h,object_h,plot_h,text_str]=legend(hAx,legendStr);
set(legend_h, 'FontSize', 8);

% legendflex still has problems
%[legend_h,object_h,plot_h,text_str]=legendflex(hAx, legendStr, 'ref', hAx, 'xscale', 0.5, 'FontSize', 8);

userData.legend_h = legend_h;
set(gData.progress,'String','Done');

setappdata(hFig, 'UserData', userData);

updateDateLabel(hFig,struct('Axes', hAx), true);

drawnow;

% release rentrancy flag
hash.remove(hObject);

end
