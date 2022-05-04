function newData = match_timebase(tbase,rawTime,rawData)
% function match_timebase(tbase,rawtime,rawdat);
%
% Projects raw data onto timebase tbase
% If raw sampling is faster, will lowpass first
% otherwise simply use linear interpolation
% ignores NaNS by linear interpolation

% S Wijffels, CSIRO MAR March 2006
if ~isreal(rawData)
    newData = (NaN + NaN*1i)*tbase;
else
    newData = NaN*tbase;
end
rawTime = rawTime(:);
rawData = rawData(:);
% keep only good
ig = find(rawTime >= min(tbase) & rawTime < max(tbase) & ~isnan(rawData));

if length(ig)/length(rawTime) < 0.05
    disp('match_timebase: Less than 5% of data is in time range!');
    return
end

if ~isempty(ig)
    % interpolate to timebase:
    newData = interp1(rawTime,rawData,tbase);
    ib = find(tbase < min(rawTime) | tbase > max(rawTime) );
    newData(ib) = NaN*ib;
    if ~isreal(newData),newData(ib) =  NaN*ib*(1+1i);end
    
    %remove interpolated data where NaNs are in original data
    ib = find(isnan(rawData));
    if sum(ib)>0
        rawt = rawTime(ib);
        %match these times to the original times
        td = abs(diff(tbase(1:2))-diff(rawTime(3:4)));
        for j=1:length(rawt)
            tb = find(tbase<rawt(j)+td & tbase > (rawt(j)-td));
            if isreal(newData)
                newData(tb) =  NaN;
            else
                newData(tb) = NaN + NaN*1i;
            end
        end
    end
end


return