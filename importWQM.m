


%select file
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.dat', 'Choose wqm files:','MultiSelect','on');

if ischar(FILENAME)
    importOneWqm(FILENAME,PATHNAME);
else
    for i=1:length(FILENAME)
        importOneWqm(FILENAME{i},PATHNAME);
    end
end
clear FILENAME PATHNAME FILTERINDEX i

