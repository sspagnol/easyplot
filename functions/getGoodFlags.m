function goodFlags = getGoodFlags()

%% retrieve good flag values
qcSet     = str2double(readProperty('toolbox.qc_set'));
rawFlag   = imosQCFlag('raw', qcSet, 'flag');
goodFlag  = imosQCFlag('good', qcSet, 'flag');
goodFlags = int8([rawFlag, goodFlag]);

end