function [ sam ] = netcdfParseCleanup( sam )
%netcdfParseCleanup Easyplot struct cleanup

% make instrument_model string a little shorter for display purposes

[instrument_model, EP_instrument_model_shortname] = EPshortnameMap();

for ii = 1:length(instrument_model)
    if ~isempty(regexp(sam.meta.instrument_model, instrument_model{ii}, 'once'))
        new_instrument_model = regexprep(sam.meta.instrument_model, instrument_model{ii}, EP_instrument_model_shortname{ii});
        sam.meta.instrument_model = new_instrument_model;
        sam.meta.EP_instrument_model_shortname  = new_instrument_model;
    end
end
                           
if isempty(sam.meta.instrument_serial_no)
    sam.meta.instrument_serial_no ='?';
end

end

