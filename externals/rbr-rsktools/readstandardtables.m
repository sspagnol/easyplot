function RSK = readstandardtables(RSK)

%READSTANDARDTABLES- Read tables that are populated in all .rsk files.
%
% Syntax:  [RSK] = READSTANDARDTABLES(RSK)
%
% Opens the tables that are populated in any file. These tables are
% channels, epochs, schedules, deployments and instruments.
%
% Inputs:
%    RSK - Structure opened using RSKopen.m.
%
% Outputs:
%    RSK - Structure containing the standard tables.
%
% See also: RSKopen.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-06-21

RSK = readchannels(RSK);

RSK.epochs = mksqlite('select deploymentID,startTime/1.0 as startTime, endTime/1.0 as endTime from epochs');
RSK.epochs.startTime = RSKtime2datenum(RSK.epochs.startTime);
RSK.epochs.endTime = RSKtime2datenum(RSK.epochs.endTime);

RSK.schedules = mksqlite('select * from schedules');

RSK.deployments = mksqlite('select * from deployments');

RSK.instruments = mksqlite('select * from instruments');

end
