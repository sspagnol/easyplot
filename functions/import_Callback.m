%% --- Executes on button press in pushbutton1.
function import_Callback(hObject, eventdata, oldHandles)
%IMPORT_CALLBACk select instrument files to import
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

persistent hash;
if isempty(hash)
    hash = java.util.Hashtable;
end
if ~isempty(hash.get(hObject))
    return;
end
hash.put(hObject,1);

hFig=ancestor(hObject,'figure');

userData=getappdata(hFig,'UserData');

msgPanel = findobj(hFig, 'Tag','msgPanel');
msgPanelText = findobj(msgPanel, 'Tag','msgPanelText');
filelistPanel= findobj(hFig, 'Tag','filelistPanel');
filelistPanelListbox  = findobj(filelistPanel, 'Tag','filelistPanelListbox');
%treePanel = findobj(hFig, 'Tag','treePanel');
treePanel = userData.treePanel;

parserList=userData.parserList;

title = 'Instrument to load?';
prompt = 'Instrument List';
defaultanswer = 1;
[indParse, popupString] = optionDialog_EP( title, prompt, parserList.name, defaultanswer );

if indParse < 1 % no instrument chosen
    hash.remove(hObject);
    return;
end

if indParse == 1
    % load csv with
    % column 1 : data file (full qualified or just filename) or a directory
    % column 2 : imos toolbox parser to use
    % if column 1 is a directory, it will be used as a base dir for
    % recursive searchdata for data files that are not fully qualified.
    % If multiple directory only name then the first is used.
    % e.g.
    % D:\ITF\Moorings\Field\20150803_ITF11Trip6247\Data\ITFFTB-1502\sbe3787511508.cnv, SBE37SMParse
    % D:\ITF\Moorings\Field\20150803_ITF11Trip6247\Data\ITFFTB-1502\SBE05601011_2015-08-12.cnv, SBE56Parse
    % D:\ITF\Moorings\Field\20150803_ITF11Trip6247\Data\ITFFTB-1502, BASEDIR
    % D:\ITF\Moorings\Field\20150803_ITF11Trip6247\Data\ITFFTB-1502\58521508.asc, SBE39Parse
    % FTB10000.000, workhorseParse
    pause(0.1); % need to pause to get uigetfile to operate correctly
    com.mathworks.mwswing.MJFileChooserPerPlatform.setUseSwingDialog(1) % Try to fix Dialog issue
    [theFile, thePath, FILTERINDEX] = uigetfile('*.csv', parserList.message{indParse}, 'MultiSelect','off');
    if isequal(theFile,0)
        hash.remove(hObject);
        return;
    end
    fileID = fopen(fullfile(thePath,theFile));
    C = textscan(fileID, '%s%s', 'Delimiter', ',');
    fclose(fileID);
    FILEparsers = C{2};
    fileList = C{1};
    clear('C');
    [FILEpaths, FILEnames, FILEexts] = cellfun(@(x) fileparts(x), fileList, 'UniformOutput', false);
    % find first directory only file, make that the base directory
    iDir = cellfun(@isdir , fileList);
    if any(iDir)
        baseDir = fileList{find(iDir,1)};
    else
        baseDir = fileparts(fileList{1});
    end
    FILEpaths(iDir) = [];
    FILEnames(iDir) = [];
    FILEexts(iDir) = [];
    FILEparsers(iDir) = [];
    % find all filename only, do recursive search in baseDir
    iFileOnly = cellfun(@isempty , FILEpaths);
    iFileOnly = find(iFileOnly);
    for ii=1:length(iFileOnly)
        jj = iFileOnly(ii);
        [FILEpaths{jj}, FILEnames{jj}, FILEexts{jj}] = fileparts(char(getAllFiles(baseDir, [FILEnames{jj} FILEexts{jj}])));
    end
else
    % user selected files for one particular instrument type
    filterSpec=fullfile(userData.EP_previousDataDir,strjoin(parserList.wildcard{indParse},';'));
    pause(0.1); % need to pause to get uigetfile to operate correctly
    com.mathworks.mwswing.MJFileChooserPerPlatform.setUseSwingDialog(1) % Try to fix Dialog issue
    [theFiles, thePath, FILTERINDEX] = uigetfile(filterSpec, parserList.message{indParse}, 'MultiSelect','on');
    allFiles = fullfile(thePath, theFiles);
    if ~iscell(allFiles)
        allFiles = { allFiles };
    end
    [FILEpaths, FILEnames, FILEexts] = cellfun(@(x) fileparts(x), allFiles, 'UniformOutput', false);
    FILEparsers(true(size(FILEnames))) = {parserList.parser{indParse}};
