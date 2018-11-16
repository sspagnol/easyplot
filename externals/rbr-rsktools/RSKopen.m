function [RSK, dbid] = RSKopen(fname, varargin)

% RSKopen - Open an RBR RSK file and read metadata and downsample, if exists.
%
% Syntax:  [RSK, dbid] = RSKopen(fname, [OPTIONS])
% 
% Makes a connection to an RSK (SQLite format) database as obtained from an
% RBR logger and reads in the instrument metadata as well as downsample of
% the stored data. RSKopen assumes only a single instrument deployment is
% in the RSK file. The downsample table will not exist when the data
% contains less than 40960 samples per channel. It is a downsample of the
% full range of data, for a quick review of the original data.
%
% Requires a working mksqlite library. We have included a couple of
% versions here for Windows (32/64 bit), Linux (64 bit) and Mac (64 bit),
% but you might need to compile another version.  The mksqlite-src
% directory contains everything you need and some instructions from the
% original author.  You can also find the source through Google.
%
% Inputs:
%    [Required] - fname - Filename of the RSK database.
%
%    [Optional] - readHiddenChannels - Read hidden channel when set as
%                                      true, default is false.
%
% Outputs:
%    RSK - Structure containing the logger metadata.
%
%    dbid - Database id returned from mksqlite.
%
% Example: 
%    rsk = RSKopen('sample.rsk');  
%
% See also: RSKreaddata, RSKreadprofiles.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-10-03


p = inputParser;
addRequired(p,'fname',@ischar);
addOptional(p,'readHiddenChannels', false, @islogical)
parse(p, fname, varargin{:})

fname = p.Results.fname;
readHiddenChannels = p.Results.readHiddenChannels;

loadconstants

if nargin==0
    [file, path] = uigetfile({'*.rsk','*.RSK'},'Choose an RSK file');
    fname = fullfile(path, file);
elseif isempty(dir(fname))
    disp('File cannot be found')
    RSK=[];dbid=[];
    return
end

RSK.toolSettings.filename = fname;
RSK.toolSettings.readHiddenChannels = readHiddenChannels;

RSK.dbInfo = doSelect(RSK, 'select version,type from dbInfo');

if iscompatibleversion(RSK, latestRSKversionMajor, latestRSKversionMinor, latestRSKversionPatch+1)
    warning(['RSK version ' latestRSKversion ' is newer than your RSKtools version. It is recommended to update RSKtools at https://rbr-global.com/support/matlab-tools']);
end

RSK = readstandardtables(RSK);
switch RSK.dbInfo(end).type
    case 'EasyParse'
        RSK = readheaderEP(RSK);
    case 'EPdesktop'
        RSK = readheaderEPdesktop(RSK);
    case 'skinny'
        RSK = readheaderskinny(RSK);
    case 'full'
        RSK = readheaderfull(RSK);
    case 'live'
        RSK = readheaderlive(RSK);
    otherwise
        % do nothing
end

RSK = getprofiles(RSK);

RSK = readannotations(RSK);

logentry = [fname ' opened using RSKtools v' RSKtoolsversion '.'];
RSK = RSKappendtolog(RSK, logentry);

end