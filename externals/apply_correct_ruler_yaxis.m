% from https://github.com/CelsoReyes/zmap7
function [rulerChanged, ax] = apply_correct_ruler_yaxis(dataType, ax)
if ~exist('whichaxis', 'var') || isempty.YAxis
    whichaxis = 'XAxis';
end
rulerChanged=false;
switch dataType
    case 'categorical'
        if ~isa(ax.YAxis,'matlab.graphics.axis.decorator.CategoricalRuler')
            ax.Y = matlab.graphics.axis.decorator.CategoricalRuler;
            rulerChanged=true;
        end
    case 'datetime'
        if ~isa(ax.YAxis,'matlab.graphics.axis.decorator.DatetimeRuler')
            try
                ax.YAxis = matlab.graphics.axis.decorator.DatetimeRuler;
                rulerChanged=true;
            catch
                samp = datetime(datestr(now + [0:10]'),'Format','MMM-dd');
                matlab.graphics.internal.configureAxes(ax, 1, samp);
                rulerChanged=true;
            end
        end
    case 'duration'
        if ~isa(ax.YAxis,'matlab.graphics.axis.decorator.DurationRuler')
            ax.YAxis = matlab.graphics.axis.decorator.DurationRuler;
            rulerChanged=true;
        end
    otherwise
        if ~isa(ax.YAxis,'matlab.graphics.axis.decorator.NumericRuler')
            ax.YAxis = matlab.graphics.axis.decorator.NumericRuler;
            rulerChanged=true;
        end
end
end