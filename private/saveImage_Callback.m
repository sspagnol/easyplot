%% --- Executes on button press in saveImage.
function saveImage_Callback(hObject, eventdata, oldHandles)
%SAVEIMAGE_CALLBACK Easyplot save image
%
% hObject    handle to saveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

theParent = ancestor(hObject,'figure');
userData=getappdata(theParent, 'UserData');
gData = guidata(theParent);

if isfield(userData,'sample_data') && numel(userData.sample_data) > 0
    [FILENAME, PATHNAME, FILTERINDEX] = uiputfile('*.png', 'Filename to save png');
    if isequal(FILENAME,0) || isequal(PATHNAME,0)
        disp('No file selected.');
    else
        %print(handles.axes1,'-dpng','-r300',fullfile(PATHNAME,FILENAME));
        export_fig(fullfile(PATHNAME,FILENAME),'-png',gData.axes1);
    end
    %uiresume(handles.figure1);
end

ButtonName = questdlg('Export MATLAB fig?', ...
                         'Export MATLAB fig', ...
                         'YES', 'NO', 'NO');
   switch ButtonName,
     case 'YES',
      saveas(theParent, fullfile(PATHNAME,regexprep(FILENAME,'\.png','\_ep\.fig','ignorecase')), 'fig');
      %savefig(theParent, fullfile(PATHNAME,regexprep(FILENAME,'\.png','\.fig','ignorecase')));
   end % switch
end


