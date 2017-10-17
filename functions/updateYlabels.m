function updateYlabels( hObject )
%updateYlabels update ylabels

hFig = ancestor(hObject,'figure');
if isempty(hFig), return; end

userData = getappdata(hFig, 'UserData');
if isempty(userData.sample_data), return; end

plotPanel = findobj(hFig, 'Tag','plotPanel');
graphs = findobj(plotPanel,'Type','axes');

if numel(graphs) == 1
    % have one axis one one variable
    if numel(userData.plotVarNames) == 1
        short_name = char(userData.plotVarNames);
        long_name = imosParameters( short_name, 'long_name' );
        try      uom = ['(' imosParameters(short_name, 'uom') ')'];
        catch e, uom = '';
        end
        ylabelStr = makeYlabel( short_name, long_name, uom );
        ylabel(graphs, ylabelStr);
    else
        % have one axis of multiple variables
        ylabel(graphs,'Multiple Variables');
    end
else
    % have multiple axes
    for ii = 1:numel(graphs)
        short_name = graphs(ii).Tag;
        long_name = imosParameters( short_name, 'long_name' );
        try      uom = ['(' imosParameters(short_name, 'uom') ')'];
        catch e, uom = '';
        end
        ylabelStr = makeYlabel( short_name, long_name, uom );
        ylabel(graphs(ii), ylabelStr);
    end
    
end


