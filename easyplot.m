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

% Last Modified by GUIDE v2.5 07-Feb-2014 08:15:37

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

% --- Executes just before easyplot is made visible.
function easyplot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to easyplot (see VARARGIN)

% Choose default command line output for easyplot
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes easyplot wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = easyplot_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end



% --- Executes on button press in pushbutton1.
function import_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%
ii=1;
theList.name{ii}='RBR';
theList.wildcard{ii}='*.txt';
theList.message{ii}='Choose TR1060/TDR2050 files:';
theList.parser{ii}='XRParse';

ii=ii+1;
theList.name{ii}='WQM';
theList.wildcard{ii}='*.dat';
theList.message{ii}='Choose WQM files:';
theList.parser{ii}='WQMParse';

ii=ii+1;
theList.name{ii}='SBE37';
theList.wildcard{ii}='*.cnv';
theList.message{ii}='Choose SBE37 files:';
theList.parser{ii}='SBE37SMParse';

ii=ii+1;
theList.name{ii}='SBE39';
theList.wildcard{ii}='*.asc';
theList.message{ii}='Choose SBE39 files:';
theList.parser{ii}='SBE39Parse';

ii=ii+1;
theList.name{ii}='SBE56';
theList.wildcard{ii}='*.cnv';
theList.message{ii}='Choose SBE56 files:';
theList.parser{ii}='SBE56Parse';

ii=ii+1;
theList.name{ii}='SBE CTD cnv';
theList.wildcard{ii}='*.cnv';
theList.message{ii}='Choose CTD cnv files:';
theList.parser{ii}='SBE19Parse';

ii=ii+1;
theList.name{ii}='RDI';
theList.wildcard{ii}='*.000';
theList.message{ii}='Choose RDI 000 files:';
theList.parser{ii}='workhorseParse';

%%

iParse=menu('Choose instrument type',theList.name);
fhandle = str2func(theList.parser{iParse});
% need to pause to get uigetfile to operate correctly
pause(0.1);
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile(theList.wildcard{iParse}, theList.message{iParse}, 'MultiSelect','on');

if ischar(FILENAME)
    FILENAME = {FILENAME};
end
if ~isfield(handles,'sample_data')
    handles.sample_data={};
end

notLoaded=0;
for ii=1:length(FILENAME)
    notLoaded = ~any(cell2mat((cellfun(@(x) ~isempty(strfind(x.toolbox_input_file, char(FILENAME{ii}))), handles.sample_data, 'UniformOutput', false))));
    if notLoaded
        disp(['importing file ', num2str(ii), ' of ', num2str(length(FILENAME)), ' : ', char(FILENAME{ii})]);
        handles.sample_data{end+1} = fhandle( {fullfile(PATHNAME,FILENAME{ii})}, 'timeseries' );
        handles.sample_data{end}.isPlotted=0;
    else
        disp(['File ' char(FILENAME{ii}) ' already loaded.']);
    end
end

guidata(hObject, handles);

plotData(hObject,handles);

end

function plotData(hObject,handles)

sample_data=handles.sample_data;

figure(handles.figure1); %make figure current

kk=1;
for ii=1:length(sample_data)
    for jj=1:length(sample_data{ii}.variables)
        if isvector(sample_data{ii}.variables{jj}.data)
            varList{kk}=sample_data{ii}.variables{jj}.name;
            kk=kk+1;
        end
    end
end
varList=unique(varList);

disp(sprintf('%s ','Variable list = ',varList{:}));

%ask for a string in order to filter variable to plot
%varName = upper(input('Plot variable ? ', 's'));
ii=menu('Varialbe to plot?',varList);
varName=char(varList{ii});
varInd=cellfun(@(x) getVar(x.variables, varName), sample_data);
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

for ii=1:length(varInd)
    if varInd(ii)~=0 %&& ~sample_data{ii}.isPlotted
        idTime  = getVar(sample_data{ii}.dimensions, 'TIME');
        instStr=strcat(sample_data{ii}.meta.instrument_model,'\_',sample_data{ii}.meta.instrument_serial_no);
        plot(handles.axes1,sample_data{ii}.dimensions{idTime}.data, sample_data{ii}.variables{varInd(ii)}.data,'DisplayName',instStr);
        legendStr{end+1}=instStr;
        %handles.sample_data{ii}.isPlotted=1;
    end
end
ylabel(varName);
% make
h = findobj(handles.axes1,'Type','line');

% mapping = round(linspace(1,64,length(h)))';
% colors = colormap('jet');
colors = distinguishable_colors(length(h),'white');
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

datetick('x','dd-mmm-yyyy');
xlabel(handles.axes1,'Time (UTC)');
setDate4zoom;
%set(fh_overlay,'Visible','on');
%set(hLegend,'Interpreter','none');
lh=legend(legendStr);
%axc= findobj(get(gca,'Children'),'Type','line');
%lh=legend(axc,dstrings,'Location','Best','FontSize',6);

%clear hfigure i selVarInd plotStr legendStr varList hLegend
guidata(hObject, handles);
end

% --- Executes on button press in saveImage.
function saveImage_Callback(hObject, eventdata, handles)
% hObject    handle to saveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FILENAME, PATHNAME, FILTERINDEX] = uiputfile('*.png', 'Filename to save png');
if FILTERINDEX
    %print(handles.axes1,'-dpng','-r300',fullfile(PATHNAME,FILENAME));
    export_fig(fullfile(PATHNAME,FILENAME),'-png',handles.axes1);
end
uiresume(handles.figure1);
end

% --- Executes on button press in clearPlot.
function clearPlot_Callback(hObject, eventdata, handles)
% hObject    handle to clearPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% clear plot
children = get(handles.axes1, 'Children');
delete(children);
legend(handles.axes1,'hide')
handles.sample_data={};
guidata(hObject, handles);
end


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%hobj=guidata(hObject);
delete(handles.figure1);
end


% --- Executes on button press in replot.
function replot_Callback(hObject, eventdata, handles)
% hObject    handle to replot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plotData(hObject,handles);
end
