function newBranch = piAssetTranslate(thisR, assetInfo, translation,varargin)
%%
%
% Synopsis:
%   newBranch = piAssetTranslate(thisR, assetInfo, translation, varargin)
%
% Brief description:
%   Translate the position of an asset. Function rewritten by Zheng Lyu.
%
% Inputs:
%   thisR       - recipe
%   assetInfo   - asset node name or id
%   translation - translation vector
%
% Return
%   newBranch   - the newly inserted branch
%
% Description
%   Translate an asset. If the asset is a branch node, move it.
%   If the asset is an object or light, insert a branch node representing 
%   translation between the node and its parent.
%
% ZL, Vistasoft Team, 2018
% ZLY, Vistasoft Team, 2020
%
% See also
%   piAsset*
%

% Example:
%{
thisR = piRecipeDefault('scene name', 'Simple scene');
disp(thisR.assets.tostring)

thisR = thisR.set('asset', '004ID_Sky1', 'translate', [1, 1, 1]);
disp(thisR.assets.tostring)
%}
%% Parse input

p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('assetInfo', @(x)(ischar(x) || isscalar(x)));
p.addRequired('translation', @isvector);
p.parse(thisR, assetInfo, translation, varargin{:})

%%
% If assetInfo is a node name, find the id
if ischar(assetInfo)
    assetName = assetInfo;
    assetInfo = piAssetFind(thisR.assets, 'name', assetInfo);
    if isempty(assetInfo)
        warning('Couldn not find an asset with name %s:', assetName);
        return;
    end
end

%%
thisNode = thisR.assets.get(assetInfo);

if isempty(thisNode)
    warning('Couldn not find an asset with name %d:', assetInfo);
    return;
end

% New branch node
newBranch = piAssetCreate('type', 'branch');
newBranch.name = strcat(thisR.assets.stripID(assetInfo), '_', 'T');
newBranch.position = reshape(translation, 1, 3);

if isequal(thisNode.type, 'branch')
    % If the node is branch
    % Get the children id of thisNode
    childID = thisR.assets.getchildren(assetInfo);
    
    % Add the new node as child of thisNode
    thisR.set('asset', thisNode.name, 'add', newBranch);
    
    % Set the parent of children of thisNode be the newBranch
    for ii=1:numel(childID)
        thisR.set('asset', childID(ii), 'parent',...
                thisR.get('asset', thisR.assets.nnodes, 'name'));
    end
else
    % Node is object or light
    % Insert the newBranch node under its parent
    thisR.set('asset', assetInfo, 'insert', newBranch);
end

end
