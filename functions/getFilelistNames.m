%%
function fileListNames = getFilelistNames(sample_data)
%GETFILELISTNAMES make a list of filenames from sample_data structure

% fileListNames={};
% if ~isempty(sample_data)
%     for ii=1:numel(sample_data)
%         %fileListNames{end+1}=[sample_data{ii}.EP_inputFile sample_data{ii}.EP_inputFileExt];
%         fileListNames{end+1}=[sample_data{ii}.meta.instrument_model ' : ' sample_data{ii}.EP_inputFile sample_data{ii}.EP_inputFileExt];
%     end
% end

%instModels = cellfun(@(x) x.meta.instrument_model, sample_data, 'UniformOutput', false)';
instSerials = strtrim(cellfun(@(x) x.meta.instrument_serial_no,sample_data, 'UniformOutput', false)'); 
instShortname = cellfun(@(x) x.meta.EP_instrument_model_shortname, sample_data, 'UniformOutput', false)';
instFile = cellfun(@(x) x.EP_inputFile, sample_data, 'UniformOutput', false)';
instFileExt = cellfun(@(x) x.EP_inputFileExt, sample_data, 'UniformOutput', false)';
%fileListNames = strcat(instModels, '#', instSerials, ' (', instFile, instFileExt, ')');
fileListNames = strcat(instShortname, '#', instSerials, ' (', instFile, instFileExt, ')');

end
