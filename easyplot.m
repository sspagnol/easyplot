function varargout = easyplot(varargin)
% EASYPLOT MATLAB code for easyplot.fig
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
handles.output = hObject;

set(handles.figure1,'Color',[1 1 1]);
set(handles.figure1,'Toolbar','figure');
% create easyplot toolbar
%hpt = uipushtool(ht,'CData',icon,'TooltipString','Hello')

%set(handles.plotVar,'String','');
%handles.plotVar='';
handles.xMin=NaN;
handles.xMax=NaN;
handles.yMin=NaN;
handles.yMax=NaN;
handles.oldPathname='';
ii=1;
theList.name{ii}='RBR (txt)';
theList.wildcard{ii}='*.txt';
theList.message{ii}='Choose TR1060/TDR2050 files:';
theList.parser{ii}='XRParse';

ii=ii+1;
theList.name{ii}='WQM (dat)';
theList.wildcard{ii}='*.dat';
theList.message{ii}='Choose WQM files:';
theList.parser{ii}='WQMParse';

ii=ii+1;
theList.name{ii}='SBE37 (asc)';
theList.wildcard{ii}='*.asc';
theList.message{ii}='Choose SBE37 files:';
theList.parser{ii}='SBE37Parse';

ii=ii+1;
theList.name{ii}='SBE37 (cnv)';
theList.wildcard{ii}='*.cnv';
theList.message{ii}='Choose SBE37 files:';
theList.parser{ii}='SBE37SMParse';

ii=ii+1;
theList.name{ii}='SBE39 (asc)';
theList.wildcard{ii}='*.asc';
theList.message{ii}='Choose SBE39 asc files:';
theList.parser{ii}='SBE39Parse';

ii=ii+1;
theList.name{ii}='SBE56 (cnv)';
theList.wildcard{ii}='*.cnv';
theList.message{ii}='Choose SBE56 cnv files:';
theList.parser{ii}='SBE56Parse';

ii=ii+1;
theList.name{ii}='SBE CTD (cnv)';
theList.wildcard{ii}='*.cnv';
theList.message{ii}='Choose CTD cnv files:';
theList.parser{ii}='SBE19Parse';

ii=ii+1;
theList.name{ii}='RDI (000)';
theList.wildcard{ii}='*.000';
theList.message{ii}='Choose RDI 000 files:';
theList.parser{ii}='workhorseParse';

ii=ii+1;
theList.name{ii}='Wetlabs FLNTU (raw)';
theList.wildcard{ii}='*.raw';
theList.message{ii}='Choose FLNTU *.raw files:';
theList.parser{ii}='ECOTripletParse';

ii=ii+1;
theList.name{ii}='Vemco Minilog-II-T (csv)';
theList.wildcard{ii}='*.csv';
theList.message{ii}='Choose VML2T *.csv files:';
theList.parser{ii}='VemcoParse';

handles.theList=theList;

handles.firstPlot = true;

% Update handles structure
%guidata(hObject, handles);

dynamicDateTicks(handles.axes1, [], 'dd-mmm','UseDataTipCursor',false);
xlabel(handles.axes1,'Time (UTC)');

hoverlines( handles.figure1 );

dcm_h = datacursormode(handles.figure1);
% %datacursormode on;
set(dcm_h, 'UpdateFcn', @customDatacursorText)

guidata(ancestor(hObject,'figure'), handles);

% UIWAIT makes easyplot wait for user response (see UIRESUME)
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
function import_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

theList=handles.theList;

iParse=menu('Choose instrument type',theList.name);
fhandle = str2func(theList.parser{iParse});

if ~exist(handles.oldPathname,'dir')
    filterSpec=theList.wildcard{iParse};
else
    filterSpec=[handles.oldPathname '/' theList.wildcard{iParse}];
