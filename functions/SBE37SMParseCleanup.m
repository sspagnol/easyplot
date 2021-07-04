function [ sam ] = SBE37SMParseCleanup( sam )
%SBE37SMParseCleanup Easyplot struct cleanup

% make instrument_model a little shorter
sam.meta.EP_instrument_model_shortname = regexprep(sam.meta.instrument_model, '-\w+$', '');

end

