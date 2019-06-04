function [treePanelData] = generateTreeData(sample_data)
%GENERATETREEDATA Create cell array for treeTable data

treePanelData={};
kk=1;
for ii=1:numel(sample_data)
    for jj = [find(sample_data{ii}.EP_isPlottableVar)]
        %  group-by-instrument, group-by-file, group-by-serial, variable,
        %  visible, slice
        treePanelData{kk,1} = sample_data{ii}.meta.EP_instrument_model_shortname;
        treePanelData{kk,2} = [sample_data{ii}.EP_inputFile sample_data{ii}.EP_inputFileExt];
        treePanelData{kk,3} = sample_data{ii}.meta.EP_instrument_serial_no_deployment;
        treePanelData{kk,4} = sample_data{ii}.variables{jj}.name;
        treePanelData{kk,5} = sample_data{ii}.EP_variablePlotStatus(jj) > 0;
        treePanelData{kk,6} = sample_data{ii}.variables{jj}.EP_iSlice;
        
        kk=kk+1;
    end
end
end
