function varargout = easyplot(varargin)
%EASYPLOT MATLAB code for oceanographic field data viewing using
%imos-toolbox parser routines.
%      EASYPLOT, by itself, creates a new EASYPLOT or raises the existing
%      singleton*.
%
%      H = EASYPLOT returns the handle to a new EASYPLOT or the handle to
%      the existing singleton*.
%
%      EASYPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EASYPLOT.M with the given input arguments.
%
%      EASYPLOT('Property','Value',...) creates a new EASYPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before easyplot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to easyplot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help easyplot

% Last Modified by GUIDE v2.5 11-Feb-2014 02:32:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @easyplot_OpeningFcn, ...
    'gui_OutputFcn',  @easyplot_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

end


%% --- Executes just before easyplot is made visible.
function easyplot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to easyplot (see VARARGIN)

% Choose default command line output for easyplot
hFig=ancestor(hObject,'figure');
handles=guidata(hFig);
handles.output = hObject;

set(handles.figure1,'Color',[1 1 1]);
set(handles.figure1,'Toolbar','figure');
% create easyplot toolbar
%hpt = uipushtool(ht,'CData',icon,'TooltipString','Hello')

handles.xMin=NaN;
handles.xMax=NaN;
handles.yMin=NaN;
handles.yMax=NaN;
% old path for easier importing
[handles.EPdir, name, ext] = fileparts(mfilename('fullpath'));
handles.oldPathname=handles.EPdir;
handles.ini = ini2struct(fullfile(handles.EPdir,'easyplot.ini'));
try
    thePath=handles.ini.startDialog.dataDir;
    if exist(thePath)
        handles.oldPathname=thePath;
    end
end

% this is what I am working toward, parsers can be 'queried' for some info
% and file extensions supported
% parsers=listParsers;
% structs={};
% for ii=1:numel(parsers)
%     parser=getParser(parsers{ii});
%     structs{end+1}=parser('info');
% end
% aStr=cellfun(@(x) x.short_message, structs, 'UniformOutput', false);
% [choice, idx]=optionDialog('Choose instument type','Choose instument type',aStr,1);
% but for the moment have this
% list of instruments and their parsers
ii=0;

ii=ii+1;
theList.name{ii}='Citadel CTD (csv)';
theList.wildcard{ii}={'*.csv'};
theList.message{ii}='Choose Citadel CTD csv files:';
theList.parser{ii}='citadelParse';

ii=ii+1;
theList.name{ii}='Nortek AWAC (wpr,wpb)';
theList.wildcard{ii}={'*.wpr', '*.wpb'};
theList.message{ii}='Choose Nortek *.wpr, *.wpb files:';
theList.parser{ii}='awacParse';

ii=ii+1;
theList.name{ii}='Nortek Continental (wpr,wpb)';
theList.wildcard{ii}={'*.wpr', '*.wpb'};
theList.message{ii}='Choose Nortek *.wpr, *.wpb files:';
theList.parser{ii}='continentalParse';

ii=ii+1;
theList.name{ii}='Nortek Aquadopp Velocity (aqd)';
theList.wildcard{ii}={'*.aqd'};
theList.message{ii}='Choose Nortek *.aqd files:';
theList.parser{ii}='aquadoppVelocityParse';

ii=ii+1;
theList.name{ii}='Nortek Aquadopp Profiler (prf)';
theList.wildcard{ii}={'*.prf'};
theList.message{ii}='Choose Nortek *.prf files:';
theList.parser{ii}='aquadoppProfilerParse';

ii=ii+1;
theList.name{ii}='RBR (txt,dat)';
theList.wildcard{ii}={'*.txt', '*.dat'};
theList.message{ii}='Choose TR1060/TDR2050 files:';
theList.parser{ii}='XRParse';

ii=ii+1;
theList.name{ii}='RDI (000,PD0)';
theList.wildcard{ii}={'*.000', '*.PD0'};
theList.message{ii}='Choose RDI 000/PD0 files:';
theList.parser{ii}='workhorseParse';

ii=ii+1;
theList.name{ii}='SBE37 (asc)';
theList.wildcard{ii}={'*.asc'};
theList.message{ii}='Choose SBE37 files:';
theList.parser{ii}='SBE37Parse';

ii=ii+1;
theList.name{ii}='SBE37 (cnv)';
theList.wildcard{ii}={'*.cnv'};
theList.message{ii}='Choose SBE37 files:';
theList.parser{ii}='SBE37SMParse';

ii=ii+1;
theList.name{ii}='SBE39 (asc)';
theList.wildcard{ii}={'*.asc'};
theList.message{ii}='Choose SBE39 asc files:';
theList.parser{ii}='SBE39Parse';

ii=ii+1;
theList.name{ii}='SBE56 (cnv)';
theList.wildcard{ii}={'*.cnv'};
theList.message{ii}='Choose SBE56 cnv files:';
theList.parser{ii}='SBE56Parse';

ii=ii+1;
theList.name{ii}='SBE CTD (cnv)';
theList.wildcard{ii}={'*.cnv'};
theList.message{ii}='Choose CTD cnv files:';
theList.parser{ii}='SBE19Parse';

ii=ii+1;
theList.name{ii}='Vemco Minilog-II-T (csv)';
theList.wildcard{ii}={'*.csv'};
theList.message{ii}='Choose VML2T *.csv files:';
theList.parser{ii}='VemcoParse';

