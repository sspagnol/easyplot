function structs = update_EP_slicing(structs)
%UPDATE_EP_SLICING update/add EP slicing info to variables

for ii=1:numel(structs)
    for jj=1:numel(structs(ii).variables)
        structs(ii).variables{jj}.EP_iSlice   = 1;
        structs(ii).variables{jj}.EP_minSlice = 1;
        structs(ii).variables{jj}.EP_maxSlice = 1;
        if ~isvector(structs(ii).variables{jj}.data)
            [d1, d2] = size(structs(ii).variables{jj}.data);
            structs(ii).variables{jj}.EP_iSlice   = floor(d2/2);
            structs(ii).variables{jj}.EP_minSlice = 1;
            structs(ii).variables{jj}.EP_maxSlice = d2;
        end
    end
end

end



