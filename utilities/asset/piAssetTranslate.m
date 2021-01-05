function newBranch = piAssetTranslate(thisR, assetInfo, translation,varargin)
%% Translate an asset
%
% Synopsis:
%   newBranch = piAssetTranslate(thisR, assetInfo, translation, varargin)
%
% Description:
%   Translate an asset.
%
%   If the asset is a branch node, translate it.
%
%   If the asset is an object or light, insert a branch node representing 
%   translation between the node and its parent.
%
% Inputs:
%   thisR       - recipe
%   assetInfo   - asset node name or id
%   translation - translation vector
%
% Outputs:
%   newBranch   - the newly inserted branch
%
% See also
%   piAsset*
%

% History:
%   ZL, Vistasoft Team, 2018
%   ZLY, Vistasoft Team, 2020
%
%   01/05/21  dhb  Put comments closer to ISETBio standard form.
%                  Little bit of commenting
%                  Fix example so it runs


% Examples:
%{
thisR = piRecipeDefault('scene name', 'Simple scene');
disp(thisR.assets.tostring)

thisR.set('asset', '004ID_Sky1_L', 'translate', [1, 1, 1]);
disp(thisR.assets.tostring)
%}

%% Parse input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('assetInfo', @(x)(ischar(x) || isscalar(x)));
p.addRequired('translation', @isvector);
p.parse(thisR, assetInfo, translation, varargin{:})

%% If assetInfo is a node name, find the id
if ischar(assetInfo)
    assetName = assetInfo;
    assetInfo = piAssetFind(thisR.assets, 'name', assetInfo);
    if isempty(assetInfo)
        warning('Couldn not find an asset with name %s:', assetName);
        return;
    end
end

%% Get asset node
thisNode = thisR.assets.get(assetInfo);
if isempty(thisNode)
    warning('Couldn not find an asset with name %d:', assetInfo);
    return;
end

%% Put translation onto a new branch node
newBranch = piAssetCreate('type', 'branch');
newBranch.name = strcat(thisR.assets.stripID(assetInfo), '_', 'T');
newBranch.translation = reshape(translation, 1, 3);

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