ii=ii+1;
theList.name{ii}='Wetlabs (FL)NTU (raw)';
theList.wildcard{ii}={'*.raw'};
theList.message{ii}='Choose (FL)NTU *.raw files:';
theList.parser{ii}='ECOTripletParse';

ii=ii+1;
theList.name{ii}='WQM (dat)';
theList.wildcard{ii}={'*.dat'};
theList.message{ii}='Choose WQM files:';
theList.parser{ii}='WQMParse';

handles.theList=theList;

handles.firstPlot = true;

axesInfo.Linked = handles.axes1;
axesInfo.mdformat = 'dd-mmm';
axesInfo.Type = 'dateaxes';
axesInfo.XLabel = 'Time (UTC)';
% why does axes UserData get wiped somewhere later?
axH=handle(handles.axes1);
set(axH, 'UserData', axesInfo);
set(axH, 'XLim', [floor(now) floor(now)+1]);
% until I understand what happens to UserData use guidata to store it
handles.axesInfo=axesInfo;
guidata(hFig, handles);

% Couldn't get easyplot to function correctly so pulled in code from
% dynamicDateTick into easyplot and modified as required.
%dynamicDateTicks(handles.axes1, [], 'dd-mmm','UseDataTipCursor',false);

% Call once to ensure proper formatting
updateDateLabel(hFig,struct('Axes', axH), true);

% Tried a callback on zoom/pan and XLim listener but that just cause
% massive confusion. At the moment just call updateDateLabel as required,
% if I look into this again think I will create seperate callbacks
% for ActionPostCallback and PostSet XLim listener, which would then
% call common updateDateLabel
z = zoom(hFig);
p = pan(hFig);
set(z,'ActionPostCallback',@updateDateLabel);
set(p,'ActionPostCallback',@updateDateLabel);
%handles.lisH=addlistener(handles.axes1, 'XLim', 'PostSet', @updateDateLabel);

xlabel(handles.axes1,'Time (UTC)');

%hoverlines( handles.figure1 );

% custome data tip with nicely formatted date
dcm_h = datacursormode(handles.figure1);
set(dcm_h, 'UpdateFcn', @customDatacursorText)

handles.treePanelData{1,1}='None';
handles.treePanelData{1,2}='';
handles.treePanelData{1,3}='';
handles.treePanelData{1,4}=false;
handles.treePanelData{1,5}=0;
handles.treePanelHeader = {'','Instrument','Variable','Show','Slice'};
handles.treePanelColumnTypes = {'','char','char','logical','integer'};
handles.treePanelColumnEditable = {false, false, true, true};

handles.jtable = createTreeTable(handles);
setVisibilityCallback(hObject,true);
guidata(hFig, handles);

% UIWAIT makes easyplot wait for user response (see UIRESUMEUIRESUME)
% uiwait(handles.figure1);
end


%% --- Outputs from this function are returned to the command line.
function varargout = easyplot_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


%% --- Executes on button press in pushbutton1.
function import_Callback(hObject, eventdata, oldHandles)
%IMPORT_CALLBACk select instrument files to import
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hFig=ancestor(hObject,'figure');

handles=guidata(hFig);
setVisibilityCallback(hObject,false);

theList=handles.theList;

iParse=menu('Choose instrument type',theList.name);
if iParse < 1 % no instrument chosen
    return;
end


% get parser for the filetype
parser = str2func(theList.parser{iParse});

filterSpec=fullfile(handles.oldPathname,strjoin(theList.wildcard{iParse},';'));

pause(0.1); % need to pause to get uigetfile to operate correctly
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile(filterSpec, theList.message{iParse}, 'MultiSelect','on');
%uiwait(handles.figure1);
handles.oldPathname=PATHNAME;
if isequal(FILENAME,0) || isequal(PATHNAME,0)
    disp('No file selected.');
