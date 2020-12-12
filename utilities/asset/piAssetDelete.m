function thisR = piAssetDelete(thisR, assetInfo, varargin)
%%
%
% Synopsis:
%   thisR = piAssetDelete(thisR, assetInfo)
%
% Brief description:
%   Remove a node from assets tree
%
% Inputs:
%   thisR     - recipe.
%   assetInfo - asset node name or id.
% 
% Returns:
%   thisR     - modified recipe.

% Examples:
%{
thisR = piRecipeDefault('scene name', 'Simple scene');
disp(thisR.assets.tostring)
thisR = thisR.set('asset', 'Sky1', 'delete');
disp(thisR.assets.tostring)
%}
%% Parse
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('assetInfo', @(x)(ischar(x) || isscalar(x)));
p.parse(thisR, assetInfo, varargin{:});

thisR     = p.Results.thisR;
assetInfo = p.Results.assetInfo;

%%
% If assetInfo is a node name, find the id
if ischar(assetInfo)
    assetName = assetInfo;
    assetInfo = piAssetFind(thisR, 'name', assetInfo);
    if isempty(assetInfo)
        warning('Couldn not find a parent with name %s:', assetName);
        return;
    end
end
%% Remove node 
if ~isempty(thisR.assets.get(assetInfo))
    thisR.assets = thisR.assets.removenode(assetInfo);
else
    warning('Node: %d is not in the tree, returning.', assetInfo);
end

end