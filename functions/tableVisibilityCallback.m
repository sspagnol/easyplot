%%
function tableVisibilityCallback(hModel, hEvent, hObject)
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
    disp('I am stuck in tableVisibilityCallback');
    return;
end

% Get the modification data, zero indexed
modifiedRow = get(hEvent,'FirstRow');
modifiedCol = get(hEvent,'Column');
theModel   = hModel.getValueAt(modifiedRow,0);
theSerial   = hModel.getValueAt(modifiedRow,1);
if isempty(theSerial)
    theSerial = '';
end
theVariable   = hModel.getValueAt(modifiedRow,2);
plotTheVar = double(hModel.getValueAt(modifiedRow,3));
iSlice = hModel.getValueAt(modifiedRow,4);

% if deselecting mark it as -1
if plotTheVar == 0, plotTheVar = -1; end

% update flags/values in userData.sample_data
for ii=1:numel(userData.sample_data) % loop over files
    for jj=1:numel(userData.sample_data{ii}.variables)
        if strcmp(userData.sample_data{ii}.meta.instrument_model, theModel) && ...
                strcmp(userData.sample_data{ii}.meta.instrument_serial_no, theSerial) &&...
                strcmp(userData.sample_data{ii}.variables{jj}.name, theVariable)
            userData.sample_data{ii}.variablePlotStatus(jj) = plotTheVar;
            if isvector(userData.sample_data{ii}.variables{jj}.data)
                hModel.setValueAt(1,modifiedRow,4);
                userData.sample_data{ii}.variables{jj}.iSlice = 1;
            else
                [d1,d2] = size(userData.sample_data{ii}.variables{jj}.data);
                if iSlice<1
                    hModel.setValueAt(1,modifiedRow,4);
                    userData.sample_data{ii}.variables{jj}.iSlice = 1;
                elseif iSlice>d2
                    hModel.setValueAt(d2,modifiedRow,4);
                    userData.sample_data{ii}.variables{jj}.iSlice = d2;
                else
                    userData.sample_data{ii}.variables{jj}.iSlice = iSlice;
                end
            end
        end
    end
end

% gather up list of variables that will be plotted
plotVarNames = {};
for ii=1:numel(userData.sample_data) % loop over files
    iVars = find(userData.sample_data{ii}.variablePlotStatus > 0)';
    if ~isempty(iVars)
        markedVarNames = arrayfun(@(x) userData.sample_data{ii}.variables{x}.name, iVars, 'UniformOutput', false);
        plotVarNames = {plotVarNames{:} markedVarNames{:}};
    end
end
plotVarNames = sort(unique(plotVarNames));
userData.plotVarNames = plotVarNames;

% model = getOriginalModel(handles.jtable);
% model.groupAndRefresh;
% handles.jtable.repaint;

setappdata(ancestor(hObject,'figure'), 'UserData', userData);

plotData(ancestor(hObject,'figure'));

% release rentrancy flag
hash.remove(hObject);

end  % tableChangedCallback


