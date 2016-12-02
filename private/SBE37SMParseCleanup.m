function [ sam ] = SBE37SMParseCleanup( sam )
%SBE37SMParseCleanup Easyplot struct cleanup

% make instrument_model a little shorter
sam.meta.instrument_model = strtrim(strrep(sam.meta.instrument_model, '-RS232', ''));

end

