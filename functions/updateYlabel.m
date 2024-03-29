function updateYlabels( hAx )
%updateYlabel update ylabel of an axis based on its Tag

short_name = hAx.Tag;

if strcmp(short_name, 'MULTI')
    ylabelStr = 'Multiple Variables';
else
    [long_name, is_ep_param] = easyplotParameters( short_name, 'long_name' );
    if is_ep_param
        uom = ['(' easyplotParameters(short_name, 'uom') ')'];
        ylabelStr = makeYlabel( short_name, short_name, uom );
    else
        long_name = imosParameters( short_name, 'long_name' );
        try
            uom = ['(' imosParameters(short_name, 'uom') ')'];
        catch e
            uom = '';
        end
        ylabelStr = makeYlabel( short_name, long_name, uom );
    end
    
    
end

ylabel(hAx, ylabelStr, 'Interpreter', 'none');

end


