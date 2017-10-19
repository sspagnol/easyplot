function [ sam ] = workhorseParseCleanup( sam )
%workhorseParseCleanup Easyplot struct cleanup

% make instrument_model string a little shorter for display purposes

%sam.meta.instrument_model_shortname = strtrim(strrep(sam.meta.instrument_model, 'Workhorse ADCP', 'RDI'));
% make all 'blah RDI' == 'RDI'
%sam.meta.instrument_model_shortname = strtrim(regexprep(sam.meta.instrument_model, '.+(?=RDI)', ''));

sam.meta.instrument_model_shortname = 'RDI';

end

