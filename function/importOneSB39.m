%import sb39 data
%each sb39 sensor is loaded separatly into the workspace
%SB3 data must be in the format:
%
%Mederic MAINSON.

function[]=importOneSB39(FILENAME,PATHNAME)

fid = fopen(fullfile(PATHNAME, FILENAME));

%check if a pressure sensor is present
%declare psensor is not there, then look for it
tline = '';
while isempty(strfind (tline,'* SBE 39 configuration ='))
    tline = fgetl(fid);
end
if isempty(strfind (tline,'pressure'))
    pSensor=0;
else
    pSensor=1;
end

%look for starting date line in header
while isempty(strfind (tline,'start time ='))
    tline = fgetl(fid);
end
%extract starting date from starting date line
startingDate=sscanf(tline,'start time =  %s %s %s  %s:%s:%s');
%convert starting date into serial date
startingDateNum = datenum(startingDate, 'ddmmmyyyyHH:MM:SS');

%look for sampling interval line in header
while isempty(strfind (tline,'sample interval ='))
    tline = fgetl(fid);
end
%extract sampling interval
samplingInterval=sscanf(tline,'sample interval = %d seconds');

%get to the end of header line
while isempty(strfind(tline,'start sample number'))
    tline = fgetl(fid);
end

%Import data into temporary cell array
data = textscan(fid, '%f %f %*s %*s','Delimiter',',');

fclose(fid);

%create serialTimeVector
serialTimeVector = ((((1:length(data{1}))*samplingInterval)/(60*60*24))+startingDateNum)';

% %evaluate time vector for associated set of data
% timeNumVector=startingDateNum+(data{4})/(60*60*24);
[PATHSTR,tempVarName,EXT]=fileparts(FILENAME);
if isempty(strfind(upper(tempVarName),'SBE39'))
    tempVarName=strcat('SBE39_',tempVarName);
end
tempVarName=genvarname(tempVarName);

%assign temperature variable names and values
assignin('base', strcat('TEMP_',tempVarName), [serialTimeVector , data{1}]);

%assign Pressure variable names and values
if pSensor==1
    assignin('base', strcat('PRES_',tempVarName), [serialTimeVector , data{2}]);
end