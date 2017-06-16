function RSK = RSKgetprofiles(RSK)

% RSKgetprofiles - finds the profiles start and end times
%
% Syntax:  [RSK] = RSKgetprofiles(RSK)
% 
% RSKgetprofiles translates events into profile start and end times for
% upcast and downcast
%
% Inputs: 
%    RSK - the input RSK structure, with profile events
%
% Outputs:
%    RSK - Structure containing the logger metadata and thumbnails
%    including profile metadata
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-01-09

RSKconstants

try 
    tmp = RSKreadevents(RSK);
    events = tmp.events;
catch
end

if exist('events', 'var')
    nup = length(find(events.values(:,2) == eventBeginUpcast));
    ndown = length(find(events.values(:,2) == eventBeginDowncast));
    
    if ~(nup == 0 && ndown == 0)
        
        iup = find(events.values(:,2) == eventBeginUpcast);
        idown = find(events.values(:,2) == eventBeginDowncast);
        iend = find(events.values(:,2) == eventEndcast);
        
        % which is first?
        if (idown(1) < iup(1)) 
            idownend = iend(1:2:end);
            iupend = iend(2:2:end);
        else
            idownend = iend(2:2:end);
            iupend = iend(1:2:end);
        end
        
        RSK.profiles.downcast.tstart = events.tstamp(idown);
        RSK.profiles.downcast.tend = events.tstamp(idownend);
        RSK.profiles.upcast.tstart = events.tstamp(iup);
        RSK.profiles.upcast.tend = events.tstamp(iupend);
        
    end

end
end
