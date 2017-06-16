function hdls = RSKplotthumbnail(RSK)

% RSKplotthumbnail - Plot summaries of logger data thumbnails
%
% Syntax:  [hdls] = RSKplotthumbnail(RSK)
% 
% This generates a summary plot of the thumbnail data in the RSK
% structure. This is usually a plot of about 4000 points.  Each time
% value has a max and a min data value so that all spikes are visible
% even though the dataset is down-sampled.
% 
% Inputs:
%    RSK - Structure containing the logger metadata and thumbnails
%
% Output:
%    hdls - The line object of the plot.
%
% Example: 
%    RSK = RSKopen('sample.rsk');  
%    RSKplotthumbmail(RSK);  
%
% See also: RSKopen, RSKplotdata, RSKplotburstdata
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-17

field = 'thumbnailData';

if ~isfield(RSK,field)
    disp('You must read a section of thumbnailData in first!');
    disp('Use RSKreadthumnaildata...')
    return
end

hdls = channelsubplots(RSK, field);

end
