function [treePanelData] = generateTreeData(sample_data)
%GENERATETREEDATA Create cell array for treeTable data

treePanelData={};
kk=1;
for ii=1:numel(sample_data)
    for jj = [find(sample_data{ii}.isPlottableVar)]
        %  group-by-instrument, group-by-file, group-by-serial, variable,
        %  visible, slice
        treePanelData{kk,1} = sample_data{ii}.meta.instrument_model_shortname;
        treePanelData{kk,2} = [sample_data{ii}.inputFile sample_data{ii}.inputFileExt];
        treePanelData{kk,3} = sample_data{ii}.meta.instrument_serial_no;
        treePanelData{kk,4} = sample_data{ii}.variables{jj}.name;
        treePanelData{kk,5} = sample_data{ii}.variablePlotStatus(jj) > 0;
        treePanelData{kk,6} = sample_data{ii}.variables{jj}.iSlice;
        
        kk=kk+1;
    end
end
end
