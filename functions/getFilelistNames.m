%%
function fileListNames = getFilelistNames(sample_data)
%GETFILELISTNAMES make a list of filenames from sample_data structure

fileListNames={};
if ~isempty(sample_data)
    for ii=1:numel(sample_data)
        fileListNames{end+1}=[sample_data{ii}.EP_inputFile sample_data{ii}.EP_inputFileExt];
    end
end

end
