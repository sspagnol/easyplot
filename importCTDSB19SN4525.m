
%select file
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.cnv', 'Choose CTD files:','MultiSelect','on');

if ischar(FILENAME)
    importOneCTDSB19SN4525(FILENAME,PATHNAME);
else
    for i=1:length(FILENAME)
        importOneCTDSB19SN4525(FILENAME{i},PATHNAME);
    end
end

clear FILENAME PATHNAME FILTERINDEX i



