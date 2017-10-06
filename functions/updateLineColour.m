function updateLineColour( hObject )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

hFig = ancestor(hObject,'figure');
if isempty(hFig), return; end

userData = getappdata(hFig, 'UserData');
if isempty(userData.sample_data), return; end

gData = guidata(hFig);
hAx = findobj(gData.plotPanel,'Type','axes');

for ii = 1:numel(hAx)
    h = findobj(hAx(ii),'Type','line','-not','tag','legend','-not','tag','Colobar');
    
    % mapping = round(linspace(1,64,length(h)))';
    % colors = colormap('jet');
    %   func = @(x) colorspace('RGB->Lab',x);
    %   c = distinguishable_colors(25,'w',func);
    cfunc = @(x) colorspace('RGB->Lab',x);
    colors = distinguishable_colors(length(h),'white',cfunc);
    for jj = 1:length(h)
        %dstrings{jj} = get(h(jj),'DisplayName');
        try
            %set(h(jj),'Color',colors( mapping(j),: ));
            set(h(jj),'Color',colors(jj,:));
        catch e
            fprintf('Error changing plot colours in plot %s \n',get(gcf,'Name'));
            disp(e.message);
        end
    end
end

end