else
    if ischar(FILENAME)
        FILENAME = {FILENAME};
    end
    if ~isfield(handles,'sample_data')
        handles.sample_data={};
    end
    iFailed=0;
    notLoaded=false;
    for ii=1:length(FILENAME)
        % skip any files the user has already imported
        notLoaded = ~any(cell2mat((cellfun(@(x) ~isempty(strfind(x.toolbox_input_file, char(FILENAME{ii}))), handles.sample_data, 'UniformOutput', false))));
        if notLoaded
            try
                set(handles.progress,'String',strcat({'Loading : '}, char(FILENAME{ii})));
                drawnow;
                disp(['importing file ', num2str(ii), ' of ', num2str(length(FILENAME)), ' : ', char(FILENAME{ii})]);
                % adopt similar code layout as imos-toolbox importManager
                structs = {parser( {fullfile(PATHNAME,FILENAME{ii})}, 'TimeSeries' )};
                if numel(structs) == 1
                    % only one struct generated for one raw data file
                    tmpStruct = finaliseDataEasyplot(structs{1});
                    handles.sample_data{end+1} = tmpStruct;
                    clear('tmpStruct');
                else
                    % one data set may have generated more than one sample_data struct
                    % eg AWAC .wpr with waves in .wap etc
                    for k = 1:length(structs)
                        tmpStruct = finaliseDataEasyplot(structs{k});
                        handles.sample_data{end+1} = tmpStruct;
                        clear('tmpStruct');
                    end
                end
                clear('structs');
                set(handles.progress,'String',strcat({'Loaded : '}, char(FILENAME{ii})));
                drawnow;
            catch ME
                astr=['Importing file ', char(FILENAME{ii}), ' failed due to an unforseen issue. ' ME.message];
                disp(astr);
                set(handles.progress,'String',astr);
                drawnow;
                guidata(hFig, handles);
                uiwait(msgbox(astr,'Cannot parse file','warn','modal'));
                iFailed=1;
            end
        else
            disp(['File ' char(FILENAME{ii}) ' already loaded.']);
            set(handles.progress,'String',strcat({'Already loaded : '}, char(FILENAME{ii})));
            drawnow;
        end
    end
    
    guidata(ancestor(hObject,'figure'), handles);
    
    set(handles.listbox1,'String', getFilelistNames(handles.sample_data),'Value',1);
    guidata(hFig, handles);
    
    set(handles.progress,'String','Finished importing.');
    guidata(hFig, handles);
    drawnow;
    if numel(FILENAME)~=iFailed
        plotVar=chooseVar(handles.sample_data);
        %guidata(hObject,handles);
        handles.sample_data = markPlotVar(handles.sample_data, plotVar);
        handles.treePanelData = generateTreeData(handles.sample_data);
        guidata(ancestor(hObject,'figure'),handles);
        %         if isfield(handles,'jtable')
        %             %delete(handles.jtable);
        %             handles.jtable.getModel.getActualModel.getActualModel.setRowCount(0);
        %         end
        
        handles.jtable = createTreeTable(handles);
        guidata(ancestor(hObject,'figure'), handles);
        %% trying to just change the table data and redraw
        % [data,headers] = getTableData(handles.jtable);
        %  setTableData(jtable,handles.treePanelData,headers);
        %       jt.setModel(javax.swing.table.DefaultTableModel(handles.treePanelData,{'','Instrument','Variable','Show','Slice'}));
        %         model.setDataVector(tdc,num2cell(handles.treePanelHeader));
        %         model.groupAndRefresh;
        %         jt.repaint;
        
        % model=handles.jtable.getModel.getActualModel.getActualModel;
        %   td = model.getDataVector.toArray.cell;
        %   tdc = cellfun(@(c)c.toArray.cell, td, 'uniform',false);
        
        % jData=java.util.Vector(size(handles.treePanelData,1));
        % for ii = 1 : size(handles.treePanelData,1)
        %         jVec = java.util.Vector(size(handles.treePanelData,2));
        %         for jj = 1 : size(handles.treePanelData,2)
        %             jVec.add(handles.treePanelData{ii,jj});
        %         end
        %         jData.addElement(jVec);
        %         clear('jVec');
        % end
        %
        % jHeader= java.util.Vector(numel(handles.treePanelHeader));
        % for ii = 1 : numel(handles.treePanelHeader)
        %   jHeader.add(handles.treePanelHeader{ii});
        % end
        %
        % jt=handles.jtable;
        % jt.setModel(javax.swing.table.DefaultTableModel(jData,jHeader));
        % %jt.setModel(MultiClassTableModel(jData,jHeader));
        % CustomizableCellRenderer
        % javax.swing.table.DefaultTableCellRenderer
        % % model=handles.jtable.getModel.getActualModel.getActualModel
        % % model.groupAndRefresh;
        % mmodel = jt.getModel
        % jmodel = com.jidesoft.grid.DefaultGroupTableModel(mmodel)
        % jmodel.groupAndRefresh;
        % jt.repaint;
        
        
        guidata(ancestor(hObject,'figure'),handles);
        oldWarnState = warning('off','MATLAB:hg:JavaSetHGProperty');
        %set(handle(getOriginalModel(handles.jtable),'CallbackProperties'), 'TableChangedCallback', {@tableVisibilityCallback, ancestor(hObject,'figure')});
        guidata(ancestor(hObject,'figure'), handles);
        plotData(hFig);
        warning(oldWarnState);
    end
end
setVisibilityCallback(hObject,true);
guidata(hFig, handles);

end

%%
function sam = finaliseDataEasyplot(sam)
%FINALISEDATA Adds new TIMEDIFF var
%
% Inputs:
%   sam             - a struct containing sample data.
%
% Outputs:
%   sample_data - same as input, with fields added/modified

idTime  = getVar(sam.dimensions, 'TIME');
tmpStruct = struct();
tmpStruct.dimensions = idTime;
tmpStruct.name = 'TIMEDIFF';
theData=sam.dimensions{idTime}.data;
theData = [NaN; diff(theData*86400.0)];
tmpStruct.data = theData;
tmpStruct.iSlice = 1;
tmpStruct.typeCastFunc = sam.dimensions{idTime}.typeCastFunc;
sam.variables{end+1} = tmpStruct;
clear('tmpStruct');

[PATHSTR,NAME,EXT] = fileparts(sam.toolbox_input_file);
sam.inputFilePath = PATHSTR;
sam.inputFile = NAME;
sam.inputFileExt = EXT;

sam.isPlottableVar = false(1,numel(sam.variables));
sam.plotThisVar = false(1,numel(sam.variables));
for kk=1:numel(sam.variables)
    isEmptyDim = isempty(sam.variables{kk}.dimensions);
    isData = isfield(sam.variables{kk},'data') & any(any(~isnan(sam.variables{kk}.data)));
    if ~isEmptyDim && isData
        sam.isPlottableVar(kk) = true;
        sam.plotThisVar(kk) = false;
        sam.variables{kk}.plotThisVar=false;
    end
end

end

