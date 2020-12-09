function [sample_data, defaultLatitude] = add_structs_to_sample_data(sample_data, structs, parser_name, defaultLatitude, toolbox_input_file, plotVar)
%ADD_STRUCTS_TO_SAMPLE_DATA add parser structs to sample_data cell array

for k = 1:length(structs)
    structs{k}.meta.parser = parser_name;
    
    [tmpStruct, defaultLatitude] = finaliseDataEasyplot(structs{k}, defaultLatitude, toolbox_input_file);
    
    % Note markPlotVar can be called per struct or full sample_data cell
    % array, so return type is either a struct or cell array
    tmpStruct = markPlotVar(tmpStruct, plotVar, tmpStruct.EP_isNew);
    
    if iscell(tmpStruct)
        sample_data(end+1) = tmpStruct;
    else
        sample_data{end+1} = tmpStruct;
    end
    clear('tmpStruct');
end

end
