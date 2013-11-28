
%select file
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.txt', 'Choose TDR2050 files:','MultiSelect','on');

if ischar(FILENAME)
    importOneTDR2050(FILENAME,PATHNAME);
else
    for i=1:length(FILENAME);
        importOneTDR2050(FILENAME{i},PATHNAME);
    end
end
clear FILENAME PATHNAME FILTERINDEX i 