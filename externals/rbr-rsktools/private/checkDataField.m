function checkDataField(RSK)

if ~isfield(RSK,'data')
    RSKerror('RSK structure do not contain any data, try RSKreaddata or RSKreadprofiles first.')
end

end