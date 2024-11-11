function [ sam ] = netcdfParseCleanup( sam )
%netcdfParseCleanup Easyplot struct cleanup

% make instrument_model string a little shorter for display purposes

shortname_map = EPshortnameMap();
names = shortname_map.keys;
values = shortname_map.values;
   
sam_desc = genSampleDataDesc(sam, 'medium');
sam_desc = strtrim(sam_desc(1:strfind(sam_desc,'(')-1));
tf = ~cellfun(@isempty, regexpi(sam_desc, names));
if any(tf)
   ind = find(tf);
   sam_desc = strrep(sam_desc, names{ind}, values{ind});
end
sam.meta.instrument_model;
sam.meta.EP_instrument_model_shortname  = sam_desc;
                           
if isempty(sam.meta.instrument_serial_no)
    sam.meta.instrument_serial_no ='?';
end

end

