function modifiedBranch = piAssetRotate(thisR, assetInfo, rotation, varargin)
%% Rotate an asset
%
% Synopsis:
%   newBranch = piAssetRotate(thisR, assetInfo, rotation, varargin)
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
% Inputs:
%   thisR       - recipe.
%   assetInfo   - asset name or id
%   rotation    - rotation vector [x-axis, y-axis, z-axis] (deg)
% 
% Outputs:
%   newBranch   - inserted branch
%   
% Description
%
% See also
%   piAsset*
%

% Examples:
%{
ieInit;
thisR = piRecipeDefault('scene name', 'Simple scene');
% thisR.show;
piWRS(thisR);

assetName = '0014ID_figure_3m_B';
thisR.set('asset', assetName, 'rotation', [45, 0, 0]);
% thisR.show;
piWRS(thisR);
%}

%% Parse input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('assetInfo', @(x)(ischar(x) || isscalar(x)));
p.addRequired('rotation', @isvector);
p.parse(thisR, assetInfo, rotation, varargin{:});

%% If assetInfo is a name, find the id
if ischar(assetInfo)
    assetInfo = piAssetFind(thisR.assets, 'name', assetInfo);
    if isempty(assetInfo)
        warning('Could not find an asset with name %s:', assetInfo);
        return;
    end
end

%% Get asset node
thisNode = thisR.assets.get(assetInfo);
if isempty(thisNode)
    warning('Could not find an asset with name %d:', assetInfo);
    return;
end

% Create the rotation matrix and put it onto a new branch node
rotMatrix = [rotation(3), rotation(2), rotation(1);
             fliplr(eye(3))];
         
if isequal(thisNode.type, 'branch')
    % Insert the new rotation matrix to existing rotation cell array, and
    % store the order
    thisNode.rotation{end+1} = rotMatrix;
    thisNode.transorder(end+1) = 'R';
    [~, modifiedBranch] = thisR.set('asset', assetInfo, thisNode);    
else
    % Node is object or light
    parentNodeID = thisR.assets.getparent(assetInfo);
    modifiedBranch = piAssetRotate(thisR, parentNodeID, rotation);
end

%{
% Create the rotation matrix and put it onto a new branch node
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
    thisR.set('asset', thisNode.name, 'add', newBranch);
    
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
%}

end