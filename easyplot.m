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

% Last Modified by GUIDE v2.5 16-Mar-2017 08:21:15

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
function easyplot_OpeningFcn(hObject, eventdata, userData, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to easyplot (see VARARGIN)

% Choose default command line output for easyplot
hFig=ancestor(hObject,'figure');
gData = guidata(hFig);

userData=getappdata(hFig,'UserData');
userData.output = hObject;

% white background
set(gData.figure1,'Color',[1 1 1]);
% create easyplot toolbar
set(gData.figure1,'Toolbar','figure');
%hpt = uipushtool(ht,'CData',icon,'TooltipString','Hello')

% data min/max
userData.xMin=NaN;
userData.xMax=NaN;
userData.yMin=NaN;
userData.yMax=NaN;

% old path for easier importing
[userData.EPdir, name, ext] = fileparts(mfilename('fullpath'));
userData.oldPathname=userData.EPdir;
userData.ini = ini2struct(fullfile(userData.EPdir,'easyplot.ini'));
try
    thePath=userData.ini.startDialog.dataDir;
    if exist(thePath)
        userData.oldPathname=thePath;
    end
end

% get parser list
userData.parserList=initParserList;

userData.firstPlot = true;

axesInfo.Linked = gData.axes1;
axesInfo.mdformat = 'dd-mmm';
axesInfo.Type = 'dateaxes';
axesInfo.XLabel = 'Time (UTC)';
% why does axes UserData get wiped somewhere later?
axH=handle(gData.axes1);
set(axH, 'UserData', axesInfo);
set(axH, 'XLim', [floor(now) floor(now)+1]);
userData.axesInfo=axesInfo;
%set(axH,'ButtonDownFcn',@updateAxisManual)

% Couldn't get easyplot to function correctly so pulled in code from
% dynamicDateTick into easyplot and modified as required.
%dynamicDateTicks(handles.axes1, [], 'dd-mmm','UseDataTipCursor',false);

% Tried a callback on zoom/pan and XLim listener but that just cause
% massive confusion. At the moment just call updateDateLabel as required,
% if I look into this again think I will create seperate callbacks
% for ActionPostCallback and PostSet XLim listener, which would then
% call common updateDateLabel
z = zoom(hFig);
p = pan(hFig);
set(z,'ActionPostCallback',@updateDateLabel);
set(p,'ActionPostCallback',@updateDateLabel);
set(hFig, 'WindowKeyPressFcn', @keyPressCallback);
%handles.lisH=addlistener(handles.axes1, 'XLim', 'PostSet', @updateDateLabel);

xlabel(gData.axes1,'Time (UTC)');

%hoverlines( handles.figure1 );

% custome data tip with nicely formatted date
dcm_h = datacursormode(gData.figure1);
set(dcm_h, 'UpdateFcn', @customDatacursorText)

% callback for mouse click on plot
set(hFig,'WindowButtonDownFcn', @mouseDownListener);

% Dummy treeTable data
userData.treePanelData{1,1}='None';
userData.treePanelData{1,2}='None';
userData.treePanelData{1,3}='None';
userData.treePanelData{1,4}=false;
userData.treePanelData{1,5}=0;
userData.treePanelHeader = {'','Instrument','Variable','Show','Slice'};
userData.treePanelColumnTypes = {'','char','char','logical','integer'};
userData.treePanelColumnEditable = {false, false, true, true};
userData.jtable = createTreeTable(gData, userData);

setappdata(hFig, 'UserData', userData);

% Call once to ensure proper formatting
updateDateLabel(hFig,struct('Axes', axH), true);

end


%% --- Outputs from this function are returned to the command line.
function varargout = easyplot_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.figure1;
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
end

