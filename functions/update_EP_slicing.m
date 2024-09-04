function structs = update_EP_slicing(structs)
%UPDATE_EP_SLICING update/add EP slicing info to variables

for ii=1:numel(structs)
    for jj=1:numel(structs(ii).variables)
        switch numel(structs(ii).variables{jj}.dimensions)
            case 1
                structs(ii).variables{jj}.EP_iSlice   = 1;
                structs(ii).variables{jj}.EP_minSlice = 1;
                structs(ii).variables{jj}.EP_maxSlice = 1;
            case 2
                [d1, d2] = size(structs(ii).variables{jj}.data);
                structs(ii).variables{jj}.EP_iSlice   = floor(d2/2);
                structs(ii).variables{jj}.EP_minSlice = 0;
                structs(ii).variables{jj}.EP_maxSlice = d2;
            otherwise
                % have no idea how to slice > 2D array
                structs(ii).variables{jj}.EP_iSlice   = -1;
                structs(ii).variables{jj}.EP_minSlice = -1;
                structs(ii).variables{jj}.EP_maxSlice = -1;
        end
    end
end

end



