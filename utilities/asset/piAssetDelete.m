function thisR = piAssetDelete(thisR, assetInfo, varargin)
% Delete a node of the asset tree
%
% Synopsis:
%   thisR = piAssetDelete(thisR, assetInfo)
%
% Brief description:
%   assetInfo:  The node name or the id
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
thisR = thisR.set('asset', '004ID_Sky1', 'delete');
disp(thisR.assets.tostring)
%}
%% Parse
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('assetInfo', @(x)(ischar(x) || isscalar(x)));
p.parse(thisR, assetInfo, varargin{:});

thisR        = p.Results.thisR;
assetInfo    = p.Results.assetInfo;
%%
% If assetInfo is a node name, find the id
if ischar(assetInfo)
    assetName = assetInfo;
    [assetInfo,thisAsset] = piAssetFind(thisR.assets, 'name', assetInfo);
    if isempty(assetInfo)
        warning('Couldn not find a parent with name %s:', assetName);
        return;
    end
end
%% Remove node 
if ~isempty(thisR.assets.get(assetInfo))
        thisR.assets = thisR.assets.removenode(assetInfo);
        % warning('Removing node might change remaining node ids.')
        % [thisR.assets, ~] = thisR.assets.uniqueNames;
else
    warning('Node: %d is not in the tree, returning.', assetInfo);
end

end
