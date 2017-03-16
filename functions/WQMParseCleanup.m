function [ sam ] = WQMParseCleanup( sam )
%WQMParseCleanup Easyplot struct cleanup

idTime  = getVar(sam.dimensions, 'TIME');
dateTime = sam.dimensions{idTime}.data;

% difference between samples in seconds
diffTime=[NaN; diff(dateTime)*86400];

% negative time diffs and equal time stamps
tEps = 0.1/3600/24; %pretty sure WQM min sampling is 1 sec
iBadDiffTime = diffTime < tEps;
% more than 10 time median good diffs
%iBadMeanDiff = diffTime > mean(diffTime(~iBadDiffTime))*10;
% Don't think there was a WQM made before 1980
iBadImpossibleTime = dateTime < datenum(1980,0,0);

%iBad = iBadDiffTime | iBadMeanDiff | iBadImpossibleTime;
iBad = iBadDiffTime | iBadImpossibleTime;

if sum(iBad) > 0
    warning('WQM dat file will need more cleaning for toolbox processing.');
    disp(['Number of impossible time values (<1980): ' num2str(sum(iBadImpossibleTime))]);
    disp(['Number of coincident time values : ' num2str(sum(iBadDiffTime))]);
end

%% remove any bad entries
iSize = size(sam.dimensions{idTime}.data);
for ii=1:numel(sam.variables)
    varName=sam.variables{ii}.name;
    theData = sam.variables{ii}.data;
    if size(theData,1) == iSize(1)
        if size(theData,2) == iSize(2)
            sam.variables{ii}.data(iBad) = [];
        else
            sam.variables{ii}.data(repmat(iBad,1,iSize(2))) = [];
        end
    end
    
end
sam.dimensions{idTime}.data(iBad) = [];

end