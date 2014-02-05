%import sb19 data
%each sb19 sensor is loaded separatly into the workspace
%SB19 data must be in the format:
% 'Pressure' 'Temp' 'Conductivity' ' time elapsed in% second' 'Flag'

%Mederic MAINSON.

function[]=importOneCTDSB19(FILENAME,PATHNAME)

fid = fopen(fullfile(PATHNAME, FILENAME));

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
data = textscan(fid, '%f %f %f %f %f');

fclose(fid);
%clean varname from the end to make it a valid variable name in the workspace
[PATHSTR,tempVarName,EXT]=fileparts(FILENAME);
if isempty(strfind(upper(tempVarName),'SBE19'))
    tempVarName=strcat('SBE19_',tempVarName);
end
tempVarName=genvarname(tempVarName);

%evaluate time vector for associated set of data
timeNumVector=startingDateNum+(data{4})/(60*60*24);

%assign temprature variable names and values
assignin('base', strcat('T',tempVarName), [timeNumVector,data{2}]);

%assign Pressure variable names and values
assignin('base', strcat('P',tempVarName), [timeNumVector,data{1}]);

%assign Conductivity variable names and values
assignin('base', strcat('C',tempVarName), [timeNumVector,data{3}]);


