% from https://github.com/CelsoReyes/zmap7
function [rulerChanged, ax] = apply_correct_ruler_xaxis(dataType, ax, whichaxis)
    if ~exist('whichaxis', 'var') || isempty(whichaxis)
        whichaxis = 'XAxis';
    end
    rulerChanged=false;
    switch dataType
        case 'categorical'
            if ~isa(ax.(whichaxis),'matlab.graphics.axis.decorator.CategoricalRuler')
                ax.(whichaxis) = matlab.graphics.axis.decorator.CategoricalRuler;
                rulerChanged=true;
            end
        case 'datetime'
            if ~isa(ax.(whichaxis),'matlab.graphics.axis.decorator.DatetimeRuler')
                ax.(whichaxis) = matlab.graphics.axis.decorator.DatetimeRuler;
                rulerChanged=true;
            end
        case 'duration'
            if ~isa(ax.(whichaxis),'matlab.graphics.axis.decorator.DurationRuler')
                ax.(whichaxis) = matlab.graphics.axis.decorator.DurationRuler;
                rulerChanged=true;
            end
        otherwise
            if ~isa(ax.(whichaxis),'matlab.graphics.axis.decorator.NumericRuler')
                ax.(whichaxis) = matlab.graphics.axis.decorator.NumericRuler;
                rulerChanged=true;
            end
    end
end