%%
function fileListNames = getFilelistNames(sample_data)
%GETFILELISTNAMES make a list of filenames from sample_data structure

fileListNames={};
if ~isempty(sample_data)
    for ii=1:numel(sample_data)
        fileListNames{end+1}=[sample_data{ii}.inputFile sample_data{ii}.inputFileExt];
    end
end

end

%%
function plotVar = chooseVar(sample_data)
% CHOOSEVAR Choose single variable to plot
%
% chooseVar is always called after and data import so if this function ends
% up with no data then abort.

if isempty(sample_data)
    error('CHOOSEVAR: empty sample_data');
end

plotVar=[];
varList= {};
for ii=1:numel(sample_data)
    for jj=1:numel(sample_data{ii}.variables)
        if sample_data{ii}.isPlottableVar(jj)
            varList{end + 1}=sample_data{ii}.variables{jj}.name;
        end
    end
end
varList=unique(varList);
varList{end+1}='ALLVARS';
%disp(sprintf('%s ','Variable list = ',varList{:}));

title = 'Variable to plot?';
prompt = 'Variable List';
defaultanswer = 1;
choice = optionDialog( title, prompt, varList, defaultanswer )

pause(0.1);
if isempty(choice), return; end

if strcmp(choice,'ALLVARS') %choosen plot all variables
    plotVar=varList(1:end-1);
else
    plotVar={choice};
end
end

%%
function [isPlottable] = isPlottableData( theData )
isPlottable = false;
if isfield(theData,'data')
    if isfield(theData,'dimensions') && ~isempty(theData.dimensions)
        isPlottable = true;
    end
end
end

%%
function [sample_data] = markPlotVar(sample_data, plotVar)
%MARKPLOTVAR Create cell array of plotted data for treeTable data

for ii=1:numel(sample_data)
    sample_data{ii}.plotThisVar = cellfun(@(x) strcmp(x.name,plotVar), sample_data{ii}.variables);
    for jj=1:numel(sample_data{ii}.variables)
        if sample_data{ii}.plotThisVar(jj)
            sample_data{ii}.variables{jj}.plotThisVar=true;
            sample_data{ii}.variables{jj}.iSlice=1;
            if ~isvector(sample_data{ii}.variables{jj}.data)
                [d1,d2] = size(sample_data{ii}.variables{jj}.data);
                sample_data{ii}.variables{jj}.iSlice=floor(d2/2);
                sample_data{ii}.variables{jj}.minSlice=1;
                sample_data{ii}.variables{jj}.maxSlice=d2;
            end
        else
            sample_data{ii}.variables{jj}.plotThisVar=false;
            sample_data{ii}.variables{jj}.iSlice=1;
            sample_data{ii}.variables{jj}.minSlice=1;
            sample_data{ii}.variables{jj}.maxSlice=1;
        end
    end
end

end


%%
function [treePanelData] = generateTreeData(sample_data)
%GENERATETREEDATA Create cell array for treeTable data
treePanelData={};
kk=1;
for ii=1:numel(sample_data)
    for jj=1:numel(sample_data{ii}.variables)
        if sample_data{ii}.isPlottableVar(jj)
            %  group, variable, visible
            treePanelData{kk,1}=sample_data{ii}.meta.instrument_model;
            treePanelData{kk,2}=sample_data{ii}.meta.instrument_serial_no;
            treePanelData{kk,3}=sample_data{ii}.variables{jj}.name;
            treePanelData{kk,4}=sample_data{ii}.plotThisVar(jj);
            treePanelData{kk,5}=sample_data{ii}.variables{jj}.iSlice;
            kk=kk+1;
        end
    end
end
end

%%
function tableVisibilityCallback(hModel,hEvent, hObject)
% TABLEVISIBILITYCALLBACK callback for treeTable visibility column
%
% Inputs:
% hModel - javahandle_withcallbacks.MultiClassTableModel
% hEvent - javax.swing.event.TableModelEvent
% hObject - hopefully the handle to figure

% cannot use the turn of the callback trick here
% from "Undocumented Secrets of MATLAB-Java Programming" pg 167
% prevent re-entry
persistent hash;
if isempty(hash)
    hash = java.util.Hashtable; 
end
if ~isempty(hash.get(hObject))
return;
end
hash.put(hObject,1);

if ishghandle(hObject)
    handles=guidata(ancestor(hObject,'figure'));
else
    disp('I am stuck in tableVisibilityCallback');
    return;
end

% Get the modification data, zero indexed
modifiedRow = get(hEvent,'FirstRow');
modifiedCol = get(hEvent,'Column');
theModel   = hModel.getValueAt(modifiedRow,0);
theSerial   = hModel.getValueAt(modifiedRow,1);
theVariable   = hModel.getValueAt(modifiedRow,2);
plotTheVar = hModel.getValueAt(modifiedRow,3);
iSlice = hModel.getValueAt(modifiedRow,4);

