
function RSK = coef2cal(RSK)

% COEF2CAL - Combines the coefficients structure to the calibrations structure.
%
% Syntax: [RSK] = coef2cal(RSK)
%
% coef2cal pivots the coefficients table to combine it with the
% calibrations table.
%
% Inputs:
%    RSK - Structure containing the logger metadata created with versions
%    RSK v1.13.4 or newer.
%
% Outputs:
%    RSK - Structure containing the logger metadata and thumbnails
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2016-03-27

RSK.calibrations = mksqlite(['SELECT `cal`.`calibrationID`,'...
    '`cal`.`channelOrder`,'...
    '`cal`.`type`,'...
    '`cal`.`tstamp`/1.0 as tstamp,'...
    '`cal`.`equation`,'...
	'SUM(CASE WHEN `coeff`.`key` = "c0" THEN `coeff`.`value` END) AS c0,'... 
	'SUM(CASE WHEN `coeff`.`key` = "c1" THEN `coeff`.`value` END) AS c1,'... 
	'SUM(CASE WHEN `coeff`.`key` = "c2" THEN `coeff`.`value` END) AS c2,'...
	'SUM(CASE WHEN `coeff`.`key` = "c3" THEN `coeff`.`value` END) AS c3,'...
	'SUM(CASE WHEN `coeff`.`key` = "c4" THEN `coeff`.`value` END) AS c4,'...
	'SUM(CASE WHEN `coeff`.`key` = "c5" THEN `coeff`.`value` END) AS c5,'...
	'SUM(CASE WHEN `coeff`.`key` = "c6" THEN `coeff`.`value` END) AS c6,'...
	'SUM(CASE WHEN `coeff`.`key` = "c7" THEN `coeff`.`value` END) AS c7,'...
	'SUM(CASE WHEN `coeff`.`key` = "c8" THEN `coeff`.`value` END) AS c8,'...
	'SUM(CASE WHEN `coeff`.`key` = "c9" THEN `coeff`.`value` END) AS c9,'...
	'SUM(CASE WHEN `coeff`.`key` = "c10" THEN `coeff`.`value` END) AS c10,'...
	'SUM(CASE WHEN `coeff`.`key` = "c11" THEN `coeff`.`value` END) AS c11,'... 
	'SUM(CASE WHEN `coeff`.`key` = "c12" THEN `coeff`.`value` END) AS c12,'...
	'SUM(CASE WHEN `coeff`.`key` = "c13" THEN `coeff`.`value` END) AS c13,'...
	'SUM(CASE WHEN `coeff`.`key` = "c14" THEN `coeff`.`value` END) AS c14,'... 
	'SUM(CASE WHEN `coeff`.`key` = "c15" THEN `coeff`.`value` END) AS c15,'...
	'SUM(CASE WHEN `coeff`.`key` = "c16" THEN `coeff`.`value` END) AS c16,'... 
	'SUM(CASE WHEN `coeff`.`key` = "c17" THEN `coeff`.`value` END) AS c17,'...
	'SUM(CASE WHEN `coeff`.`key` = "c18" THEN `coeff`.`value` END) AS c18,'... 
	'SUM(CASE WHEN `coeff`.`key` = "c19" THEN `coeff`.`value` END) AS c19,'...
	'SUM(CASE WHEN `coeff`.`key` = "c20" THEN `coeff`.`value` END) AS c20,'...
	'SUM(CASE WHEN `coeff`.`key` = "c21" THEN `coeff`.`value` END) AS c21,'...
	'SUM(CASE WHEN `coeff`.`key` = "c22" THEN `coeff`.`value` END) AS c22,'...
	'SUM(CASE WHEN `coeff`.`key` = "c23" THEN `coeff`.`value` END) AS c23,'...
	'SUM(CASE WHEN `coeff`.`key` = "x0" THEN `coeff`.`value` END) AS x0,'...
	'SUM(CASE WHEN `coeff`.`key` = "x1" THEN `coeff`.`value` END) AS x1,'...
	'SUM(CASE WHEN `coeff`.`key` = "x2" THEN `coeff`.`value` END) AS x2,'...
	'SUM(CASE WHEN `coeff`.`key` = "x3" THEN `coeff`.`value` END) AS x3,'...
	'SUM(CASE WHEN `coeff`.`key` = "x4" THEN `coeff`.`value` END) AS x4,'...
	'SUM(CASE WHEN `coeff`.`key` = "x5" THEN `coeff`.`value` END) AS x5,'...
	'SUM(CASE WHEN `coeff`.`key` = "x6" THEN `coeff`.`value` END) AS x6,'...
	'SUM(CASE WHEN `coeff`.`key` = "x7" THEN `coeff`.`value` END) AS x7,'...
	'SUM(CASE WHEN `coeff`.`key` = "n0" THEN `coeff`.`value` END) AS n0,'...
	'SUM(CASE WHEN `coeff`.`key` = "n1" THEN `coeff`.`value` END) AS n1,'...
	'SUM(CASE WHEN `coeff`.`key` = "n2" THEN `coeff`.`value` END) AS n2,'...
	'SUM(CASE WHEN `coeff`.`key` = "n3" THEN `coeff`.`value` END) AS `n3`'...
'from `calibrations` as `cal`'...
		'join `coefficients` as `coeff`'...
		'ON `cal`.`calibrationID` = `coeff`.`calibrationID`' ...
	'GROUP BY `cal`.`calibrationID`']);

for ndx = 1:length(RSK.calibrations)
    RSK.calibrations(ndx).tstamp = RSKtime2datenum(RSK.calibrations(ndx).tstamp);
end

end