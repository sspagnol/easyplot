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
handles.plotVar='';
handles.xMin=+Inf;
handles.xMax=-Inf;
handles.yMin=+Inf;
handles.yMax=-Inf;
handles.plotAllVars=0;
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

handles.theList=theList;

guidata(hObject, handles);
% Update handles structure
%guidata(hObject, handles);

hoverlines( handles.figure1 );

dcm_h = datacursormode(handles.figure1);
%datacursormode on;
set(dcm_h, 'UpdateFcn', @customDatacursorText)

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
    notLoaded=0;
    for ii=1:length(FILENAME)
        notLoaded = ~any(cell2mat((cellfun(@(x) ~isempty(strfind(x.toolbox_input_file, char(FILENAME{ii}))), handles.sample_data, 'UniformOutput', false))));
        if notLoaded
            try
                set(handles.progress,'String',strcat({'Loading : '}, char(FILENAME{ii})));
                %uiresume(handles.figure1);
                disp(['importing file ', num2str(ii), ' of ', num2str(length(FILENAME)), ' : ', char(FILENAME{ii})]);
                handles.sample_data{end+1} = fhandle( {fullfile(PATHNAME,FILENAME{ii})}, 'timeseries' );
                set(handles.progress,'String',strcat({'Loaded : '}, char(FILENAME{ii})));
                handles.sample_data{end}.isPlotted=0;
            catch
                astr=['Importing file ', char(FILENAME{ii}), ' failed. Not an IMOS toolbox parseable file.'];
                disp(astr);
                set(handles.progress,'String',astr);
                guidata(hObject, handles);
                uiwait(msgbox(astr,'Cannot parse file','warn','modal'));
                iFailed=1;
            end
        else
            disp(['File ' char(FILENAME{ii}) ' already loaded.']);
            set(handles.progress,'String',strcat({'Already loaded : '}, char(FILENAME{ii})));
            %uiresume(handles.figure1);
        end
    end
    
    set(handles.listbox1,'String', getFilelistNames(hObject,handles),'Value',1);
    guidata(hObject, handles);
    
    set(handles.progress,'String','Finished importing.');
    %uiresume(handles.figure1);
    if numel(FILENAME)~=iFailed
        handles.plotVar=chooseVar(hObject,handles);
        guidata(hObject,handles);
        handles = plotData(hObject,handles);
    end
    guidata(hObject, handles);
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
function [plotVar, plotAllVars] = chooseVar(hObject,handles)

kk=1;
for ii=1:length(handles.sample_data)
    for jj=1:length(handles.sample_data{ii}.variables)
        if isvector(handles.sample_data{ii}.variables{jj}.data)
            varList{kk}=handles.sample_data{ii}.variables{jj}.name;
            kk=kk+1;
        end
    end
end
varList=unique(varList);
varList{end+1}='ALLVARS';
disp(sprintf('%s ','Variable list = ',varList{:}));

ii=menu('Varialbe to plot?',varList);
if ii==numel(varList) %choosen plot all variables
    plotVar=varList(1:end-1);
    plotAllVars=1;
else
    plotVar={varList{ii}};
    plotAllVars=0;
end
% if ~isfield(handles, 'plotVar')
%     handles.plotVar='';
% end
% handles.plotVar=plotVar;
% guidata(hObject, handles);

end

%%
function handles = plotData(hObject,handles)

figure(handles.figure1); %make figure current

%Create a string for legend
legendStr={};

% mp = get(0, 'MonitorPositions');
% screen_size = mp(1,:);
% screen_size = [0 0 mp(1,3) mp(1,4) ] .* 0.80 + 50;
% %create a toolbar and a toggle button to display or not the legend
% %toggleLegend(hFigure);
% %fh_overlay=figure('Position',screen_size, 'Visible','off');
% fh_overlay=figure('Position',screen_size,'Visible','off','ToolBar','figure');
%figure(fh_overlay);
%set(fh_overlay, 'Visible', 'off');
set(handles.figure1,'Color',[1 1 1]);
hold('on');

% clear plot
children = get(handles.axes1, 'Children');
delete(children);
legend(handles.axes1,'off');

