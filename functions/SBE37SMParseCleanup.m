function [ sam ] = SBE37SMParseCleanup( sam )
%SBE37SMParseCleanup Easyplot struct cleanup

% make instrument_model a little shorter
%sam.meta.instrument_model_shortname = strtrim(strrep(sam.meta.instrument_model, '-RS232', ''));
sam.meta.instrument_model_shortname = 'SBE37';

end

