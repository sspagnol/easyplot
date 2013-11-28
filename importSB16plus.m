
%select file
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.cnv', 'Choose CTD files:','MultiSelect','on');

if ischar(FILENAME)
    importOneSB16plus(FILENAME,PATHNAME);
else
    for i=1:length(FILENAME)
        importOneSB16plus(FILENAME{i},PATHNAME);
    end
end

clear FILENAME PATHNAME FILTERINDEX i



