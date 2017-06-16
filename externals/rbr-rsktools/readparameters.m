function RSK = readparameters(RSK)

% readparameters - Reads the parameters and only keeps current values.
%
% Syntax:  RSK = readparameters(RSK)
%
% readparameters will read the table that contains it's parameters
% information and add it to the RSK. If there are many sets of parameter
% data, it will select the most recent/current values.
%
% Inputs:
%    RSK - Structure containing some logger metadata.
%
% Output:
%    RSK - Structure containing previously present logger metadata as well
%          as parameters
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-24

RSK.parameters = mksqlite('select * from parameters');

if iscompatibleversion(RSK, 1, 13, 4)
    RSK.parameterKeys = mksqlite('select * from parameterKeys'); 
    if length(RSK.parameters) > 1
        [~, currentidx] = max([RSK.parameters.tstamp]);
        currentparamId = RSK.parameters(currentidx).parameterID;
        currentvalues = ([RSK.parameterKeys.parameterID] == currentparamId);
        RSK.parameterKeys = RSK.parameterKeys(currentvalues);
    end
else
    [~, currentidx] = max([RSK.parameters.tstamp]);
    RSK.parameters = RSK.parameters(currentidx);
end


end