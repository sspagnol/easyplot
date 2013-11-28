%import SB56 data into workspace
% SB56 .hex should have been convert to a .cnv using export function of
% seatermUSB software
%setting for export are: file type: .cnv
%                        date format: julian days,
%                        miscelleanous: output informational header.

%Mederic MAINSON. trip 5671. 16/12/2012


function[]=importOneSB56(FILENAME,PATHNAME)

    fid = fopen([PATHNAME, FILENAME]);


    %look for line with serial number in header line
    tline = fgetl(fid);
    while isempty(strfind (tline,'* <HardwareData DeviceType=''SBE56'' SerialNumber='))
        tline = fgetl(fid);
    end
    %extract serial number from serial number line
    %%%%%%%%%%%%%%%%%%%%% * <HardwareData DeviceType='SBE56' SerialNumber='05600577'>
    serial=sscanf(tline,'* <HardwareData DeviceType=''SBE56'' SerialNumber=''%d''>');

    %look for starting date line in header
    while isempty(strfind (tline,'# start_time = '))
        tline = fgetl(fid);
    end

    %extract starting date from starting date line
    %%%%%%%%%%%% # start_time = Apr 29 2013 17:00:00    %%%%%%%%%%%
    startingDate=sscanf(tline,'# start_time = %s %s %s %s:%s:%s ');

    %convert starting date into serial date
    startingDateNum = datenum(startingDate, 'mmmddyyyyHH:MM:SS');

    %get to the end of header line
    while 0==strcmp(tline,'*END*')
        tline=fgetl(fid);
    end

    %Import data into temporary cell array
    data = textscan(fid, '%f %f %*f');

    %evaluate time vector for associated set of data
    % ie: start time in julian day + (sample time in day since 1jan of sampling year  - start time in day since 1jan of sampling year )
    %the date format in SB56 .cnv give the number of days elapsed since the
    %beginning og the year
    timeNumVector=startingDateNum+(data{1}-data{1}(1));

    %assign temperature variable names and values
    assignin('base', strcat('T',num2str(serial)), [timeNumVector,data{2}]);


    fclose(fid);
