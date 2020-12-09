function sample_data = updateDeploymentNumber(sample_data)
%UPDATEDEPLOYMENTNUMBER enumerate labels of instruments by number of times deployed

all_instrument_serial_no = cellfun(@(x) x.meta.instrument_serial_no, sample_data, 'UniformOutput', false);

% count up number of deployments per instrument serial number
% idea from https://au.mathworks.com/matlabcentral/fileexchange/23333-determine-and-count-unique-values-of-an-array
x = sort(all_instrument_serial_no(:));
uniqueLocs = [true;~strcmp(x(1:end-1),x(2:end)) ~= 0];
uniqueSerials = x(uniqueLocs);
numUnique = diff([find(uniqueLocs);length(x)+1]);

for i=1:length(uniqueSerials)
    ind = find(strcmp(uniqueSerials{i}, all_instrument_serial_no));
    depNum = 1;
    for j = ind
        depLabel = [sample_data{j}.meta.instrument_serial_no '#' num2str(depNum)];
        sample_data{j}.meta.EP_instrument_serial_no_deployment = depLabel;
        sample_data{j}.meta.EP_instrument_deployment = depNum;
        depNum = depNum + 1;
    end
end

end