end
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
        notLoaded = ~any(cell2mat((cellfun(@(x) ~isempty(strfind(x.toolbox_input_file, char(FILENAME{ii}))), handles.sample_data, 'UniformOutput', false))));
        if notLoaded
            try
                set(handles.progress,'String',strcat({'Loading : '}, char(FILENAME{ii})));
                drawnow;
                disp(['importing file ', num2str(ii), ' of ', num2str(length(FILENAME)), ' : ', char(FILENAME{ii})]);
                handles.sample_data{end+1} = fhandle( {fullfile(PATHNAME,FILENAME{ii})}, 'timeseries' );
                set(handles.progress,'String',strcat({'Loaded : '}, char(FILENAME{ii})));
                drawnow;
                for jj=1:numel(handles.sample_data{1}.variables)
                    handles.sample_data{end}.variables{jj}.plotThisVar=false;
                end
            catch
                astr=['Importing file ', char(FILENAME{ii}), ' failed. Not an IMOS toolbox parseable file.'];
                disp(astr);
                set(handles.progress,'String',astr);
                drawnow;
                guidata(hObject, handles);
                uiwait(msgbox(astr,'Cannot parse file','warn','modal'));
                iFailed=1;
            end
        else
            disp(['File ' char(FILENAME{ii}) ' already loaded.']);
            set(handles.progress,'String',strcat({'Already loaded : '}, char(FILENAME{ii})));
            drawnow;
        end
    end
    
    set(handles.listbox1,'String', getFilelistNames(hObject,handles),'Value',1);
    guidata(ancestor(hObject,'figure'), handles);
    
    set(handles.progress,'String','Finished importing.');
    drawnow;
    if numel(FILENAME)~=iFailed
        plotVar=chooseVar(handles.sample_data);
        %guidata(hObject,handles);
        [handles.treePanelData, handles.sample_data]=markPlotVar(handles.sample_data, plotVar);
        guidata(ancestor(hObject,'figure'),handles);
        handles.jtable = treeTable(handles.treePanel, ...
            {'','Instrument','Variable','Visible'},...
            handles.treePanelData,...
            'ColumnTypes',{'','char','char','logical'},...
            'ColumnEditable',{false, false, true});
        oldWarnState = warning('off','MATLAB:hg:JavaSetHGProperty')
        set(handle(getOriginalModel(handles.jtable),'CallbackProperties'), 'TableChangedCallback', {@tableVisibilityCallback, handles.jtable, handles, ancestor(hObject,'figure')});
        warning(oldWarnState);
        handles = plotData(hObject,handles);
    end
    guidata(ancestor(hObject,'figure'), handles);
end

end


%%
function fileListNames = getFilelistNames(hObject,handles)
fileListNames={};
for ii=1:numel(handles.sample_data)
    [PATHSTR,NAME,EXT] = fileparts(handles.sample_data{ii}.toolbox_input_file);
    fileListNames{end+1}=[NAME EXT];
end
end

%%
function plotVar = chooseVar(sample_data)
plotVar={};
kk=1;
for ii=1:numel(sample_data)
    for jj=1:numel(sample_data{ii}.variables)
        if isvector(sample_data{ii}.variables{jj}.data)
            varList{kk}=sample_data{ii}.variables{jj}.name;
            kk=kk+1;
        end
    end
end
varList=unique(varList);
varList{end+1}='ALLVARS';
disp(sprintf('%s ','Variable list = ',varList{:}));

ii=menu('Variable to plot?',varList);
if ii==numel(varList) %choosen plot all variables
    plotVar=varList(1:end-1);
else
    plotVar={varList{ii}};
end
end

%%
function [treePanelData, sample_data]=markPlotVar(sample_data, plotVar)
% create cell array for treeTable data
treePanelData={};
    kk=1;    
for ii=1:numel(sample_data) % loop over files
    for jj=1:numel(sample_data{ii}.variables)
        if any(ismember(sample_data{ii}.variables{jj}.name, plotVar))
            sample_data{ii}.variables{jj}.plotThisVar=true;
        else
            sample_data{ii}.variables{jj}.plotThisVar=false;
        end
        %  group, variable, visible
        treePanelData{kk,1}=sample_data{ii}.meta.instrument_model;
        treePanelData{kk,2}=sample_data{ii}.meta.instrument_serial_no;
        treePanelData{kk,3}=sample_data{ii}.variables{jj}.name;
        treePanelData{kk,4}=sample_data{ii}.variables{jj}.plotThisVar;
        kk=kk+1;
    end
end
end


%%
function tableVisibilityCallback(hModel,hEvent,jtable, handles, hObject)
% Get the modification data, zero indexed
modifiedRow = get(hEvent,'FirstRow');
modifiedCol = get(hEvent,'Column');
theModel   = hModel.getValueAt(modifiedRow,0);
theSerial   = hModel.getValueAt(modifiedRow,1);
theVariable   = hModel.getValueAt(modifiedRow,2);
newData = hModel.getValueAt(modifiedRow,modifiedCol);

