
%select file
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.cnv', 'Choose CTD files:','MultiSelect','on');

if ischar(FILENAME)
    importOneCTDSBE(FILENAME,PATHNAME);
else
    for i=1:length(FILENAME)
        importOneCTDSBE(FILENAME{i},PATHNAME);
    end
end

clear FILENAME PATHNAME FILTERINDEX i



