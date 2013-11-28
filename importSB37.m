
%select file
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.cnv', 'Choose sb37 files:','MultiSelect','on');

if ischar(FILENAME)
    importOneSB37(FILENAME,PATHNAME);
else
    for i=1:length(FILENAME);
        importOneSB37(FILENAME{i},PATHNAME);
    end
end
clear FILENAME PATHNAME FILTERINDEX i 