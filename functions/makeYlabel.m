function yLabel = makeYlabel( short_name, long_name, uom )
%makeYlabel Attempt to make a nice multiline ylabel

%ylabel(hAx(ii),{strrep(short_name,'_','\_'), [strrep(long_name,'_','\_') ' (' strrep(uom,'_','\_') ')']});

% decide where to cut the Y label to display it on 1 or 2 lines
% depending on the number of words obtained from the variable name
%yLabel = regexp(long_name, '\_', 'split');
% don't split EP_var type names or PRES_REL, order is important, leave
% '[a-zA-Z]+' string at the end of grouping eg
% 'LPF_EP_DEPTH_demeaned' => 'LPF', 'EP_DEPTH, 'demeaned'
yLabel = regexp(long_name, '(?:(EP_[a-zA-Z]+|PRES_REL|[a-zA-Z]+))', 'match');

if numel(yLabel) < 4
    nthWordToCut = min(2, numel(yLabel));
elseif numel(yLabel) < 6
    nthWordToCut = 3;
else
    nthWordToCut = 4;
end
yLabel = {strjoin(yLabel(1:nthWordToCut),     ' '), ...
    strjoin(yLabel(nthWordToCut+1:end), ' ')};
yLabel = yLabel(~cellfun(@isempty, yLabel));

yLabel{end+1} = strrep(uom, '_', ' ');
iLength = 15; % arbitrary string cutoff length
%iLong = strlength(yLabel) > iLength; % only R2016b onwards
iLong = cellfun(@length, yLabel) > iLength;
yLabel(iLong) = cellfun(@(x) [x(1:iLength) '...'], yLabel(iLong), 'UniformOutput', false);

end

