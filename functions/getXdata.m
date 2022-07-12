function xdataVar = getXdata(varStruct)
%GETXDATA get xdata to plot

xdataVar = varStruct.data;
theOffset =varStruct.EP_OFFSET;
theScale = varStruct.EP_SCALE;
xdataVar = theOffset + (theScale .* xdataVar);

% remove linear drift of time (in days) from any instrument.
% the drift is calculated using the start offset (offset_s in seconds) and the
% end offset (offset_e in seconds).
try
    offset_s = varStruct.EP_StartOffset;
    offset_e = varStruct.EP_StopOffset;
catch
    offset_s = 0.0;
    offset_e = 0.0;
end
% calculate the offset times in days:
offset_days_e = offset_e/60/60/24;
offset_days_s = offset_s/60/60/24;

if offset_e == offset_s % then just remove the start time
    xdataVar = xdataVar - offset_days_s;
else
    % make an array of time corrections using the offsets:
    tarray = (offset_days_s:(offset_days_e-offset_days_s)/(length(xdataVar)-1):offset_days_e)';
    xdataVar = xdataVar - tarray;
end

end

