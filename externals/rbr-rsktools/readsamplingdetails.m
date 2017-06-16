function RSK = readsamplingdetails(RSK)

% readsamplingdetails - Reads the sampling details of a file based on it's
% mode
%
% Syntax:  RSK = readsamplingdetails(RSK)
%
% readsamplingdetails will read the table that contains it's sampling
% detail, this depends on the mode of the file. The change happened in RSK
% schema v1.13.8.
%
% Inputs:
%    RSK - Structure containing some logger metadata.
%
% Output:
%    RSK - Structure containing previously present logger metadata as well
%          as sampling details
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-03-30

mode = RSK.schedules.mode;

if strcmpi(mode, 'ddsampling')
    modetable = 'directional';
elseif strcmpi(mode, 'fetching')
    return
else 
    modetable = mode;
end

RSK.(modetable) = mksqlite(['select * from ' modetable]);

end