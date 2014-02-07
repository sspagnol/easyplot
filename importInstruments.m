%%
ii=1;
theList.name{ii}='RBR';
theList.wildcard{ii}='*.txt';
theList.message{ii}='Choose TR1060/TDR2050 files:';
theList.parser{ii}='XRParse';

ii=ii+1;
theList.name{ii}='WQM';
theList.wildcard{ii}='*.dat';
theList.message{ii}='Choose WQM files:';
theList.parser{ii}='WQMParse';

ii=ii+1;
theList.name{ii}='SBE37';
theList.wildcard{ii}='*.cnv';
theList.message{ii}='Choose SBE37 files:';
theList.parser{ii}='SBE37SMParse';

ii=ii+1;
theList.name{ii}='SBE39';
theList.wildcard{ii}='*.asc';
theList.message{ii}='Choose SBE39 files:';
theList.parser{ii}='SBE39Parse';

ii=ii+1;
theList.name{ii}='SBE56';
theList.wildcard{ii}='*.cnv';
theList.message{ii}='Choose SBE56 files:';
theList.parser{ii}='SBE56Parse';

ii=ii+1;
theList.name{ii}='SBE CTD cnv';
theList.wildcard{ii}='*.cnv';
theList.message{ii}='Choose CTD cnv files:';
theList.parser{ii}='SBE19Parse';

ii=ii+1;
theList.name{ii}='RDI';
theList.wildcard{ii}='*.000';
theList.message{ii}='Choose RDI 000 files:';
theList.parser{ii}='workhorseParse';

%%

iParse=menu('Choose instrument type',theList.name);
fhandle = str2func(theList.parser{iParse});

[FILENAME, PATHNAME, FILTERINDEX] = uigetfile(theList.wildcard{iParse}, theList.message{iParse}, 'MultiSelect','on');

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
        sample_data{end+1} = fhandle( {fullfile(PATHNAME,FILENAME{ii})}, 'timeseries' );
    else
        disp(['File ' char(FILENAME{ii}) ' already loaded.']);
    end
end

clear FILENAME PATHNAME FILTERINDEX ii