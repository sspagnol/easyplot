%import tdr2050 data
%pressure and temp are loaded separatly into the workspace
%tdr2050 data must be a dataset export as a engineering Rtext (see ruskin software):


%Mederic MAINSON.

function[]=importOneTDR2050(FILENAME,PATHNAME)

    fid = fopen([PATHNAME, FILENAME]);
    
    %look for starting date line in header
    tline = '';
    while isempty(strfind (tline,'LoggingStartTime'))
        tline = fgetl(fid);
    end
    
    
    %extract starting date from starting date line
    %ex:   LoggingStartTime=30-Jan-2013 00:00:00.000
    startingDate=sscanf(tline,'LoggingStartTime=%s%c%s');
    %convert starting date into serial date
    startingDateNum = datenum(startingDate, 'dd-mmm-yyyy HH:MM:SSFFF');
    
    %look for sampling interval line in header
    %ex: LoggingSamplingPeriod=00:01:00
    while isempty(strfind (tline,'LoggingSamplingPeriod'))
        tline = fgetl(fid);
    end
    %extract sampling interval
    samplingInterval=sscanf(tline,'LoggingSamplingPeriod=%d:%d:%d');
    samplingInterval=samplingInterval(3)+60*(samplingInterval(2)+60*samplingInterval(1));
    %get to the end of header line
    while isempty(strfind(tline,'Date & Time'))
        tline = fgetl(fid);
    end
    
    %Import data into temporary cell array
    data = textscan(fid, '%*s %*s %f %f %*f');
    
    %create serialTimeVector
    serialTimeVector = ((((1:length(data{1}))*samplingInterval)/(60*60*24))+startingDateNum)';
    
    
    %assign temperature variable names and values
    assignin('base', strcat('T',FILENAME(1:end-4)), [serialTimeVector , data{1}]); 
    
    %assign Pressure variable names and values
    assignin('base', strcat('P',FILENAME(1:end-4)), [serialTimeVector , data{2}]);