% Now do something useful with this info
fprintf('You modified cell %d,%d to: %s\n', modifiedRow+1, modifiedCol+1, num2str(newData));%% Get the basic JTable data model
%fprintf('%s %s variable : %s\n', handles.treePanelData{modifiedRow+1,1},handles.treePanelData{modifiedRow+1,2},handles.treePanelData{modifiedRow+1,3});
fprintf('%s %s variable : %s\n', theModel, theSerial, theVariable);
for ii=1:numel(handles.sample_data) % loop over files
    for jj=1:numel(handles.sample_data{ii}.variables)
        if strcmp(handles.sample_data{ii}.meta.instrument_model, theModel) && ...
                strcmp(handles.sample_data{ii}.meta.instrument_serial_no, theSerial) &&...
                strcmp(handles.sample_data{ii}.variables{jj}.name, theVariable)
            handles.sample_data{ii}.variables{jj}.plotThisVar = newData;
        end
    end
end
% guidata(getParentFigure(hObject), handles);
% handles = plotData(getParentFigure(hObject),handles);
% guidata(getParentFigure(hObject), handles);
guidata(ancestor(hObject,'figure'), handles);
handles = plotData(ancestor(hObject,'figure'),handles);
guidata(ancestor(hObject,'figure'), handles);

end  % tableChangedCallback


%%
function originalModel = getOriginalModel(jtable)
originalModel = jtable.getModel;
try
    while(true)
        originalModel = originalModel.getActualModel;
    end;
catch
    a=1;  % never mind - bail out...
end
end  % getOriginalModel

%%
function fig = getParentFigure(fig)
% if the object is a figure or figure descendent, return the
% figure. Otherwise return [].
while ~isempty(fig) & ~strcmp('figure', get(fig,'type'))
    fig = get(fig,'parent');
end
end
%%
function handles = plotData(hObject,handles)

hFig = getParentFigure(hObject);
figure(hFig); %make figure current

%Create a string for legend
legendStr={};

% set(handles.figure1,'Color',[1 1 1]);
%hold('on');

% clear plot
%children = get(handles.axes1, 'Children');
children = findobj(handles.axes1,'Type','line');
if ~isempty(children)
    delete(children);
end
legend(handles.axes1,'off');

varNames={};
%allVarInd=cellfun(@(x) cellfun(@(y) getVar(x.variables, char(y)), varName,'UniformOutput',false), handles.sample_data,'UniformOutput',false);

for ii=1:numel(handles.sample_data) % loop over files
    for jj=1:numel(handles.sample_data{ii}.variables)
        if handles.sample_data{ii}.variables{jj}.plotThisVar
            idTime  = getVar(handles.sample_data{ii}.dimensions, 'TIME');
            instStr=strcat(handles.sample_data{ii}.variables{jj}.name, '-',handles.sample_data{ii}.meta.instrument_model,'-',handles.sample_data{ii}.meta.instrument_serial_no);
            ph=plot(handles.axes1,handles.sample_data{ii}.dimensions{idTime}.data, handles.sample_data{ii}.variables{jj}.data,'DisplayName',instStr);
            hold(handles.axes1,'on');
            legendStr{end+1}=strrep(instStr,'_','\_');
            varNames{end+1}=handles.sample_data{ii}.variables{jj}.name;
            set(handles.progress,'String',strcat('Plot : ', instStr));
            %guidata(hObject, handles);
            drawnow;
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
    set(handles.axes1,'XLim',[handles.xMin handles.xMax]);
    set(handles.axes1,'YLim',[handles.yMin handles.yMax]);
    handles.firstPlot=false;
end

if numel(varNames)>1
    ylabel(handles.axes1,'Multiple Variables');
else
    ylabel(handles.axes1,strrep(char(varNames{1}),'_','\_'));
end

% make
h = findobj(handles.axes1,'Type','line');

% mapping = round(linspace(1,64,length(h)))';
% colors = colormap('jet');
%   func = @(x) colorspace('RGB->Lab',x);
%   c = distinguishable_colors(25,'w',func);
cfunc = @(x) colorspace('RGB->Lab',x);
colors = distinguishable_colors(length(h),'white',cfunc);
for jj = 1:length(h)
    dstrings{jj} = get(h(jj),'DisplayName');
    try
        %set(h(jj),'Color',colors( mapping(j),: ));
        set(h(jj),'Color',colors(jj,:));
    catch e
        fprintf('Error changing plot colours in plot %s \n',get(gcf,'Name'));
        disp(e.message);
    end
