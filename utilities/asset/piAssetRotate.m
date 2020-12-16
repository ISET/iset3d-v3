function thisR = piAssetRotate(thisR, assetInfo, rotation, varargin)
%% Rotate an asset
%
% Synopsis:
%   thisR = piAssetRotate(thisR, assetInfo, rotation, varargin)
%
% Brief description:
%   Rotate an asset. Function reweitten by Zheng Lyu.
% 
% Inputs:
%   thisR       - recipe.
%   assetInfo   - asset name or id
%   rotation    - rotation vector [x-axis, y-axis, z-axis] (deg)
% 
% Returns:
%   thisR       - modified recipe.
%
% Description:
%   Rotate an asset. 
%
%   If the asset is a branch node, insert a new branch node with rotation
%   below.
%
%   If the asset is an object or light, insert a branch node representing
%   rotation between the node and its parent.
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

thisR = thisR.set('asset', '004ID_Sky1', 'rotation', [45, 0, 0]);
disp(thisR.assets.tostring)
%}
%% Parse input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('assetInfo', @(x)(ischar(x) || isscalar(x)));
p.addRequired('rotation', @isvector);
p.parse(thisR, assetInfo, rotation, varargin{:});

%%
% If assetInfo is a node name, find the id
if ischar(assetInfo)
    assetName = assetInfo;
    assetInfo = piAssetFind(thisR, 'name', assetInfo);
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

% Form rotation matrix
rotMatrix = [rotation(3), rotation(2), rotation(1);
             fliplr(eye(3))];
newBranch = piAssetCreate('type', 'branch');
newBranch.name = strcat(thisR.assets.stripID(assetInfo), '_', 'rotate');
newBranch.rotate = rotMatrix;
         
if isequal(thisNode.type, 'branch')
    % If the node is branch
    % Get the children id of thisNode
    childID = thisR.assets.getchildren(assetInfo);
    
    % Add the new node as child of thisNode
    thisR = thisR.set('asset', thisNode.name, 'add', newBranch);
    
    % Set the parent of children of thisNode be the newBranch
    for ii=1:numel(childID)
        thisR.set('asset', childID(ii), 'parent',...
                thisR.get('asset', thisR.assets.nnodes, 'name'));
    end
else
    % Node is object or light
    % Insert the newBranch node under its parent
    thisR = thisR.set('asset', assetInfo, 'insert', newBranch);
end
end