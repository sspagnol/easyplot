%%
function sam = updateDataEasyplot(sam)
% UPDATEDATAEASYPLOT updates EP_* vars after a variable transform has been
% applied
%
% Inputs:
%   sam - a struct containing sample data.
%
% Outputs:
%   sam - same as input, with fields added/modified

%% retrieve good flag values
goodFlags = getGoodFlags();

%%
if isfield(sam.meta, 'latitude')
    defaultLatitude = sam.meta.latitude;
else
    defaultLatitude = NaN;
end

%% add derived diagnositic variables, prefaces with 'EP_'
sam = add_EP_vars(sam, defaultLatitude);

%% calculate data limits
sam = calc_EP_LIMITS(sam);

end
