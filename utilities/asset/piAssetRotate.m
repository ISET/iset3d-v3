function newBranch = piAssetRotate(thisR, assetInfo, rotation, varargin)
%% Rotate an asset
%
% Synopsis:
%   newBranch = piAssetRotate(thisR, assetInfo, rotation, varargin)
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
%   newBranch   - inserted branch
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
% If assetInfo is a name, find the id
if ischar(assetInfo)
    assetInfo = piAssetFind(thisR.assets, 'name', assetInfo);
    if isempty(assetInfo)
        warning('Could not find an asset with name %s:', assetInfo);
        return;
    end
end

thisNode = thisR.assets.get(assetInfo);

%% 
if isempty(thisNode)
    warning('Could not find an asset with name %d:', assetInfo);
    return;
end

% Create the rotation matrix
rotMatrix = [rotation(3), rotation(2), rotation(1);
             fliplr(eye(3))];
newBranch = piAssetCreate('type', 'branch');
newBranch.name   = strcat(thisR.assets.stripID(assetInfo), '_', 'R');
newBranch.rotation = rotMatrix;
         
if isequal(thisNode.type, 'branch')
    % The node sent in is a branch node.  Get a list of the ids of its
    % children 
    childID = thisR.assets.getchildren(assetInfo);
    
    % Add the new node, which is also a branch, as child of the input branch
    % node.
    thisR = thisR.set('asset', thisNode.name, 'add', newBranch);
    
    % Set the children of the original branch node will now be children of
    % this new branch node
    for ii=1:numel(childID)
        thisR.set('asset', childID(ii), 'parent',...
                thisR.get('asset', thisR.assets.nnodes, 'name'));
    end
else
    % The node sent in is an object or light.  We create a new node between
    % thisNode and its parent.    
    thisR.set('asset', assetInfo, 'insert', newBranch);
end

end