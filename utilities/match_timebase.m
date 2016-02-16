function newdat = match_timebase(tbase,rawtime,rawdat);
% function match_timebase(tbase,rawtime,rawdat);
% 
% Projects raw data onto timebase tbase 
% If raw sampling is faster, will lowpass first
% otherwise simply use linear interpolation
% ignores NaNS by linear interpolation

% S Wijffels, CSIRO MAR March 2006
if ~isreal(rawdat)
    newdat = (NaN + NaN*i)*tbase;
else
    newdat = NaN*tbase;
end
rawtime = rawtime(:);
rawdat = rawdat(:);
% keep only good
ig = find(rawtime >= min(tbase) & rawtime < max(tbase) & ~isnan(rawdat));

if length(ig)/length(rawtime) < 0.05,
    disp('match_timebase: Less than 5% of data is in time range!');
    return
end

if ~isempty(ig),
    % interpolate to timebase:
    newdat = interp1(rawtime,rawdat,tbase);
    ib = find(tbase < min(rawtime) | tbase > max(rawtime) );
    newdat(ib) = NaN*ib;
    if ~isreal(newdat),newdat(ib) =  NaN*ib*(1+i);end
    
    %remove interpolated data where NaNs are in original data
    ib = find(isnan(rawdat));
    if sum(ib)>0
        rawt = rawtime(ib);
        %match these times to the original times
        td = abs(diff(tbase(1:2))-diff(rawtime(3:4)));
        for j=1:length(rawt)
            tb = find(tbase<rawt(j)+td & tbase > (rawt(j)-td));
            if isreal(newdat)
                newdat(tb) =  NaN;
            else
                newdat(tb) = NaN + NaN*i;
            end
        end
    end
end


return