varName=handles.plotVar;
%varInd=cellfun(@(x) getVar(x.variables, varName), handles.sample_data);
allVarInd=cellfun(@(x) cellfun(@(y) getVar(x.variables, char(y)), varName,'UniformOutput',false), handles.sample_data,'UniformOutput',false);

for ii=1:numel(allVarInd) % loop over files
    varInd=allVarInd{ii};
    for jj=1:numel(varInd)
        if varInd{jj}~=0 %&& ~sample_data{ii}.isPlotted
            idTime  = getVar(handles.sample_data{ii}.dimensions, 'TIME');
            instStr=strcat(handles.sample_data{ii}.variables{varInd{jj}}.name, '-',handles.sample_data{ii}.meta.instrument_model,'-',handles.sample_data{ii}.meta.instrument_serial_no);
            ph=plot(handles.axes1,handles.sample_data{ii}.dimensions{idTime}.data, handles.sample_data{ii}.variables{varInd{jj}}.data,'DisplayName',instStr);
            legendStr{end+1}=strrep(instStr,'_','\_');
            %handles.sample_data{ii}.isPlotted=1;
            set(handles.progress,'String',strcat('Plot : ', instStr));
            handles.xMin=min(handles.sample_data{ii}.dimensions{idTime}.data(1), handles.xMin);
            handles.yMin=min(min(handles.sample_data{ii}.variables{varInd{jj}}.data), handles.yMin);
            handles.xMax=max(handles.sample_data{ii}.dimensions{idTime}.data(end), handles.xMax);
            handles.yMax=max(max(handles.sample_data{ii}.variables{varInd{jj}}.data), handles.yMax);
            guidata(hObject, handles);
        end
    end
end
if numel(varInd)>1
    ylabel('All Variables');
else
    ylabel(strrep(char(varName{1}),'_','\_'));
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

%datetick('x','dd-mmm-yyyy');
dynamicDateTicks(handles.axes1, [], 'dd-mmm');
xlabel(handles.axes1,'Time (UTC)');
%setDate4zoom;
%set(fh_overlay,'Visible','on');
%set(hLegend,'Interpreter','none');
lh=legend(legendStr);
%axc= findobj(get(gca,'Children'),'Type','line');
%lh=legend(axc,dstrings,'Location','Best','FontSize',6);
set(handles.progress,'String','Done');

guidata(hObject, handles);

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
    set(handles.listbox1,'String', '');
    guidata(hObject, handles);
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
    [handles.plotVar, handles.plotAllVars]=chooseVar(hObject,handles);
    guidata(hObject,handles);
    handles = plotData(hObject,handles);
    guidata(hObject, handles);
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
    index_selected = get(handles.listbox1,'Value');
    file_list = get(handles.listbox1,'String');
    % Item selected in list box
    filename = file_list{index_selected};
    iFile = find(cell2mat((cellfun(@(x) ~isempty(strfind(x.toolbox_input_file, filename)), handles.sample_data, 'UniformOutput', false))));
    handles.sample_data(iFile)=[];
    guidata(hObject,handles);
    set(handles.listbox1,'String', getFilelistNames(hObject,handles));
    handles = plotData(hObject,handles);
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
    if handles.plotAllVars==1
        set(handles.axes1,'YLim',[handles.yMin handles.yMax]);
    end
end
%zoom('on');
guidata(hObject, handles);
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

output_txt = {[ 'X: ',num2str(pos(1),4)],...
    ['Y: ',num2str(pos(2),4)]};
% If there is a Z-coordinate in the position, display it as well
if length(pos) > 2
    output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
end
output_txt{end+1} = ['Time: ', datestr(pos(1),'yyyy-mm-dd HH:MM:SS.FFF')];

try
    p=get(eventdata,'Target');
    %displayName=get(p,'DisplayName')
    output_txt{end+1} = ['DisplayName: ',get(p,'DisplayName')];
end

%set(hObject,'String', output_txt);

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
function [xMin xMax yMin yMax]=findVarExtents(hObject, eventdata, handles)

end
