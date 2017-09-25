function [x,y,ph] = select_points(hAx)
% SELECT_POINTS uses rbbox to select points in the timeseries chart for flagging.
%
% [x,y,ph] = select_points(hAx)
% Inputs
%   hAx : axes handle to plot on
% Outpus
%   x,y : index of rectangle corners in figure units 
%   ph : plot handle for box

axes(hAx);
k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions
x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
hold('on');
axis('manual');
ph = plot(x,y);                            % redraw in dataspace units

end