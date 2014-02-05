
%import WQM data
%each WQM variable is loaded into the workspace

%Mederic MAINSON.

function[]=importOneWqm(FILENAME,PATHNAME)

%open file
fid = fopen(fullfile(PATHNAME,FILENAME));

%look for header
wqmHeader=fgetl(fid);
wqmHeader=textscan(sprintf(wqmHeader), '%s %s %s %s %s %s %s %s %s %s %s');
    
%Import data into cell array
data = textscan(fid, '%s %u %s %s %f %f %f %f %f %f %f','delimiter','\t');

serialDate=datenum(strcat(data{3},data{4}),'mmddyyHHMMSS');
wqmData=[serialDate data{5} data{6} data{7} data{8} data{9} data{10}];

wqmHeader=['date' wqmHeader{5} wqmHeader{6} wqmHeader{7} wqmHeader{8} wqmHeader{9} wqmHeader{10}];

[PATHSTR,tempVarName,EXT]=fileparts(FILENAME);
tempVarName=genvarname(tempVarName);

for i=2:length(wqmHeader)
    %clean wqmHeader from the end to make it a valid variable name in the workspace
    while isvarname(wqmHeader{i})==0;
        wqmHeader{i}=wqmHeader{i}(1:end-1);
    end
    tempVarName= [wqmHeader{i} '_' tempVarName];
    
    assignin('base',tempVarName, [wqmData(:,1),wqmData(:,i)]);
end

fclose(fid)
clear data serialDate FILENAME PATHNAME FILTERINDEX wqmData wqmHeader tempVarName fid i ans;
