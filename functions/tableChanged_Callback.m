%%
function tableVisibility_Callback(hModel, hEvent, treePanel)
% TABLEVISIBILITYCALLBACK callback for treeTable visibility column
%
% Inputs:
% hModel - javahandle_withcallbacks.MultiClassTableModel
% hEvent - javax.swing.event.TableModelEvent
% hObject - hopefully the handle to figure

% cannot use turn off the callback trick here
% from "Undocumented Secrets of MATLAB-Java Programming" pg 167
% prevent re-entry

persistent hash;
if isempty(hash)
    hash = java.util.Hashtable;
end
if ~isempty(hash.get(treePanel))
    return;
end
hash.put(treePanel,1);

if ~ishghandle(treePanel)
    hash.remove(treePanel);
    disp('I am stuck in tableVisibility_Callback');
    return;
end

hFig = ancestor(treePanel,'figure');
userData=getappdata(hFig, 'UserData');

tUserData=getappdata(treePanel, 'UserData');
%jtable = tUserData.jtable;
%jtable.setCBEnabled(false);
%oldCallback = get(jtable, 'TableChangedCallback');

%treePanelHeader = {'Instrument','File','#','Variable','Show','Slice'};
idModel = 0;
idFile = 1;
idSerial = 2;
idVariable = 3;
idShow = 4;
idSlice = 5;

% Get the modification data, zero indexed
modifiedRow = get(hEvent,'FirstRow');
modifiedCol = get(hEvent,'Column');
theInstrument  = hModel.getValueAt(modifiedRow,idModel);
theFile   = hModel.getValueAt(modifiedRow,idFile);
theSerial = hModel.getValueAt(modifiedRow,idSerial);
theVariable   = hModel.getValueAt(modifiedRow,idVariable);
plotStatus = double(hModel.getValueAt(modifiedRow,idShow));
EP_iSlice = str2num(hModel.getValueAt(modifiedRow,idSlice));

% if deselecting mark it as -1
if plotStatus == 0
    plotStatus = -1; % delete plot
elseif modifiedCol == idSlice
    plotStatus = -2; % existing plot, changed islice
else
    plotStatus = 2; % new plot
end

% update flags/values in userData.sample_data for the matching instrument
% NOTE: testing of valid values and then hModel.setValueAt causes another
% tablechange

for ii=1:numel(userData.sample_data) % loop over files
    for jj = find(cellfun(@(x) strcmp(x.name, theVariable), userData.sample_data{ii}.variables))
                    %strcmp(userData.sample_data{ii}.meta.instrument_serial_no , theSerial) &&...
        iMatch = strcmp(userData.sample_data{ii}.meta.EP_instrument_model_shortname, theInstrument) && ...
            strcmp([userData.sample_data{ii}.EP_inputFile userData.sample_data{ii}.EP_inputFileExt], theFile) &&...
            strcmp(userData.sample_data{ii}.meta.EP_instrument_serial_no_deployment, theSerial) &&...
            strcmp(userData.sample_data{ii}.variables{jj}.name, theVariable);
        if iMatch
            userData.sample_data{ii}.EP_variablePlotStatus(jj) = plotStatus;
            if isvector(userData.sample_data{ii}.variables{jj}.data)
                hModel.setValueAt(1,modifiedRow,idSlice);
                %originalModel.setValueAt(1,modifiedRow,idSlice);
                userData.sample_data{ii}.variables{jj}.EP_iSlice = 1;
            else
                [d1,d2] = size(userData.sample_data{ii}.variables{jj}.data);
                if EP_iSlice<1
                    hModel.setValueAt(1,modifiedRow,idSlice);
                    %originalModel.setValueAt(1,modifiedRow,idSlice);
                    userData.sample_data{ii}.variables{jj}.EP_iSlice = 1;
                elseif EP_iSlice>d2
                    hModel.setValueAt(d2,modifiedRow,idSlice);
                    %originalModel.setValueAt(d2,modifiedRow,idSlice);
                    userData.sample_data{ii}.variables{jj}.EP_iSlice = d2;
                else
                    userData.sample_data{ii}.variables{jj}.EP_iSlice = EP_iSlice;
                end
            end
        end
    end
end

treePanelData = generateTreeData(userData.sample_data);
updateTreeDisplay(treePanel, treePanelData)

setappdata(hFig, 'UserData', userData);

plotData(hFig);

% release rentrancy flag
hash.remove(treePanel);

%jtable.setCBEnabled(true);

%set(treePanel, 'TableChangedCallback', oldCallback);
    
end  % tableChangedCallback


