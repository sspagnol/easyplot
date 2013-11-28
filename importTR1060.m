
%select file
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.txt', 'Choose TR1060 files:','MultiSelect','on');

if ischar(FILENAME)
    importOneTR1060(FILENAME,PATHNAME);
else
    for i=1:length(FILENAME);
        importOneTR1060(FILENAME{i},PATHNAME);
    end
end
clear FILENAME PATHNAME FILTERINDEX i 