%import sb16plus V2.0c data
%each sb16 sensor is loaded separatly into the workspace
%no auxialary sensor
%SB16 data must be in the format:
%'Conductivity' 'Pressure' 'Temp' ' time elapsed in% second' 'Flag'

%Mederic MAINSON.

function[]=importOneSB16plus(FILENAME,PATHNAME)

    fid = fopen(fullfile(PATHNAME, FILENAME));
    
    tline = fgetl(fid);
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

    fclose(fid);
    
    % prepend SBE16 string if required and sanitize to make a valid workspace variable
    % name
    [PATHSTR,tempVarName,EXT]=fileparts(FILENAME);
    if isempty(strfind(upper(tempVarName),'SBE16'))
        tempVarName=strcat('SBE16_',tempVarName);
    end
    tempVarName=genvarname(tempVarName);
    
    %evaluate time vector for associated set of data
    timeNumVector=startingDateNum+(data{4})/(60*60*24);
    
    %assign temprature variable names and values
    assignin('base', strcat('TEMP_',tempVarName), [timeNumVector,data{3}]); 
    
    %assign Pressure variable names and values
    assignin('base', strcat('PRES_REL_',tempVarName), [timeNumVector,data{2}]);

    %assign Conductivity variable names and values
    assignin('base', strcat('CNDC_',tempVarName), [timeNumVector,data{1}]);
    
    
    