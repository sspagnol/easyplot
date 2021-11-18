function parserList = initParserList
%initParserList initialize simple structure listing available parsers

% This is what I am working toward, parsers can be 'queried' for some info
% and file extensions supported
% parsers=listParsers;
% structs={};
% for ii=1:numel(parsers)
%     parser=getParser(parsers{ii});
%     structs{end+1}=parser('info');
% end
% aStr=cellfun(@(x) x.short_message, structs, 'UniformOutput', false);
% [choice, idx]=optionDialog('Choose instument type','Choose instument type',aStr,1);

parserList = struct;
% But for the moment have this list of instruments and their parsers
ii=0;

% csv file of fully qualified filename and parser to use
ii=ii+1;
parserList.name{ii}='File list (csv)';
parserList.wildcard{ii}={'*.csv'};
parserList.message{ii}='Choose file list:';
parserList.parser{ii}='fileListParse';

ii=ii+1;
parserList.name{ii}='AquaTec (csv)';
parserList.wildcard{ii}={'*.csv'};
parserList.message{ii}='Choose AquaTec csv files:';
parserList.parser{ii}='aquatecParse';

ii=ii+1;
parserList.name{ii}='Citadel CTD (csv)';
parserList.wildcard{ii}={'*.csv'};
parserList.message{ii}='Choose Citadel CTD csv files:';
parserList.parser{ii}='citadelParse';

ii=ii+1;
parserList.name{ii}='HOBO U20/U22 Pres/Temp (csv)';
parserList.wildcard{ii}={'*.csv'};
parserList.message{ii}='Choose HOBO U22 csv files:';
parserList.parser{ii}='hoboU2xParse';

ii=ii+1;
parserList.name{ii}='InterOcean S4 (s4a,s4b)';
parserList.wildcard{ii}={'*.s4a', '*.s4b'};
parserList.message{ii}='Choose InterOcean S4 s4a/s4b files:';
parserList.parser{ii}='InterOceanS4Parse';

ii=ii+1;
parserList.name{ii}='JCU Marotte (csv)';
parserList.wildcard{ii}={'*.csv'};
parserList.message{ii}='Choose Marotte csv files:';
parserList.parser{ii}='MarotteParse';

ii=ii+1;
parserList.name{ii}='Netcdf IMOS toolbox (nc)';
parserList.wildcard{ii}={'*.nc'};
parserList.message{ii}='Choose Netcdf *.nc files:';
parserList.parser{ii}='netcdfParse';

ii=ii+1;
parserList.name{ii}='Netcdf IMOS Aggregate (nc)';
parserList.wildcard{ii}={'*.nc'};
parserList.message{ii}='Choose Netcdf *.nc files:';
parserList.parser{ii}='netcdfAggParse';

ii=ii+1;
parserList.name{ii}='Netcdf Other (nc)';
parserList.wildcard{ii}={'*.nc'};
parserList.message{ii}='Choose Netcdf *.nc files:';
parserList.parser{ii}='netcdfOtherParse';

ii=ii+1;
parserList.name{ii}='Nortek AWAC (wpr,wpb)';
parserList.wildcard{ii}={'*.wpr', '*.wpb'};
parserList.message{ii}='Choose Nortek *.wpr, *.wpb files:';
parserList.parser{ii}='awacParse';

ii=ii+1;
parserList.name{ii}='Nortek Continental (wpr,wpb)';
parserList.wildcard{ii}={'*.wpr', '*.wpb'};
parserList.message{ii}='Choose Nortek *.wpr, *.wpb files:';
parserList.parser{ii}='continentalParse';

ii=ii+1;
parserList.name{ii}='Nortek Aquadopp Velocity (aqd)';
parserList.wildcard{ii}={'*.aqd'};
parserList.message{ii}='Choose Nortek *.aqd files:';
parserList.parser{ii}='aquadoppVelocityParse';

ii=ii+1;
parserList.name{ii}='Nortek Aquadopp Profiler (prf)';
parserList.wildcard{ii}={'*.prf'};
parserList.message{ii}='Choose Nortek *.prf files:';
parserList.parser{ii}='aquadoppProfilerParse';

