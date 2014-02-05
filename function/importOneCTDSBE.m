%import sb19 data
%each sb19 sensor is loaded separatly into the workspace
%SB19 data must be in the format:
% for sbe19 w/o DO
% 'Pressure' 'Temp' 'Conductivity' ' time elapsed in% second' 'Flag'
% # name 0 = prdM: Pressure, Strain Gauge [db]
% # name 1 = tv290C: Temperature [ITS-90, deg C]
% # name 2 = c0S/m: Conductivity [S/m]
% # name 3 = timeS: Time, Elapsed [seconds]
% # name 4 = flag:  0.000e+00

% for sbe19 with DO or sbe25
% # name 0 = prdM: Pressure, Strain Gauge [db]
% # name 1 = tv290C: Temperature [ITS-90, deg C]
% # name 2 = c0S/m: Conductivity [S/m]
% # name 3 = sbeox0ML/L: Oxygen, SBE 43 [ml/l]
% # name 4 = xmiss: Beam Transmission, Chelsea/Seatech [%]
% # name 5 = flECO-AFL: Fluorescence, WET Labs ECO-AFL/FL [mg/m^3]
% # name 6 = par: PAR/Irradiance, Biospherical/Licor
% # name 7 = timeS: Time, Elapsed [seconds]
% # name 8 = flag:  0.000e+00

%Mederic MAINSON.

function[]=importOneCTDSBE(FILENAME,PATHNAME)

% from imos-toolbox, parse lines like
% "*  <StatusData DeviceType='SBE16plus' SerialNumber='01607110'>"
% "*  <StatusData DeviceType='SBE25plus' SerialNumber='0251009'>"
headerExpr   = '^\*\s*(SBE \S+|SeacatPlus)\s+V\s+(\S+)\s+SERIAL NO.\s+(\d+)';
headerExpr2  = '<HardwareData DeviceType=''(\S+)'' SerialNumber=''(\S+)''>';
headerExpr3  = '^\*\s*<HardwareData DeviceType=''(\S+)'' SerialNumber=''(\S+)''>';
% '# nquan = 5'
nquanExpr     = '^\#\s*nquan = (\d+)';
exprs = {headerExpr headerExpr2 headerExpr2 nquanExpr};

fid = fopen(fullfile(PATHNAME, FILENAME));

tline = fgetl(fid);
while 0==strcmp(tline,'*END*')
    %look for starting date line in header
    if strfind (tline,'# start_time = ')
        %extract starting date from starting date line
        startingDate=sscanf(tline,'# start_time = %s %s %s %s:%s:%s [Instrument''s time stamp, header]');
    end
    for m = 1:length(exprs)
        % until one of them matches
        tkns = regexp(tline, exprs{m}, 'tokens');
        if ~isempty(tkns)
            % yes, ugly, but easiest way to figure out which regex we're on
            switch m
                % header
                case 1
                    header.instrument_model     = tkns{1}{1};
                    header.instrument_firmware  = tkns{1}{2};
                    header.instrument_serial_no = tkns{1}{3};
                    % header2
                case 2,3
                    header.instrument_model     = tkns{1}{1};
                    header.instrument_serial_no = tkns{1}{2};
                case 4
                    header.nquan= str2num(tkns{1}{1});
            end
            break;
        end
    end
    
    tline = fgetl(fid);
end

%convert starting date into serial date
startingDateNum = datenum(startingDate, 'mmmddyyyyHH:MM:SS');

%Import data into temporary cell array
str=repmat('%f ',[1 header.nquan]);
data = textscan(fid, str);

fclose(fid);

%clean varname from the end to make it a valid variable name in the workspace
tempVarName=strcat(header.instrument_model, '_', header.instrument_serial_no);

%evaluate time vector for associated set of data
timeNumVector=startingDateNum+(data{4})/(60*60*24);

ii=1;
%assign Pressure variable names and values
assignin('base', strcat('PRES_REL_',tempVarName), [timeNumVector,data{ii}]);
ii=ii+1;

%assign temprature variable names and values
assignin('base', strcat('TEMP_',tempVarName), [timeNumVector,data{ii}]);
ii=ii+1;

%assign Conductivity variable names and values
assignin('base', strcat('CNDC_',tempVarName), [timeNumVector,data{ii}]);
ii=ii+1;

if header.nquan > 5
    %assign DO variable names and values
    assignin('base', strcat('DOX1_',tempVarName), [timeNumVector,data{ii}]);
    ii=ii+1;
    
    %assign beam transmission variable names and values
    assignin('base', strcat('TR_',tempVarName), [timeNumVector,data{ii}]);
    ii=ii+1;
    
    %assign Fluo variable names and values
    assignin('base', strcat('CHLF_',tempVarName), [timeNumVector,data{ii}]);
    ii=ii+1;
    
    %assign Par variable names and values
    assignin('base', strcat('PAR_',tempVarName), [timeNumVector,data{ii}]);
    
end

