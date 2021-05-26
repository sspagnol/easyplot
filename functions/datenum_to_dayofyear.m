function x_dayofyear = datenum_to_dayofyear(x_datenum)
%DATENUM_TO_DAYOFYEAR Helper function for datenum to dayofyear

x_dayofyear = day(datetime(x_datenum, 'ConvertFrom', 'datenum'), 'dayofyear');

end

