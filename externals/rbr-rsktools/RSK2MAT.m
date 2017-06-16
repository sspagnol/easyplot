function [RBR] = RSK2MAT(RSK)

% RSK2MAT - Creates a structure array from a RSK structure.
%
% Syntax: [RBR] = RSK2MAT(RSKfile)
%
% RSK2MAT converts the regular RSK structure format to the legacy .mat RBR
% structure array. The output structure (RBR) is similar to the .mat file
% generated by Ruskin but is missing some fields: comments,
% serialstarttime/serialendtime, derived channels, events, parameters and
% sample code.
%
% NOTE: This function is to be used if you previously have been using the .mat
% export from Ruskin and already have functions set up to work with this
% layout. If possible use the .rsk files directly.
% 
%
% Inputs:
%    RSK - Structure containing the logger metadata, along with the
%          added 'data' fields.
%
% Outputs:
%    RBR - Structure containing the logger data and some metadata in the
%          same format as the .mat files exported by Ruskin.
%
% Example:
%   RSK = RSKopen(fname);
%   RSK = RSKreaddata(RSK);
%   RBR = RSK2MAT(RSK);
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-03-30

%% Notify user that RSK2MAT doesn't work for file that were previously EasyParse
if strcmpi(RSK.dbInfo(1).type, 'EasyParse');
    error('RSK2MAT is not compatible with files that are from Ruskin Mobile . File should be opened in Ruskin Desktop first.')
end


%% Firmware Version location is dependant on the rsk file version
[firmwareV, ~, ~]  = RSKfirmwarever(RSK);


%% Set up metadata
RBR.name = ['RBR ' RSK.instruments.model ' ' firmwareV ' ' num2str(RSK.instruments.serialID)];

% Sample period
RBR.sampleperiod = RSKsamplingperiod(RSK); 

% Channels
RBR.channelnames = {RSK.channels.longName}';
RBR.channelunits = {RSK.channels.units}';
try
    RBR.channelranging = {RSK.ranging.mode}';
catch
end

% Epochs
RBR.starttime = datestr(RSK.epochs.startTime, 'dd/mm/yyyy HH:MM:SS PM');
RBR.endtime = datestr(RSK.epochs.endTime, 'dd/mm/yyyy HH:MM:SS PM');


%% Set up coefficients table
nchannels = length(RBR.channelnames);
% Salinity adds a channel but does not have calibration coefficients

hasS = any(strcmp({RSK.channels.longName}, 'Salinity'));
if hasS
    nchannels = nchannels-1;
end

if ~strcmp(RSK.dbInfo(end).type, 'EPdesktop') && ~strcmp(RSK.dbInfo(end).type, 'live')%EPdesktop & live does not have calibration table
    % Only shows first 4 coefficients (c0, c1, c2 & c3).
    RSK = RSKreadcalibrations(RSK);
    RBR.coefficients = zeros(4, nchannels);
    for ndx=1:nchannels
        channelindex = find([RSK.calibrations.channelOrder] == ndx);
        coefcell = [{RSK.calibrations(channelindex(end)).c0}; {RSK.calibrations(channelindex(end)).c1}; {RSK.calibrations(channelindex(end)).c2; RSK.calibrations(channelindex(end)).c3}];
        nocoef = cellfun('isempty', coefcell);
        coefcell(nocoef) = {NaN};
        RBR.coefficients(:,ndx) = cell2mat(coefcell);
    end
end


%% Set up data tables
RBR.sampletimes = cellstr(datestr(RSK.data.tstamp, 'yyyy-mm-dd HH:MM:ss.FFF'));
RBR.data = RSK.data.values(:,1:nchannels);


%% Save to mat file
matfile = strrep([num2str(RSK.instruments.serialID) '_' RSK.instruments.model],'.rsk','.mat');
save(matfile, 'RBR', '-v7.3');


end