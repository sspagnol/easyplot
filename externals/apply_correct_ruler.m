% from https://github.com/CelsoReyes/zmap7
function [rulerChanged, ax] = apply_correct_ruler(dataType, ax)
    rulerChanged=false;
    switch dataType
        case 'categorical'
            if ~isa(ax.XAxis,'matlab.graphics.axis.decorator.CategoricalRuler')
                ax.XAxis = matlab.graphics.axis.decorator.CategoricalRuler;
                rulerChanged=true;
            end
        case 'datetime'
            if ~isa(ax.XAxis,'matlab.graphics.axis.decorator.DatetimeRuler')
                ax.XAxis = matlab.graphics.axis.decorator.DatetimeRuler;
                rulerChanged=true;
            end
        case 'duration'
            if ~isa(ax.XAxis,'matlab.graphics.axis.decorator.DurationRuler')
                ax.XAxis = matlab.graphics.axis.decorator.DurationRuler;
                rulerChanged=true;
            end
        otherwise
            if ~isa(ax.XAxis,'matlab.graphics.axis.decorator.NumericRuler')
                ax.XAxis = matlab.graphics.axis.decorator.NumericRuler;
                rulerChanged=true;
            end
    end
end