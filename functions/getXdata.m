function xdataVar = getXdata(varStruct)
%GETXDATA get xdata to plot

xdataVar = varStruct.data;
theOffset =varStruct.EP_OFFSET;
theScale = varStruct.EP_SCALE;
xdataVar = theOffset + (theScale .* xdataVar);

end

