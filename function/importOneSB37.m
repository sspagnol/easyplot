%import sb37 data
%each sb37 sensor is loaded separatly into the workspace
%SB37 data must be in the format:
% 'Pressure' 'Temp' 'Conductivity' ' time elapsed in% second' 'Flag'

%Mederic MAINSON.

function[]=importOneSB37(FILENAME,PATHNAME)

    fid = fopen([PATHNAME, FILENAME]);
    
    
    
    %look for serial number line in header
    tline = fgetl(fid);
    while isempty(strfind (tline,'HardwareData DeviceType=''SBE37SM-RS232'' SerialNumber='))
        tline = fgetl(fid);
    end
    
    %extract serial number from serial number line
    serial=sscanf(tline,'* <HardwareData DeviceType=''SBE37SM-RS232'' SerialNumber=''%d''>');% '%d' should be change to '%s', so we dont have to use num2str() in following lines, couldn't get it working...
    
    %check if a pressure sensor is present 
    %declare psensor is not there, then look for it
    pSensor=0;
    while isempty(strfind (tline,'</InternalSensors>'))
        if isempty(strfind (tline,'<Sensor id=''Pressure''>'))
        tline = fgetl(fid);
        else
        pSensor=1;
        break
        end
    end
    
    %look for starting date line in header
    while isempty(strfind (tline,'# start_time = '))
        tline = fgetl(fid);
    end
    
    %extract starting date from starting date line
    startingDate=sscanf(tline,'# start_time = %s %s %s %s:%s:%s [Instrument''s time stamp, first data scan]');
    
    %convert starting date into serial date
    startingDateNum = datenum(startingDate, 'mmmddyyyyHH:MM:SS');
    
   
    %get to the end of header line
    while 0==strcmp(tline,'*END*')
        tline = fgetl(fid);
    end
    
    %Import data into temporary cell array
    data = textscan(fid, '%f %f %f %f %f');
    
    %evaluate time vector for associated set of data
    % ie: julian day start + (seconds elapsed since start/ #second in one day)
    timeNumVector=startingDateNum+(data{4})/(60*60*24); 
    
    %assign temperature variable names and values
    assignin('base', strcat('T',num2str(serial)), [timeNumVector,data{2}]); 
    
    %assign Pressure variable names and values
    if pSensor==1
        assignin('base', strcat('P',num2str(serial)), [timeNumVector,data{1}]);
    end
    
    %assign Conductivity variable names and values
    assignin('base', strcat('C',num2str(serial)), [timeNumVector,data{3}]);
    
    fclose(fid);