for ii=1:numel(handles.sample_data) % loop over files
    for jj=1:numel(handles.sample_data{ii}.variables)
        if strcmp(handles.sample_data{ii}.meta.instrument_model, theModel) && ...
                strcmp(handles.sample_data{ii}.meta.instrument_serial_no, theSerial) &&...
                strcmp(handles.sample_data{ii}.variables{jj}.name, theVariable)
            handles.sample_data{ii}.plotThisVar(jj) = plotTheVar;
            if isvector(handles.sample_data{ii}.variables{jj}.data)
                hModel.setValueAt(1,modifiedRow,4);
                handles.sample_data{ii}.variables{jj}.iSlice = 1;
            else
                [d1,d2] = size(handles.sample_data{ii}.variables{jj}.data);
                if iSlice<1
                    hModel.setValueAt(1,modifiedRow,4);
                    handles.sample_data{ii}.variables{jj}.iSlice = 1;
                elseif iSlice>d2
                    hModel.setValueAt(d2,modifiedRow,4);
                    handles.sample_data{ii}.variables{jj}.iSlice = d2;
                else
                    handles.sample_data{ii}.variables{jj}.iSlice = iSlice;
                end
            end
        end
    end
end
% model = getOriginalModel(handles.jtable);
% model.groupAndRefresh;
% handles.jtable.repaint;

guidata(ancestor(hObject,'figure'), handles);
plotData(ancestor(hObject,'figure'));

guidata(ancestor(hObject,'figure'), handles);

% release rentrancy flag
hash.remove(hObject);

end  % tableChangedCallback


%%
function originalModel = getOriginalModel(jtable)
%GETORIGINALMODEL Get original jtable model

originalModel = [];
if ~isempty(jtable)
    originalModel = jtable.getModel;
    try
        while(true)
            originalModel = originalModel.getActualModel;
        end;
    catch
        % never mind - bail out...
    end
end

end  % getOriginalModel


%%
function fig = getParentFigure(fig)
%GETPARENTFIGURE Get the parent figure of an object
%
% If the object is a figure or figure descendent, return the
% figure. Otherwise return [].

while ~isempty(fig) & ~strcmp('figure', get(fig,'type'))
    fig = get(fig,'parent');
end
end


%%
function plotData(hObject)
%PLOTDATA plot marked variables in sample_data
%
% Inputs:
%   hObject - handle to figure
%dbstack
if isempty(hObject), return; end

hFig = ancestor(hObject,'figure');
handles=guidata(hFig);

if isempty(hFig), return; end
if isempty(handles.sample_data), return; end

figure(hFig); %make figure current
hAx=handles.axes1;

%Create a string for legend
%legendStr={'Plots'};
legendStr={};

% set(handles.figure1,'Color',[1 1 1]);
%hold('on');

% clear plot
legend(hAx,'off');
% if isfield(handles,'legend_h')
%     delete(handles.legend_h);
% end
%children = get(handles.axes1, 'Children');
children = findobj(handles.axes1,'Type','line');
if ~isempty(children)
    delete(children);
end

varNames={};
%allVarInd=cellfun(@(x) cellfun(@(y) getVar(x.variables, char(y)), varName,'UniformOutput',false), handles.sample_data,'UniformOutput',false);

for ii=1:numel(handles.sample_data) % loop over files
    for jj=1:numel(handles.sample_data{ii}.variables)
        if strcmp(handles.sample_data{ii}.variables{jj}.name,'TIMEDIFF')
            lineStyle='.';
        else
            lineStyle='-';
        end
        if handles.sample_data{ii}.plotThisVar(jj)
            idTime  = getVar(handles.sample_data{ii}.dimensions, 'TIME');
            instStr=strcat(handles.sample_data{ii}.variables{jj}.name, '-',handles.sample_data{ii}.meta.instrument_model,'-',handles.sample_data{ii}.meta.instrument_serial_no);
            %disp(['Size : ' num2str(size(handles.sample_data{ii}.variables{jj}.data))]);
            [PATHSTR,NAME,EXT] = fileparts(handles.sample_data{ii}.toolbox_input_file);
            try
                if isvector(handles.sample_data{ii}.variables{jj}.data)
                    plot(hAx,handles.sample_data{ii}.dimensions{idTime}.data, ...
                        handles.sample_data{ii}.variables{jj}.data, ...
                        lineStyle, 'DisplayName', instStr, 'Tag', [NAME EXT]);
                else
                    iSlice = handles.sample_data{ii}.variables{jj}.iSlice;
                    plot(hAx,handles.sample_data{ii}.dimensions{idTime}.data, ...
                        handles.sample_data{ii}.variables{jj}.data(:,iSlice), ...
                        lineStyle, 'DisplayName', instStr, 'Tag', [NAME EXT]);
                end
                %line(handles.sample_data{ii}.dimensions{idTime}.data, handles.sample_data{ii}.variables{jj}.data,'DisplayName',instStr);
            catch
                error('PLOTDATA: plot failed.');
            end
            hold(hAx,'on');
            legendStr{end+1}=strrep(instStr,'_','\_');
            varNames{end+1}=handles.sample_data{ii}.variables{jj}.name;
            set(handles.progress,'String',strcat('Plot : ', instStr));
            guidata(ancestor(hObject,'figure'), handles);
            %drawnow;
        end
    end
end
varNames=unique(varNames);
dataLimits=findVarExtents(handles.sample_data);
handles.xMin = dataLimits.xMin;
handles.xMax = dataLimits.xMax;
handles.yMin = dataLimits.yMin;
handles.yMax = dataLimits.yMax;
guidata(ancestor(hObject,'figure'), handles);
if handles.firstPlot
    set(hAx,'XLim',[handles.xMin handles.xMax]);
    set(hAx,'YLim',[handles.yMin handles.yMax]);
    handles.firstPlot=false;
end

if isempty(varNames)
    ylabel(hAx,'No Variables');
elseif numel(varNames)==1
    ylabel(hAx,strrep(char(varNames{1}),'_','\_'));
