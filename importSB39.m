
%select file
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.asc', 'Choose sb39 files:','MultiSelect','on');

if ischar(FILENAME)
    importOneSB39(FILENAME,PATHNAME);
else
    for i=1:length(FILENAME);
        importOneSB39(FILENAME{i},PATHNAME);
    end
end
clear FILENAME PATHNAME FILTERINDEX i 