%select file
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.cnv', 'Choose SBE56 files:','MultiSelect','on');

if ischar(FILENAME)
    FILENAME = {FILENAME};
end

iend=0;
if exist('sample_data','var')
    iend=numel(sample_data);
end

notLoaded=0;
for ii=1:length(FILENAME)
    if exist('sample_data','var')
        notLoaded = ~any(cell2mat((cellfun(@(x) ~isempty(strfind(x.toolbox_input_file, char(FILENAME{ii}))), sample_data, 'UniformOutput', false))));
    else
        notLoaded = 1;
    end
    if notLoaded
        disp(['importing file ', num2str(ii), ' of ', num2str(length(FILENAME)), ' : ', char(FILENAME{ii})]);
        sample_data{ii+iend} = SBE56Parse( {fullfile(PATHNAME,FILENAME{ii})}, 'timeseries' );
    else
        disp(['File ' char(FILENAME{ii}) ' already loaded.']);
    end
end

clear FILENAME PATHNAME FILTERINDEX ii