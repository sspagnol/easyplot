
%select file
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.txt', 'Choose TR1060/TDR2050 files:','MultiSelect','on');

if ischar(FILENAME)
    FILENAME = {FILENAME};
end

if ~exist('sample_data','var')
    sample_data={};
end

notLoaded=0;
for ii=1:length(FILENAME)
    notLoaded = ~any(cell2mat((cellfun(@(x) ~isempty(strfind(x.toolbox_input_file, char(FILENAME{ii}))), sample_data, 'UniformOutput', false))));
    if notLoaded
        disp(['importing file ', num2str(ii), ' of ', num2str(length(FILENAME)), ' : ', char(FILENAME{ii})]);
        sample_data{end+1} = XRParse( {fullfile(PATHNAME,FILENAME{ii})}, 'timeseries' );
    else
        disp(['File ' char(FILENAME{ii}) ' already loaded.']);
    end
end

clear FILENAME PATHNAME FILTERINDEX ii