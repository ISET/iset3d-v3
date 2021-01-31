function thisR = piAssetSetParent(thisR, assetInfo, newParentInfo, varargin)
%%
%
% Synopsis:
%   thisR = piAssetSetParent(thisR, assetInfo, newParentInfo, varargin)
%
% Brief description:
%   Set a node a new parent.
%
% Inputs:
%   thisR         - recipe.
%   assetInfo     - child node name or id.
%   newParentInfo - new parent node name or id.
%
% Returns:
%   thisR         - modified recipe.
% 

% Examples
%{
thisR = piRecipeDefault('scene name', 'Simple scene');
disp(thisR.assets.tostring)

parentName = '012ID_Sky Dome';
childName = '010ID_Moon Light';
thisR.set('asset', childName, 'parent', parentName);
disp(thisR.assets.tostring)
%}

%% Parse input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('assetInfo', @(x)(ischar(x) || isscalar(x)));
p.addRequired('newParentInfo', @(x)(ischar(x) || isscalar(x)));
p.parse(thisR, assetInfo, newParentInfo, varargin{:});

thisR = p.Results.thisR;
assetInfo = p.Results.assetInfo;
newParentInfo = p.Results.newParentInfo;
%%
% If assetInfo is a node name, find the id
if ischar(assetInfo)
    assetName = assetInfo;
    assetInfo = piAssetFind(thisR.assets, 'name', assetInfo);
    if isempty(assetInfo)
        warning('Could not find a node with name %s:', assetName);
        return;
    end
end

% If assetInfo is a node name, find the id
if ischar(newParentInfo)
    parentName = newParentInfo;
    newParentInfo = piAssetFind(thisR.assets, 'name', newParentInfo);
    if isempty(newParentInfo)
        warning('Could not find a parent node with name %s:', parentName);
        return;
    end
end

%%
if isempty(thisR.assets.get(assetInfo))
    warning('Node: %d does not exist, returning.', assetInfo);
    return;
end

if isempty(thisR.assets.get(newParentInfo))
    warning('Node: %d does not exist, returning.', assetInfo);
    return;
end

%%
thisR.assets = thisR.assets.setparent(assetInfo, newParentInfo);

end
