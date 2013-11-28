
%select file
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.cnv', 'Choose CTD files:','MultiSelect','on');

if ischar(FILENAME)
    importOneCTDSB19(FILENAME,PATHNAME);
else
    for i=1:length(FILENAME)
        importOneCTDSB19(FILENAME{i},PATHNAME);
    end
end

clear FILENAME PATHNAME FILTERINDEX i



