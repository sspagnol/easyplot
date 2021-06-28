%%
function targetInBounds = localInBounds(hAxes)
%localInBounds : Check if the user clicked within the bounds of the axes. If not, do
%nothing.
%
% from datacursormode

targetInBounds = true;
tol = 3e-16;

cp = get(hAxes,'CurrentPoint');
XLims = get(hAxes,'XLim');
if isdatetime(XLims)
    cpX = hAxes.XAxis.ReferenceDate + hAxes.CurrentPoint(1);
    if (cpX < XLims(1)) || (cpX > XLims(2))
        targetInBounds = false;
    end
else
    if ((cp(1,1) - min(XLims)) < -tol || (cp(1,1) - max(XLims)) > tol) && ...
            ((cp(2,1) - min(XLims)) < -tol || (cp(2,1) - max(XLims)) > tol)
        targetInBounds = false;
    end
end
YLims = get(hAxes,'YLim');
if isdatetime(YLims)
    cpY = hAxes.YAxis.ReferenceDate + hAxes.CurrentPoint(2);
    if (cpY < YLims(1)) || (cpY > YLims(2))
        targetInBounds = false;
    end
else
    if ((cp(1,2) - min(YLims)) < -tol || (cp(1,2) - max(YLims)) > tol) && ...
            ((cp(2,2) - min(YLims)) < -tol || (cp(2,2) - max(YLims)) > tol)
        targetInBounds = false;
    end
end
ZLims = get(hAxes,'ZLim');
if isdatetime(ZLims)
    ZLims = datenum(ZLims);
end    
if ((cp(1,3) - min(ZLims)) < -tol || (cp(1,3) - max(ZLims)) > tol) && ...
        ((cp(2,3) - min(ZLims)) < -tol || (cp(2,3) - max(ZLims)) > tol)
    targetInBounds = false;
end
end


