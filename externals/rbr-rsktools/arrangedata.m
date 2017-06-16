function data = arrangedata(results_struct)

% RSKarrangedata - helper function to clean data structures during reading.
% 
% Syntax:  data = arrangedata(results_struct)
% 
% A helper function for arranging data read from an RSK
% SQLite database, and cleaning setting zeros for empty values
% (usually occurs at the beginning of profiling runs when some sensors
% are still settling).
% 
% Inputs: 
%    results_struct - Structure containing the logger data read
%                     from the RSK file.
%
% Outputs:
%    data - Structure containing the arranged logger data, ordered
%           by tstamp.
%
% See also: RSKreaddata, RSKreadevents, RSKreadburstdata, RSKreadthumbnail
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-16

s=struct2cell(results_struct);
data.tstamp = [s{1,:}]';
values = s(2:end,:);

% Clean up empty values, usually while sensors settle.
blanks = cellfun('isempty',values);
values(blanks)={0};

data.values = cell2mat(values)';

end


