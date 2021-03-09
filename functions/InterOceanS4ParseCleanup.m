function [ sam ] = InterOceanS4ParseCleanup( sam )
%InterOceanS4ParseCleanup Easyplot struct cleanup

% make instrument_model string a little shorter for display purposes
sam.meta.EP_instrument_model_shortname = 'S4';
if isempty(sam.meta.instrument_serial_no)
    sam.meta.instrument_serial_no ='S4';
end

end

