function x_datetime = datenum_to_datetime(x_datenum)
%DATENUM_TO_DATETIME Helper function for datenum to datetime

x_datetime = datetime(x_datenum, 'ConvertFrom', 'datenum');

end

