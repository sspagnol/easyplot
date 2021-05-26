function modifyToolbarButtons(hToolbar)
%modifyToolbarButtons add callbacks to toolbar

% change toolbar button 'Standard.FileOpen' callback
hFileOpenButton = findall(hToolbar,'tag','Standard.FileOpen');
set(hFileOpenButton, 'ClickedCallback','import_Callback(gcbf)', 'TooltipString','Import Data File');

% change toolbar button 'Standard.SaveFigure' callback
hSaveButton = findall(hToolbar,'tag','Standard.SaveFigure');
set(hSaveButton, 'ClickedCallback','saveImage_Callback(gcbf)', 'TooltipString','Save Image');

% change toolbar button 'Standard.NewFigure' callback
hNewFigureButton = findall(hToolbar,'tag','Standard.NewFigure');
set(hNewFigureButton, 'ClickedCallback','clearPlot_Callback(gcbf)', 'TooltipString','Clear Plot');

% hide certain default toolbar entries
for txtTag = {'Exploration.Rotate' 'DataManager.Linking' 'Annotation.InsertLegend' 'Annotation.InsertColorbar'}
    hTag = findall(hToolbar, 'tag', char(txtTag));
    if ~isempty(hTag)
        set(hTag, 'Visible', 'Off');
    end
end

end