else
    ylabel(hAx,'Multiple Variables');
end

% make
h = findobj(hAx,'Type','line');

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

updateDateLabel(hFig,struct('Axes', hAx), true);

legend_h=legend(hAx,legendStr,'Location','Best', 'FontSize', 8);
%[legend_h,object_h,plot_h,text_str]=legendflex(hAx, legendStr, 'xscale', 0.5, 'FontSize', 6)
handles.legend_h=legend_h;
set(handles.progress,'String','Done');
drawnow;
guidata(ancestor(hObject,'figure'), handles);
%drawnow;
end


%% --- Executes on button press in saveImage.
function saveImage_Callback(hObject, eventdata, oldHandles)
%SAVEIMAGE_CALLBACK Easyplot save image
% hObject    handle to saveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(ancestor(hObject,'figure'));
if isfield(handles,'sample_data') && numel(handles.sample_data) > 0
    [FILENAME, PATHNAME, FILTERINDEX] = uiputfile('*.png', 'Filename to save png');
    if isequal(FILENAME,0) || isequal(PATHNAME,0)
        disp('No file selected.');
    else
        %print(handles.axes1,'-dpng','-r300',fullfile(PATHNAME,FILENAME));
        export_fig(fullfile(PATHNAME,FILENAME),'-png',handles.axes1);
    end
    %uiresume(handles.figure1);
end

end


%% --- Executes on button press in clearPlot.
function clearPlot_Callback(hObject, eventdata, oldHandles)
%CLEARPLOT_CALLBACK Clear easyplot plot window
%
% hObject    handle to clearPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(ancestor(hObject,'figure'));
% clear plot
if isfield(handles, 'sample_data')
    children = get(handles.axes1, 'Children');
    delete(children);
    legend(handles.axes1,'off')
    handles.sample_data={};
    % how do I reset contents of handles.jtable?
    %     if isfield(handles,'jtable')
    %         %delete(handles.jtable);
    %         handles.jtable.getModel.getActualModel.getActualModel.setRowCount(0);
    %     end
    
    handles.treePanelData{1,1}='None';
    handles.treePanelData{1,2}='None';
    handles.treePanelData{1,3}='None';
    handles.treePanelData{1,4}=false;
    handles.treePanelData{1,5}=1;
    %     model = handles.jtable.getModel.getActualModel;
    %     %model = getOriginalModel(jtable);
    %     model.groupAndRefresh;
    %     handles.jtable.repaint;
    
    set(handles.listbox1,'String', '');
    
    handles.firstPlot=true;
    handles.xMin=NaN;
    handles.xMax=NaN;
    handles.yMin=NaN;
    handles.yMax=NaN;
    
    guidata(ancestor(hObject,'figure'), handles);
end
end


%% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, oldHandles)
%EXIT_CALLBACK Easyplot exit
%
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(ancestor(hObject,'figure'));
handles.ini.startDialog.dataDir=handles.oldPathname;
struct2ini(fullfile(handles.EPdir,'easyplot.ini'),handles.ini);

%delete(handles.lisH);
delete(handles.figure1);
end


%% --- Executes on button press in replot.
function replot_Callback(hObject, eventdata, oldHandles)
% hObject    handle to replot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(ancestor(hObject,'figure'));
setVisibilityCallback(hObject,false);
if isfield(handles, 'sample_data')
    
    plotVar = chooseVar(handles.sample_data);
    handles.sample_data = markPlotVar(handles.sample_data, plotVar);
    
    handles.treePanelData = generateTreeData(handles.sample_data);
    guidata(ancestor(hObject,'figure'),handles);
    
    %     %model = handles.jtable.getModel.getActualModel;
    %     model = getOriginalModel(handles.jtable);
    %     model.groupAndRefresh;
    %     handles.jtable.repaint;
    
    % surely I don't have to delete and recreate jtable
    %     if isfield(handles,'jtable')
    %         %delete(handles.jtable);
    %         handles.jtable.getModel.getActualModel.getActualModel.setRowCount(0);
    %     end
    handles.jtable = createTreeTable(handles);
    guidata(ancestor(hObject,'figure'), handles);
    plotData(ancestor(hObject,'figure'));
end
setVisibilityCallback(hObject,true);
guidata(ancestor(hObject,'figure'), handles);

end


%% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, oldHandles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=guidata(ancestor(hObject,'figure'));
setVisibilityCallback(hObject,false);

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
selectionType=get(handles.figure1,'SelectionType');
% If double click
if strcmp(selectionType,'open')
    
    if numel(handles.sample_data) == 1
        % removing last plot
        clearPlot_Callback(hObject, eventdata, handles);
    else
        index_selected = get(handles.listbox1,'Value');
        file_list = get(handles.listbox1,'String');
        % Item selected in list box
        filename = file_list{index_selected};
        iFile = find(cell2mat((cellfun(@(x) ~isempty(strfind(x.toolbox_input_file, filename)), handles.sample_data, 'UniformOutput', false))));
        handles.sample_data(iFile)=[];
        guidata(ancestor(hObject,'figure'),handles);
        set(handles.listbox1,'Value',1); % Matlab workaround, add this line so that the list can be changed
        set(handles.listbox1,'String', getFilelistNames(handles.sample_data));
        handles.treePanelData = generateTreeData(handles.sample_data);
        guidata(ancestor(hObject,'figure'), handles);
        % surely I don't have to delete and recreate jtable
        
        %         if isfield(handles,'jtable')
        %             %delete(handles.jtable);
        %             handles.jtable.getModel.getActualModel.getActualModel.setRowCount(0);
        %         end
        handles.jtable = createTreeTable(handles);
        
        handles.firstPlot=true;
        guidata(ancestor(hObject,'figure'), handles);
        plotData(ancestor(hObject,'figure'));
        %        set(handles.axes1,'XLim',[handles.xMin handles.xMax]);
        %        set(handles.axes1,'YLim',[handles.yMin handles.yMax]);
        % set(handle(getOriginalModel(handles.jtable),'CallbackProperties'), 'TableChangedCallback', {@tableVisibilityCallback, ancestor(hObject,'figure')});
        
        drawnow;
    end