end

%utcOffsets = askUtcOffset(FILENAME);

userData.EP_previousDataDir=thePath;
if isequal(FILEnames,0) || isequal(thePath,0)
    disp('No file selected.');
else
    if ~isfield(userData,'sample_data')
        userData.sample_data={};
    end
    for kk=1:numel(userData.sample_data)
        userData.sample_data{kk}.EP_isNew = false;
    end
    
    iFailed=0;
    nFiles = length(FILEnames);
    defaultLatitude = userData.EP_defaultLatitude;
    plotVar = '';
    for ii=1:nFiles
        toolbox_input_file_short = char([FILEnames{ii} FILEexts{ii}]);
        if isempty(FILEpaths{ii})
            toolbox_input_file = which([FILEnames{ii} FILEexts{ii}]);
        else
            toolbox_input_file = char(fullfile(FILEpaths{ii},[FILEnames{ii} FILEexts{ii}]));
        end
        
        notLoaded = ~any(cell2mat((cellfun(@(x) ~isempty(strfind(x.EP_inputFullFilename, toolbox_input_file_short)), userData.sample_data, 'UniformOutput', false))));
        if notLoaded
            % get parser for the filetype
            parser_name = FILEparsers{ii};
            parser = str2func(parser_name);

            try
                set(msgPanelText,'String',strcat({'Loading : '}, toolbox_input_file_short));
                %drawnow;
                disp(['importing file ', num2str(ii), ' of ', num2str(nFiles), ' : ', toolbox_input_file_short]);
                
                structs = parser( {toolbox_input_file}, 'timeSeries' );
                
                % some parsers return struct some a cell or cell array
                if isstruct(structs)
                    structs = num2cell(structs);
                end
                
                structs = add_EPOffset_EPScale(structs);
                
                [userData.sample_data, defaultLatitude] = add_structs_to_sample_data(userData.sample_data, structs, parser_name, defaultLatitude, toolbox_input_file, plotVar);
                
                userData.EP_defaultLatitude = defaultLatitude;
                clear('structs');
                set(msgPanelText,'String',strcat({'Loaded : '}, toolbox_input_file_short));
                %drawnow;
                
            catch ME
                astr=['Importing file ', toolbox_input_file_short, ' failed due to an unforseen issue. ' ME.message];
                disp(astr);
                set(msgPanelText,'String',astr);
                %drawnow;
                setappdata(hFig, 'UserData', userData);
                uiwait(msgbox(astr,'Cannot parse file','warn','modal'));
                iFailed=1;
                for kk=1:length(ME.stack)
                    ME.stack(kk)
                end
            end
        else
            disp(['File ' toolbox_input_file_short ' already loaded.']);
            set(msgPanelText,'String',strcat({'Already loaded : '}, toolbox_input_file_short));
            %drawnow;
        end
    end
    
    if ~isfield(userData, 'dataLimits')
        userData.dataLimits = [];
    end
    userData.dataLimits = updateVarExtents(userData.sample_data, userData.dataLimits);
    
    userData.sample_data = updateDeploymentNumber(userData.sample_data);
    userData.sample_data = timeOffsetPP(userData.sample_data, 'raw', false);
    set(filelistPanelListbox,'String', getFilelistNames(userData.sample_data),'Value',1);
    set(msgPanelText,'String','Finished importing.');
    setappdata(hFig, 'UserData', userData);
    %drawnow;
    
    if numel(FILEnames)~=iFailed
        plotVar=chooseVar(userData.sample_data);
        EP_isNew=cellfun(@(x) x.EP_isNew, userData.sample_data);
        
        userData.sample_data = markPlotVar(userData.sample_data, plotVar, EP_isNew);
        
        userData.plotVarNames = sort(unique({userData.plotVarNames{:} plotVar}));
        treePanelData = generateTreeData(userData.sample_data);
        
        updateTreeDisplay(userData.treePanel, treePanelData);
        
        oldWarnState = warning('off','MATLAB:hg:JavaSetHGProperty');
        setappdata(ancestor(hObject,'figure'), 'UserData', userData);
        plotData(hFig);
        warning(oldWarnState);
    end
end

drawnow;
pause(0.01);
% release rentrancy flag
hash.remove(hObject);

end
