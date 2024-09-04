function structs = update_EP_axis_types(structs)
%UPDATE_EP_AXIS_TYPE update/add a variables axis type (1 = 1D with TIME, or
%2D

for ii = 1:numel(structs)
    nvars = numel(structs(ii).variables);
    structs(ii).EP_axis_types = zeros([nvars, 1]);
    for jj = 1:nvars
        if isvector(structs(ii).variables{jj}.data)
            structs(ii).EP_axis_types(jj) = 1;
        elseif ismatrix(structs(ii).variables{jj}.data)
            structs(ii).EP_axis_types(jj) = 2;
        end
    end
end

end