end

if strcmp(selectionType,'normal')
    index_selected = get(handles.listbox1,'Value');
    file_list = get(handles.listbox1,'String');
    % Item selected in list box
    filename = file_list{index_selected};
    iFile = find(cell2mat((cellfun(@(x) ~isempty(strfind(x.toolbox_input_file, filename)), handles.sample_data, 'UniformOutput', false))));
    idTime  = getVar(handles.sample_data{iFile}.dimensions, 'TIME');
    newXLimits=[handles.sample_data{iFile}.dimensions{idTime}.data(1) handles.sample_data{iFile}.dimensions{idTime}.data(end)];
    %xlim(handles.axes1, newXLimits);
    zoom(handles.axes1,'reset');
    set(handles.axes1,'XLim',newXLimits);
    updateDateLabel(handles.figure1,struct('Axes', handles.axes1), true);
    %    if handles.plotAllVars==1
    %        set(handles.axes1,'YLim',[handles.yMin handles.yMax]);
    %    end
end
setVisibilityCallback(hObject,true);
guidata(ancestor(hObject,'figure'), handles);

end


%% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox1 controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


%%
function datacursorText = customDatacursorText(hObject, eventdata)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).
% event_obj

dataIndex = get(eventdata,'DataIndex');
pos = get(eventdata,'Position');

datacursorText = {['Time: ', datestr(pos(1),'yyyy-mm-dd HH:MM:SS.FFF')],...
    ['Y: ',num2str(pos(2),4)]};
% If there is a Z-coordinate in the position, display it as well
if length(pos) > 2
    datacursorText{end+1} = ['Z: ',num2str(pos(3),4)];
end

try
    p=get(eventdata,'Target');
    datacursorText{end+1} = ['DisplayName: ',get(p,'DisplayName')];
    datacursorText{end+1} = ['FileName: ',get(p,'Tag')];
end

end


%%
% --- Executes on button press in zoomYextent.
function zoomYextent_Callback(hObject, eventdata, oldHandles)
% hObject    handle to zoomYextent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(ancestor(hObject,'figure'));
if isfield(handles,'sample_data')
    dataLimits=findVarExtents(handles.sample_data);
    handles.xMin = dataLimits.xMin;
    handles.xMax = dataLimits.xMax;
    handles.yMin = dataLimits.yMin;
    handles.yMax = dataLimits.yMax;
    if ~isnan(handles.yMin) || ~isnan(handles.yMax)
        set(handles.axes1,'YLim',[handles.yMin handles.yMax]);
    end
    guidata(ancestor(hObject,'figure'), handles);
    updateDateLabel(handles.figure1,struct('Axes', handles.axes1), true);
end
end


%%
% --- Executes on button press in zoomXextent.
function zoomXextent_Callback(hObject, eventdata, oldHandles)
% hObject    handle to zoomXextent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(ancestor(hObject,'figure'));
if isfield(handles,'sample_data')
    dataLimits=findVarExtents(handles.sample_data);
    handles.xMin = dataLimits.xMin;
    handles.xMax = dataLimits.xMax;
    handles.yMin = dataLimits.yMin;
    handles.yMax = dataLimits.yMax;
    if ~isnan(handles.xMin) || ~isnan(handles.xMax)
        set(handles.axes1,'XLim',[handles.xMin handles.xMax]);
    end
    guidata(ancestor(hObject,'figure'), handles);
    updateDateLabel(handles.figure1,struct('Axes', handles.axes1), true);
end
end


%%
function dataLimits=findVarExtents(sample_data)
%FINDVAREXTENTS Find time and data extents of marked sample_data variables

if isempty(sample_data)
    dataLimits.xMin = floor(now);
    dataLimits.xMax = floor(now)+1;
    dataLimits.yMin = 0;
    dataLimits.yMax = 1;
