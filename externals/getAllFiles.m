function fileList = getAllFiles(dirName, pattern)
%GETALLFILES recursively examine dirName for files matching regexp pattern
%   Detailed explanation goes here
% Modified from some code found on stackexchange.com

dirData = dir(dirName);      % Get the data for the current directory
dirIndex = [dirData.isdir];  % Find the index for directories
fileList = {dirData(~dirIndex).name}';  % Get a list of the files

if ~isempty(fileList)
    % Prepend path to files
    fileList = cellfun(@(x) fullfile(dirName,x),...
        fileList,'UniformOutput',false);
    matchstart = regexp(fileList, pattern);
    fileList = fileList(~cellfun(@isempty, matchstart));
end

% Get a list of the subdirectories
subDirs = {dirData(dirIndex).name};  
% Find index of subdirectories that are not '.' or '..'
validIndex = ~ismember(subDirs,{'.','..'});  

for iDir = find(validIndex)                  % Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    % Get the subdirectory path
    fileList = [fileList; getAllFiles(nextDir,pattern)];  % Recursively call getAllFiles
end

end

