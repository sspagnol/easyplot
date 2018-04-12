function updateLineColour( hObject )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

hFig = ancestor(hObject,'figure');
if isempty(hFig), return; end

userData = getappdata(hFig, 'UserData');
if isempty(userData.sample_data), return; end

plotPanel = findobj(hFig, 'Tag','plotPanel');
graphs = findobj(plotPanel,'Type','axes');

for ii = 1:numel(graphs)
    h = findobj(graphs(ii),'Type','line','-not','tag','legend','-not','tag','Colobar');

    hTags = arrayfun(@(x) x.Tag, h, 'UniformOutput', false);
    uTags = unique(hTags);
    nColors = length(uTags);
    [LIA,LOCB] = ismember(hTags, uTags);
    
    % mapping = round(linspace(1,64,length(h)))';
    % colors = colormap('jet');
    %   func = @(x) colorspace('RGB->Lab',x);
    %   c = distinguishable_colors(25,'w',func);
    cfunc = @(x) colorspace('RGB->Lab',x);
    colors = distinguishable_colors(nColors,'white',cfunc);
    for jj = 1:length(h)
        %dstrings{jj} = get(h(jj),'DisplayName');
        try
            set(h(jj),'Color',colors(LOCB(jj),:));
        catch e
            fprintf('Error changing plot colours in plot %s \n',get(gcf,'Name'));
            disp(e.message);
        end
    end
end

end

