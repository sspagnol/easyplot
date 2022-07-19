function newData = match_timebase(tbase, rawTime, rawData)
% MATCH_TIMEBASE interpolate onto new timebase.
%
% INPUTS
%   tbase : new timebase (Xq)
%   rawTime : time (X)
%   rawData : data (V)
%
% OUTPUTS
%   newData : data interpolated onto tbase (Vq)
%
% Projects raw data onto timebase tbase
% If raw sampling is faster, will lowpass first
% otherwise simply use linear interpolation
% ignores NaNS by linear interpolation
%
% S Wijffels, CSIRO MAR March 2006
%
% 2022-07-19 : Simon Spagnol <s.spagnol@aims.gov.au>
%   - some updated comments and code cleanup.

tbase = tbase(:);
rawTime = rawTime(:);
rawData = rawData(:);

if ~isreal(rawData)
    newData = complex(NaN(size(tbase)));
else
    newData = NaN(size(tbase));
end

% keep only good
ig = find(rawTime >= min(tbase) & rawTime < max(tbase) & ~isnan(rawData));

if length(ig)/length(rawTime) < 0.05
    disp('match_timebase: Less than 5% of data is in time range!');
    return
end

if ~isempty(ig)
    % interpolate to timebase:
    newData = interp1(rawTime, rawData, tbase);
    ib = (tbase < min(rawTime)) | (tbase > max(rawTime));
    if isreal(newData)
        newData(ib) = NaN;
    else
        newData(ib) =  complex(NaN, NaN);
    end
    
    % remove interpolated data where NaNs are in original data
    ib = isnan(rawData);
    if sum(ib)>0
        rawt = rawTime(ib);
        % match these times to the original times
        td = abs(diff(tbase(1:2)) - diff(rawTime(3:4)));
        for j=1:length(rawt)
            tb = (tbase < (rawt(j)+td)) & (tbase > (rawt(j)-td));
            if isreal(newData)
                newData(tb) =  NaN;
            else
                newData(tb) = complex(NaN, NaN);
            end
        end
    end
end

return