end

lh=legend(handles.axes1,legendStr);
set(handles.progress,'String','Done');
drawnow;
guidata(ancestor(hObject,'figure'), handles);
%guidata(getParentFigure(hObject), handles);

end


%% --- Executes on button press in saveImage.
function saveImage_Callback(hObject, eventdata, handles)
% hObject    handle to saveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'sample_data') && numel(handles.sample_data) > 0
    [FILENAME, PATHNAME, FILTERINDEX] = uiputfile('*.png', 'Filename to save png');
    if isequal(FILENAME,0) || isequal(PATHNAME,0)
        disp('No file selected.');
    else
        %print(handles.axes1,'-dpng','-r300',fullfile(PATHNAME,FILENAME));
        export_fig(fullfile(PATHNAME,FILENAME),'-png',handles.axes1);
    end
    uiresume(handles.figure1);
end

end


%% --- Executes on button press in clearPlot.
function clearPlot_Callback(hObject, eventdata, handles)
% hObject    handle to clearPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% clear plot
if isfield(handles, 'sample_data')
    children = get(handles.axes1, 'Children');
    delete(children);
    legend(handles.axes1,'off')
    handles.sample_data={};
    delete(handles.jtable);
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
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%hobj=guidata(hObject);
delete(handles.figure1);
end


%% --- Executes on button press in replot.
function replot_Callback(hObject, eventdata, handles)
% hObject    handle to replot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles, 'sample_data')
    plotVar = chooseVar(handles.sample_data);
    %guidata(hObject,handles);
    [handles.treePanelData, handles.sample_data]=markPlotVar(handles.sample_data, plotVar);
    guidata(ancestor(hObject,'figure'),handles);
    % surely I don't have to delete and recreate jtable
    delete(handles.jtable);
    handles.jtable = treeTable(handles.treePanel, ...
        {'','Instrument','Variable','Visible'},...
        handles.treePanelData,...
        'ColumnTypes',{'','char','char','logical'},...
        'ColumnEditable',{false, false, true});
    set(handle(getOriginalModel(handles.jtable),'CallbackProperties'), 'TableChangedCallback', {@tableVisibilityCallback, handles.jtable, handles, hObject});

    handles = plotData(hObject,handles);
    guidata(ancestor(hObject,'figure'), handles);
end
end


%% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
        set(handles.listbox1,'String', getFilelistNames(hObject,handles));
        %[handles.treePanelData, handles.sample_data]=markPlotVar(handles.sample_data, handles.plotVar);
        guidata(ancestor(hObject,'figure'),handles);
        handles.firstPlot=true;
        handles = plotData(hObject,handles);
        %        set(handles.axes1,'XLim',[handles.xMin handles.xMax]);
        %        set(handles.axes1,'YLim',[handles.yMin handles.yMax]);
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
%    if handles.plotAllVars==1
%        set(handles.axes1,'YLim',[handles.yMin handles.yMax]);
%    end
end
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
end

end


%%
% --- Executes on button press in zoomYextent.
function zoomYextent_Callback(hObject, eventdata, handles)
% hObject    handle to zoomYextent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%[xMin xMax yMin yMax]=findVarExtents(hObject, eventdata, handles);
if isfield(handles,'sample_data')
    set(handles.axes1,'YLim',[handles.yMin handles.yMax]);
end
end


%%
% --- Executes on button press in zoomXextent.
function zoomXextent_Callback(hObject, eventdata, handles)
% hObject    handle to zoomXextent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'sample_data')
    set(handles.axes1,'XLim',[handles.xMin handles.xMax]);
end
end


%%
function dataLimits=findVarExtents(sample_data)
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
        if sample_data{ii}.variables{jj}.plotThisVar
            idTime  = getVar(sample_data{ii}.dimensions, 'TIME');
            dataLimits.xMin=min(sample_data{ii}.dimensions{idTime}.data(1), dataLimits.xMin);
            dataLimits.yMin=min(min(sample_data{ii}.variables{jj}.data), dataLimits.yMin);
            dataLimits.xMax=max(sample_data{ii}.dimensions{idTime}.data(end), dataLimits.xMax);
            dataLimits.yMax=max(max(sample_data{ii}.variables{jj}.data), dataLimits.yMax);
        end
    end
end

end
