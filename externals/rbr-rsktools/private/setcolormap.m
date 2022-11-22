function setcolormap(channel)
%SETCOLORMAP - Use cmocean colormaps, choose it based on the channel. 
%
% cmocean toolbox can be found here:
% https://www.mathworks.com/matlabcentral/fileexchange/57773-cmocean-perceptually-uniform-colormaps 

if exist('cmocean', 'file')==2 
    if contains(channel, 'salinity', 'ignorecase', true)
        cmocean('haline');
    elseif contains(channel, 'temperature', 'ignorecase', true)
        cmocean('thermal'); 
    elseif contains(channel, 'chlorophyll', 'ignorecase', true)
        cmocean('algae'); 
    elseif contains(channel, 'backscatter', 'ignorecase', true)
        cmocean('matter');
    elseif contains(channel, ["phycoerythrin", "turbidity"], 'ignorecase', true)
        cmocean('turbid');
    elseif strcmpi(channel, 'par')
        cmocean('solar');
	else
		cmocean('haline');
    end
else
    colormap default
end

end