else
    eps=1e-1;
    dataLimits.xMin = NaN;
    dataLimits.xMax = NaN;
    dataLimits.yMin = NaN;
    dataLimits.yMax = NaN;
    %allVarInd=cellfun(@(x) cellfun(@(y) getVar(x.variables, char(y)), varName,'UniformOutput',false), sample_data,'UniformOutput',false);
    % for ii=1:numel(allVarInd) % loop over files
    %     varInd=allVarInd{ii};
    %     for jj=1:numel(varInd)
    for ii=1:numel(sample_data) % loop over files
        for jj=1:numel(sample_data{ii}.variables)
            if sample_data{ii}.plotThisVar(jj)
                idTime  = getVar(sample_data{ii}.dimensions, 'TIME');
                dataLimits.xMin=min(sample_data{ii}.dimensions{idTime}.data(1), dataLimits.xMin);
                dataLimits.xMax=max(sample_data{ii}.dimensions{idTime}.data(end), dataLimits.xMax);
                if isvector(sample_data{ii}.variables{jj}.data)
                    dataLimits.yMin=min(min(sample_data{ii}.variables{jj}.data), dataLimits.yMin);
                    dataLimits.yMax=max(max(sample_data{ii}.variables{jj}.data), dataLimits.yMax);
                else
                    iSlice=sample_data{ii}.variables{jj}.iSlice;
                    dataLimits.yMin=min(min(sample_data{ii}.variables{jj}.data(:,iSlice)), dataLimits.yMin);
                    dataLimits.yMax=max(max(sample_data{ii}.variables{jj}.data(:,iSlice)), dataLimits.yMax);
                end
            end
        end
    end
    % if ylimits are small, make them a bit bigger for nice visuals
    if dataLimits.yMax-dataLimits.yMin < eps
        dataLimits.yMax=dataLimits.yMax*1.05;
        dataLimits.yMin=dataLimits.yMin*0.95;
    end
    %     if dataLimits.xMax-dataLimits.xMin < eps
    %         dataLimits.xMin = floor(now);
    %         dataLimits.xMax = floor(now)+1;
    %     end
    % paranoid now
    if ~isfinite(dataLimits.xMin) dataLimits.xMin=floor(now); end
    if ~isfinite(dataLimits.xMax) dataLimits.xMax=floor(now)+1; end
    if ~isfinite(dataLimits.yMin) dataLimits.yMin=0; end
    if ~isfinite(dataLimits.yMax) dataLimits.yMax=1; end
end

end


%%
function updateDateLabel(source, eventData, varargin)
% UPDATEDATELABEL Update dateticks on zoom/pan.
%
% Code from dynamicDateTicks

%if isMultipleCall();  return;  end

keepLimits=false;
% The following is mess of code but was of a result of trying to use the
% call function for setup, callback and listener. Since I'm only doing
% setup and listener could probably clean up, but keeping it around for
% reference.
if isfield(source,'Axes') %called as initialize axes
    %disp('updateDateLabel init')
    axH = source.Axes; % On which axes has the zoom/pan occurred
    axesInfo = get(source.Axes, 'UserData');
    keepLimits=true;
elseif isfield(eventData,'Axes') %called as callback from zoom/pan
    try
        %disp('updateDateLabel callback')
        axH = eventData.Axes; % On which axes has the zoom/pan occurred
        handles=guidata(source);
        axesInfo = handles.axesInfo;
        keepLimits=true;
        %set(source,'Interruptible','off');
    catch
        source, eventData, varargin
        get(source)
        get(eventData)
    end
else %called as a listener XLim event
    %disp('updateDateLabel listener');
    handles=guidata(get(eventData.AffectedObject,'Parent'));
    axesInfo = handles.axesInfo;
    axH = handle(handles.axes1);
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
for ii=1:numel(axesInfo.Linked)
    if ishghandle(axesInfo.Linked(ii))
        set(axesInfo.Linked(ii), 'XTick', ticks, 'XTickLabel', labels);
    end
end
xlabel(axH,axesInfo.XLabel);
end


%%
function flag=isMultipleCall()
flag = false;
% Get the stack
s = dbstack();
if numel(s) <= 2
    % Stack too short for a multiple call
    return
end

% How many calls to the calling function are in the stack?
names = {s(:).name};
TF = strcmp(s(2).name,names);
count = sum(TF);
if count>1
    % More than 1
    flag = true;
end
end

%% Get data from Table
function table_data = getData(jtable_handle)

numrows = jtable_handle.getRowCount;
numcols = jtable_handle.getColumnCount;

table_data = cell(numrows, numcols);

for n = 1 : numrows
    for m = 1 : numcols
        [n,m]
        temp_data = jtable_handle.getValueAt(n-1, m-1); % java indexing
        if isempty(temp_data)
            table_data{n,m} = '';
        else
            table_data{n,m} = temp_data;
        end
    end
end

end % function getData

%%
function setVisibilityCallback(hObject,toggle)

hFig=ancestor(hObject,'figure');
handles=guidata(hFig);
if ~isempty(handles)
    if isfield(handles,'jtable')
        if toggle
            %disp('Turning ON tableVisibilityCallback');
            set(handle(getOriginalModel(handles.jtable),'CallbackProperties'), 'TableChangedCallback', {@tableVisibilityCallback, ancestor(hObject,'figure')});
        else
            %disp('Turning OFF tableVisibilityCallback');
            set(handle(getOriginalModel(handles.jtable),'CallbackProperties'), 'TableChangedCallback', []);
        end
    end
end
guidata(ancestor(hObject,'figure'), handles);

end

%%
function jtable = createTreeTable(fHandle)

jtable = treeTable(fHandle.treePanel, ...
    fHandle.treePanelHeader,...
    fHandle.treePanelData,...
    'ColumnTypes',fHandle.treePanelColumnTypes,...
    'ColumnEditable',fHandle.treePanelColumnEditable);

% Make 'Visible' column width small as practible
jtable.getColumnModel.getColumn(2).setMaxWidth(45);
% right-align second column
renderer = jtable.getColumnModel.getColumn(1).getCellRenderer;
%renderer = javax.swing.table.DefaultTableCellRenderer;
renderer.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
jtable.getColumnModel.getColumn(1).setCellRenderer(renderer);

end