function hdls = channelsubplots(RSK, field, chanCol)

% channelsubplots - check if profiles are present and outputs the profiles
% if none are provided
%
% Syntax:  [hdls] = channelsubplots(RSK, field, chanCol)
% 
% Generate and plots to a subplot for each channel in the chosen field.
%
% Inputs:
%   RSK - Structure create from an rsk file.
%
%   field - The source of the data to plot. Can be 'burstdata',
%       thumbnailData', or 'data'.
%
%   chanCol - The column number of the channels to be plotted. Only
%       required if all channel are not ebing plotted.
%
% Outputs:
%    hdls - The line object of the plot.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-16


if ~exist('chanCol', 'var')
    chanCol = 1:size(RSK.(field).values,2);
end

numchannels = length(chanCol);

n = 1;
for chan = chanCol
    subplot(numchannels,1,n)
    hdls(n) = plot(RSK.(field).tstamp, RSK.(field).values(:,chan),'-');
    title(RSK.channels(chan).longName);
    ylabel(RSK.channels(chan).units);
    ax(n)=gca;
    datetick('x')
    n = n+1 ;
end

linkaxes(ax,'x')
shg

end