function [ sam ] = workhorseParseCleanup( sam )
%workhorseParseCleanup Easyplot struct cleanup

% make instrument_model a little shorter
sam.meta.instrument_model = strtrim(strrep(sam.meta.instrument_model, 'Sentinel or Monitor', ''));
sam.meta.instrument_model = strtrim(strrep(sam.meta.instrument_model, 'Workhorse ADCP', 'RDI'));
sam.meta.instrument_model = strtrim(strrep(sam.meta.instrument_model, 'Long Ranger', ''));

end

