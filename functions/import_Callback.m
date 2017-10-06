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
gData = guidata(hFig);

parserList=userData.parserList;

iParse=menu('Choose instrument type',parserList.name);
if iParse < 1 % no instrument chosen
    return;
end

if iParse == 1
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
    [theFile, thePath, FILTERINDEX] = uigetfile('*.csv', parserList.message{iParse}, 'MultiSelect','off');
    fileID = fopen(fullfile(thePath,theFile));
    C = textscan(fileID, '%s%s', 'Delimiter', ',');
    fclose(fileID);
    FILEparsers = C{2};
    fileList = C{1};
    clear('C');
    [FILEpaths, FILEnames, FILEexts] = cellfun(@(x) fileparts(x), fileList, 'UniformOutput', false);
    % find first directory only file, make that the base directory
    iDir = cellfun(@isdir , fileList);
    baseDir = fileList{find(iDir),1};
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
    filterSpec=fullfile(userData.oldPathname,strjoin(parserList.wildcard{iParse},';'));
    pause(0.1); % need to pause to get uigetfile to operate correctly
    [theFiles, thePath, FILTERINDEX] = uigetfile(filterSpec, parserList.message{iParse}, 'MultiSelect','on');
    allFiles = fullfile(thePath, theFiles);
    if ~iscell(allFiles)
        allFiles = { allFiles };
    end
    [FILEpaths, FILEnames, FILEexts] = cellfun(@(x) fileparts(x), allFiles, 'UniformOutput', false);
    FILEparsers(true(size(FILEnames))) = {parserList.parser{iParse}};
end

%utcOffsets = askUtcOffset(FILENAME);

userData.oldPathname=thePath;
if isequal(FILEnames,0) || isequal(thePath,0)
    disp('No file selected.');
else
    if ~isfield(userData,'sample_data')
        userData.sample_data={};
    end
    for kk=1:numel(userData.sample_data)
        userData.sample_data{kk}.isNew = false;
    end
    
    iFailed=0;
    nFiles = length(FILEnames);
    for ii=1:nFiles
        theFile = char([FILEnames{ii} FILEexts{ii}]);
        if isempty(FILEpaths{ii})
            theFullFile = which([FILEnames{ii} FILEexts{ii}]);
        else
            theFullFile = char(fullfile(FILEpaths{ii},[FILEnames{ii} FILEexts{ii}]));
        end
        % skip any files the user has already imported
%        isLoaded = cell2mat(cellfun(@(x) ~isempty(strfind(x.easyplot_input_file, theFile)), userData.sample_data, 'UniformOutput', false));
%         if ~isempty(isLoaded)
%             for kk=1:numel(userData.sample_data)
%                 if ~isLoaded(kk)
%                     userData.sample_data{kk}.isNew = false;
%                 end
%             end
%         end
        
        notLoaded = ~any(cell2mat((cellfun(@(x) ~isempty(strfind(x.easyplot_input_file, theFile)), userData.sample_data, 'UniformOutput', false))));
%        if ~any(isLoaded)
        if notLoaded
            try
                set(gData.progress,'String',strcat({'Loading : '}, theFile));
                %drawnow;
                disp(['importing file ', num2str(ii), ' of ', num2str(nFiles), ' : ', theFile]);
                % adopt similar code layout as imos-toolbox importManager
                % get parser for the filetype
                parser = str2func(FILEparsers{ii});
                
                structs = parser( {theFullFile}, 'timeSeries' );
                if numel(structs) == 1
                    % only one struct generated for one raw data file
                    structs.meta.parser = FILEparsers{ii};
                    tmpStruct = finaliseDataEasyplot(structs, theFullFile);
                    userData.sample_data{end+1} = tmpStruct;
                    clear('tmpStruct');
                    userData.sample_data{end}.isNew = true;
                else
                    % one data set may have generated more than one sample_data struct
                    % eg AWAC .wpr with waves in .wap etc
                    for k = 1:length(structs)
                        structs{k}.meta.parser = FILEparsers{ii};
                        tmpStruct = finaliseDataEasyplot(structs{k}, theFullFile);
                        userData.sample_data{end+1} = tmpStruct;
                        clear('tmpStruct');
                        userData.sample_data{end}.isNew = true;
                    end
                end
                clear('structs');
                set(gData.progress,'String',strcat({'Loaded : '}, theFile));
                %drawnow;
            catch ME
                astr=['Importing file ', theFile, ' failed due to an unforseen issue. ' ME.message];
                disp(astr);
                set(gData.progress,'String',astr);
                %drawnow;
                setappdata(hFig, 'UserData', userData);
                uiwait(msgbox(astr,'Cannot parse file','warn','modal'));
                iFailed=1;
                for kk=1:length(ME.stack)
                    ME.stack(kk)
                end
            end
        else
            disp(['File ' theFile ' already loaded.']);
            set(gData.progress,'String',strcat({'Already loaded : '}, theFile));
            %drawnow;
        end
    end
    
    %setappdata(ancestor(hObject,'figure'), 'UserData', userData);
    userData.sample_data = timeOffsetPP(userData.sample_data, 'raw', false);
    set(gData.listbox1,'String', getFilelistNames(userData.sample_data),'Value',1);
    %setappdata(hFig, 'UserData', userData);
    set(gData.progress,'String','Finished importing.');
    setappdata(hFig, 'UserData', userData);
    %drawnow;
    
    if numel(FILEnames)~=iFailed
        plotVar=chooseVar(userData.sample_data);
        isNew=cellfun(@(x) x.isNew, userData.sample_data);
        userData.sample_data = markPlotVar(userData.sample_data, plotVar, isNew);
        userData.plotVarNames = sort(unique({userData.plotVarNames{:} plotVar}));
        userData.treePanelData = generateTreeData(userData.sample_data);
        %ssetappdata(ancestor(hObject,'figure'), 'UserData', userData);
        %         if isfield(handles,'jtable')
        %             %delete(handles.jtable);
        %             handles.jtable.getModel.getActualModel.getActualModel.setRowCount(0);
        %         end
        
        userData.jtable = createTreeTable(gData, userData);
        
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
        
        
        oldWarnState = warning('off','MATLAB:hg:JavaSetHGProperty');
        setappdata(ancestor(hObject,'figure'), 'UserData', userData);
        plotData(hFig);
        warning(oldWarnState);
    end
end

% release rentrancy flag
hash.remove(hObject);

end