ii=ii+1;
parserList.name{ii}='Nortek Vector (vec)';
parserList.wildcard{ii}={'*.vec'};
parserList.message{ii}='Choose Nortek *.vec files:';
parserList.parser{ii}='vectorParse';

ii=ii+1;
parserList.name{ii}='Nortek Signature (ad2cp)';
parserList.wildcard{ii}={'*.ad2cp'};
parserList.message{ii}='Choose Nortek *.ad2cp files:';
parserList.parser{ii}='signatureParse';

ii=ii+1;
parserList.name{ii}='RBR (txt,dat,rsk)';
parserList.wildcard{ii}={'*.txt', '*.dat', '*.rsk'};
parserList.message{ii}='Choose RBR files:';
parserList.parser{ii}='XRParse_local';

ii=ii+1;
parserList.name{ii}='Reefnet Sensus (csv)';
parserList.wildcard{ii}={'*.csv'};
parserList.message{ii}='Choose SensusUltra files:';
parserList.parser{ii}='sensusUltraParse';

ii=ii+1;
parserList.name{ii}='RTI (mat)';
parserList.wildcard{ii}={'*.mat'};
parserList.message{ii}='Choose RTI files:';
parserList.parser{ii}='rtiParse';

ii=ii+1;
parserList.name{ii}='Teledyne RDI (000,PD0)';
parserList.wildcard{ii}={'*.000', '*.PD0'};
parserList.message{ii}='Choose RDI 000/PD0 files:';
parserList.parser{ii}='workhorseParse';

ii=ii+1;
parserList.name{ii}='VMDAS/WinRiverII RDI (000,PD0)';
parserList.wildcard{ii}={'*.000', '*.PD0'};
parserList.message{ii}='Choose RDI 000/PD0 files:';
parserList.parser{ii}='workhorseParse_local';

ii=ii+1;
parserList.name{ii}='SBE37 (asc)';
parserList.wildcard{ii}={'*.asc'};
parserList.message{ii}='Choose SBE37 files:';
parserList.parser{ii}='SBE37Parse';

ii=ii+1;
parserList.name{ii}='SBE37 (cnv)';
parserList.wildcard{ii}={'*.cnv'};
parserList.message{ii}='Choose SBE37 files:';
parserList.parser{ii}='SBE37SMParse';

ii=ii+1;
parserList.name{ii}='SBE39 (asc)';
parserList.wildcard{ii}={'*.asc'};
parserList.message{ii}='Choose SBE39 asc files:';
parserList.parser{ii}='SBE39Parse';

ii=ii+1;
parserList.name{ii}='SBE56 (cnv)';
parserList.wildcard{ii}={'*.cnv'};
parserList.message{ii}='Choose SBE56 cnv files:';
parserList.parser{ii}='SBE56Parse';

ii=ii+1;
parserList.name{ii}='SBE 16/19/39plus (cnv)';
parserList.wildcard{ii}={'*.cnv'};
parserList.message{ii}='Choose CTD cnv files:';
parserList.parser{ii}='SBE19Parse';

ii=ii+1;
parserList.name{ii}='StarmonMini (dat)';
parserList.wildcard{ii}={'*.dat'};
parserList.message{ii}='Choose StarmonMini dat files:';
parserList.parser{ii}='StarmonMiniParse';

ii=ii+1;
parserList.name{ii}='Vemco Minilog-II-T (csv)';
parserList.wildcard{ii}={'*.csv'};
parserList.message{ii}='Choose VML2T *.csv files:';
parserList.parser{ii}='VemcoParse';

ii=ii+1;
parserList.name{ii}='Wetlabs (FL)NTU (raw)';
parserList.wildcard{ii}={'*.raw'};
parserList.message{ii}='Choose (FL)NTU *.raw files:';
parserList.parser{ii}='ECOTripletParse';

ii=ii+1;
parserList.name{ii}='WQM (raw, dat)';
parserList.wildcard{ii}={'*.dat', '*.raw'};
parserList.message{ii}='Choose WQM files:';
parserList.parser{ii}='WQMParse';

ii=ii+1;
parserList.name{ii}='InsituMarineOptics sensors (log, txt)';
parserList.wildcard{ii}={'*.log', '*.txt'};
parserList.message{ii}='Choose IMO files:';
parserList.parser{ii}='IMOParse';

end

