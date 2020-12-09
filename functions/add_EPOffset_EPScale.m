function structs = add_EPOffset_EPScale(structs)

for ns = 1:length(structs)
    for nd=1:numel(structs{ns}.dimensions)
        if ~isfield(structs{ns}.dimensions{nd}, 'EP_OFFSET')
            structs{ns}.dimensions{nd}.EP_OFFSET = 0.0;
            structs{ns}.dimensions{nd}.EP_SCALE = 1.0;
        end
    end
    for nd=1:numel(structs{ns}.variables)
        if ~isfield(structs{ns}.variables{nd}, 'EP_OFFSET')
            structs{ns}.variables{nd}.EP_OFFSET = 0.0;
            structs{ns}.variables{nd}.EP_SCALE = 1.0;
        end
    end
end

end