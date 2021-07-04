function [ sam ] = SBE37ParseCleanup( sam )
%SBE37PARSECLEANUP Easyplot struct cleanup

% make instrument_model a little shorter
sam.meta.EP_instrument_model_shortname = regexprep(sam.meta.instrument_model, '-', '');

end

