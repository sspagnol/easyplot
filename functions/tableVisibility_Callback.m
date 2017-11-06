%%
function tableVisibility_Callback(hModel, hEvent, hObject)
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
if ~isempty(hash.get(hObject))
    return;
end
hash.put(hObject,1);

if ishghandle(hObject)
    userData=getappdata(ancestor(hObject,'figure'), 'UserData');
else
    hash.remove(hObject);
    disp('I am stuck in tableVisibility_Callback');
    return;
end

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
if isempty(theSerial)
    theSerial = '';
end
theVariable   = hModel.getValueAt(modifiedRow,idVariable);
plotStatus = double(hModel.getValueAt(modifiedRow,idShow));
iSlice = hModel.getValueAt(modifiedRow,idSlice);

% if deselecting mark it as -1
if plotStatus == 0
    plotStatus = -1;
else
    plotStatus = 2;
end

% update flags/values in userData.sample_data for the matching instrument
for ii=1:numel(userData.sample_data) % loop over files
    for jj = find(cellfun(@(x) strcmp(x.name, theVariable), userData.sample_data{ii}.variables))
        iMatch = strcmp(userData.sample_data{ii}.meta.instrument_model_shortname, theInstrument) && ...
            strcmp([userData.sample_data{ii}.inputFile userData.sample_data{ii}.inputFileExt], theFile) &&...
            strcmp(userData.sample_data{ii}.meta.instrument_serial_no , theSerial) &&...
            strcmp(userData.sample_data{ii}.variables{jj}.name, theVariable);
        if iMatch
            userData.sample_data{ii}.variablePlotStatus(jj) = plotStatus;
            if isvector(userData.sample_data{ii}.variables{jj}.data)
                hModel.setValueAt(1,modifiedRow,idSlice);
                %originalModel.setValueAt(1,modifiedRow,idSlice);
                userData.sample_data{ii}.variables{jj}.iSlice = 1;
            else
                [d1,d2] = size(userData.sample_data{ii}.variables{jj}.data);
                if iSlice<1
                    hModel.setValueAt(1,modifiedRow,idSlice);
                    %originalModel.setValueAt(1,modifiedRow,idSlice);
                    userData.sample_data{ii}.variables{jj}.iSlice = 1;
                elseif iSlice>d2
                    hModel.setValueAt(d2,modifiedRow,idSlice);
                    %originalModel.setValueAt(d2,modifiedRow,idSlice);
                    userData.sample_data{ii}.variables{jj}.iSlice = d2;
                else
                    userData.sample_data{ii}.variables{jj}.iSlice = iSlice;
                end
            end
        end
    end
end

% model = getOriginalModel(handles.jtable);
% model.groupAndRefresh;
% handles.jtable.repaint;

setappdata(ancestor(hObject,'figure'), 'UserData', userData);

plotData(ancestor(hObject,'figure'));

% release rentrancy flag
hash.remove(hObject);

end  % tableChangedCallback


