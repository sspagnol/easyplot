function [depNum, depLabel] = setDeploymentNumber(sample_data)

instrument_serial_no = sample_data{end}.meta.instrument_serial_no;
other_instrument_serial_no = cellfun(@(x) x.meta.instrument_serial_no, sample_data(1:end-1), 'UniformOutput', false);
iInstruments = strcmp(instrument_serial_no, other_instrument_serial_no);

other_EP_instrument_deployment = cellfun(@(x) x.meta.EP_instrument_deployment, sample_data(1:end-1), 'UniformOutput', false);
other_EP_instrument_deployment = other_EP_instrument_deployment(iInstruments);
other_EP_instrument_deployment = updateIfEmpty(other_EP_instrument_deployment, {0}, other_EP_instrument_deployment);
max_dep = max(other_EP_instrument_deployment{:});

depNum = max_dep + 1;
depLabel = [sample_data{end}.meta.instrument_serial_no '#' num2str(depNum)];

end