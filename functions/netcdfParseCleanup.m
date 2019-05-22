function [ sam ] = netcdfParseCleanup( sam )
%netcdfParseCleanup Easyplot struct cleanup

% make instrument_model string a little shorter for display purposes

instrument_model = {'Workhorse ADCP', ...
    'ADCP - WORKHORSE SENTINEL NEMO', ...
    'SBE16PLUS V2 SEACAT', ...
    'TEMPERATURE RECORDER', ...
    'TEMPERATURE LOGGER SOLO T'};

EP_instrument_model_shortname = {'RDI', ...
    'RDI NEMO', ...
    'SBE16PLUS V2', ...
    'TEMP', ...
    'SOLO T'};

for ii = 1:length(instrument_model)
    if ~isempty(regexp(sam.meta.instrument_model, instrument_model{ii}, 'once'))
        sam.meta.EP_instrument_model_shortname  = regexprep(sam.meta.instrument_model, instrument_model{ii}, EP_instrument_model_shortname{ii});
    end
end
                           
if isempty(sam.meta.instrument_serial_no)
    sam.meta.instrument_serial_no ='?';
end

end

