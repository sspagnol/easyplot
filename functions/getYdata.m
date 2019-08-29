function ydataVar = getYdata(varStruct, useQCflags)
%GETXDATA get y-data to plot

if isvector(varStruct.data)
    % 1D var
    ydataVar = varStruct.data;
    theOffset = varStruct.EP_OFFSET;
    theScale = varStruct.EP_SCALE;
    ydataVar = theOffset + (theScale .* ydataVar);
    
    if useQCflags && isfield(varStruct, 'flags')
        varFlags = varStruct.flags;
        iGood = ismember(varFlags, goodFlags);
        ydataVar(~iGood) = NaN;
    end
else
    % 2D var
    EP_iSlice = varStruct.EP_iSlice;
    ydataVar = varStruct.data(:,EP_iSlice);
    theOffset = varStruct.EP_OFFSET;
    theScale = varStruct.EP_SCALE;
    ydataVar = theOffset + (theScale .* ydataVar);
    if useQCflags && isfield(varStruct, 'flags')
        varFlags = varStruct.flags(:,EP_iSlice);
        iGood = ismember(varFlags, goodFlags);
        ydataVar(~iGood) = NaN;
    end
end

end

