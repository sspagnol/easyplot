%select file
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.cnv', 'Choose sb56 files:','MultiSelect','on');

if ischar(FILENAME)
    importOneSB56(FILENAME,PATHNAME);
else
    for i=1:length(FILENAME);
        importOneSB56(FILENAME{i},PATHNAME);
    end
end
clear FILENAME PATHNAME FILTERINDEX i