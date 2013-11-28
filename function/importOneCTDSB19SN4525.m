%import sb19plus #4525 data according to sensors configuration in May2013
%each sb19 sensor is loaded separatly into the workspace
%for this function to work, data must be converted from hex to cnv using
%seabird data proc with this setup file:
%\\FERGIE-PC\Data\Trip5703\Data\CTD\DatCnvCTD_SB19_4525.psa
%output variablles  would then be in this order:
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

function[]=importOneCTDSB19SN4525(FILENAME,PATHNAME)

    fid = fopen([PATHNAME, FILENAME]);
    
    tline = fgetl(fid);
    %look for starting date line in header
    while isempty(strfind (tline,'# start_time = '))
        tline = fgetl(fid);
    end
    
    %extract starting date from starting date line
    startingDate=sscanf(tline,'# start_time = %s %s %s %s:%s:%s [Instrument''s time stamp, header]');
    
    %convert starting date into serial date
    startingDateNum = datenum(startingDate, 'mmmddyyyyHH:MM:SS');
    
   
    %get to the end of header line
    while 0==strcmp(tline,'*END*')
        tline = fgetl(fid);
    end
    
    %Import data into temporary cell array
    data = textscan(fid, '%f %f %f %f %f %f %f %f %f');
    
    tempVarName= FILENAME(1:end-4);
    %clean varname from the end to make it a valid variable name in the workspace
    while isvarname(tempVarName)==0;
        tempVarName=tempVarName(1:end-1);
    end
    
    %evaluate time vector for associated set of data
    timeNumVector=startingDateNum+(data{8})/(60*60*24);
    
    %assign Pressure variable names and values
    assignin('base', strcat('P',tempVarName), [timeNumVector,data{1}]);
    
    %assign temprature variable names and values
    assignin('base', strcat('T',tempVarName), [timeNumVector,data{2}]); 

    %assign Conductivity variable names and values
    assignin('base', strcat('C',tempVarName), [timeNumVector,data{3}]);
    
    %assign DO variable names and values
    assignin('base', strcat('DO',tempVarName), [timeNumVector,data{4}]);
    
    %assign beam transmission variable names and values
    assignin('base', strcat('Tr',tempVarName), [timeNumVector,data{5}]);
    
    %assign Fluo variable names and values
    assignin('base', strcat('Fl',tempVarName), [timeNumVector,data{6}]);
    
    %assign Par variable names and values
    assignin('base', strcat('Par',tempVarName), [timeNumVector,data{7}]);
    
    
    