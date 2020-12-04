function [sam, defaultLatitude] = add_EP_vars(sam, defaultLatitude)
%ADD_EP_VARS add derived diagnositic variables, prefaces with 'EP_'

sam = add_EP_TIMEDIFF(sam);
[sam, defaultLatitude] = add_EP_PSAL(sam, defaultLatitude);
[sam, defaultLatitude] = add_EP_DEPTH(sam, defaultLatitude);
sam = add_EP_TILT(sam);

% %%
% % just in case
% for kk=1:numel(sam.dimensions)
%     if ~isfield(sam.dimensions{kk}, 'EP_OFFSET')
%         sam.dimensions{kk}.EP_OFFSET = 0.0;
%         sam.dimensions{kk}.EP_SCALE = 1.0;
%     end
% end
% for kk=1:numel(sam.variables)
%     if ~isfield(sam.variables{kk}, 'EP_OFFSET')
%         sam.variables{kk}.EP_OFFSET = 0.0;
%         sam.variables{kk}.EP_SCALE = 1.0;
%     end
% end
% %
% for kk=1:numel(sam.variables)
%     if ~isfield(sam.variables{kk}, 'EP_iSlice')
%         sam.variables{kk}.EP_iSlice = 1;
%     end
% end

% done after adding other variables
sam = add_EP_LPF(sam);

end