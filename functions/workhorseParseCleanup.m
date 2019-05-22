function [ sam ] = workhorseParseCleanup( sam )
%workhorseParseCleanup Easyplot struct cleanup

% make instrument_model string a little shorter for display purposes

%sam.meta.EP_instrument_model_shortname = strtrim(strrep(sam.meta.instrument_model, 'Workhorse ADCP', 'RDI'));
% make all 'blah RDI' == 'RDI'
%sam.meta.EP_instrument_model_shortname = strtrim(regexprep(sam.meta.instrument_model, '.+(?=RDI)', ''));

sam.meta.EP_instrument_model_shortname = 'RDI';
if isempty(sam.meta.instrument_serial_no)
    sam.meta.instrument_serial_no ='RDI';
end

end

