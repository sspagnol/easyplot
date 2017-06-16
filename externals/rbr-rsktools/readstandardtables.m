function RSK = readstandardtables(RSK)

% readstandardtables - read tables that are always populated.
%
% Syntax:  [RSK] = readstandardtables(RSK)
%
% readstandardtables is a RSKtools helper function that opens the tables
% that are populated in any file
% These tables are channels, epochs, schedules, deployments and
% instruments.
%
% Inputs:
%    RSK - A RSK structure
%
% Outputs:
%    RSK - Structure containing the standard tables
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-03-31

%% Tables that are definitely in all files
RSK = readchannels(RSK);

RSK.epochs = mksqlite('select deploymentID,startTime/1.0 as startTime, endTime/1.0 as endTime from epochs');
RSK.epochs.startTime = RSKtime2datenum(RSK.epochs.startTime);
RSK.epochs.endTime = RSKtime2datenum(RSK.epochs.endTime);

RSK.schedules = mksqlite('select * from schedules');

RSK.deployments = mksqlite('select * from deployments');

RSK.instruments = mksqlite('select * from instruments');

end
