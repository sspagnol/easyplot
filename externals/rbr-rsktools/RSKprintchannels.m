function RSKprintchannels(RSK)

% RSKprintchannels - Display channel names and units in rsk structure
%
% Syntax:  RSKprintchannels(RSK)
%
% Inputs: 
%    RSK - Input RSK structure
%
% Outputs:
%    Printed channel names and units in MATLAB command window
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2020-02-05


if isfield(RSK,'instruments') && isfield(RSK.instruments,'serialID') && ...
   isfield(RSK.instruments,'model')

    fprintf('Model: %s\n',RSK.instruments.model);
    fprintf('Serial ID: %d\n',RSK.instruments.serialID);
    try
        [fastPeriod,slowPeriod] = readsamplingperiod(RSK);
        fprintf('Sampling period: fast %0.4f second, slow %0.4f second\n',fastPeriod,slowPeriod);
    catch
        fprintf('Sampling period: %0.3f second\n',readsamplingperiod(RSK));
    end
    
end

channelTable = struct2table(RSK.channels);
channelTable.Properties.VariableNames = {'index','channel','unit'};
channelTable.index = (1:1:height(channelTable))';

disp(channelTable)


end
