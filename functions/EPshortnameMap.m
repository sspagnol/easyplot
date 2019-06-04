function [instrument_model, EP_instrument_model_shortname] = EPshortnameMap()
%EPshortnameMap Provide mapped shortnames

instrument_model = {'Workhorse ADCP', ...
    'ADCP - WORKHORSE SENTINEL NEMO', ...
    'SBE16PLUS V2 SEACAT', ...
    'TEMPERATURE RECORDER', ...
    'SBE56 - TEMPERATURE', ...
    'TEMPERATURE LOGGER SOLO T'};

EP_instrument_model_shortname = {'RDI', ...
    'RDI NEMO', ...
    'SBE16PLUS V2', ...
    'TEMP', ...
    'SBE56', ...
    'SOLO T'};

end

