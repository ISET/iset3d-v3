function id = piAssetInsert(thisR, assetInfo, newNode, varargin)
% Insert a new node between an existing node and its parent
%
% Synopsis:
%   id = piAssetInsert(thisR, assetInfo, node)
%
% Brief description:
%   The assetInfo defines the node.  The newNode will be inserted between
%   the node and its parent.
%
% Inputs:
%   thisR      - recipe.
%   assetInfo  - asset node name or id.
%   node       - the node to insert.
%
% Returns:
%   id         - id of the newly inserted node.
%

% Examples:
%{
 thisR = piRecipeDefault('scene name', 'Simple scene');
 thisR.assets.show;

 newNode = piAssetCreate('type', 'branch');
 newNode.name = 'New node';
 id = thisR.set('asset', 'Sky1_L', 'insert', newNode);
%}

%% Parse input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('assetInfo', @(x)(ischar(x) || isscalar(x)));
p.addRequired('newNode', @isstruct);

p.parse(thisR, assetInfo, newNode, varargin{:});
thisR = p.Results.thisR;
assetInfo = p.Results.assetInfo;
newNode = p.Results.newNode;

%% If assetInfo is a node name, find the id.  If an id, find the name

if isnumeric(assetInfo)
    assetID   = assetInfo;
    assetName = thisR.assets.get(assetID).name;
else
    assetName = assetInfo;
    assetID   = piAssetFind(thisR.assets,'name',assetName);
end

%% Specify the current node and the new node

% Get node and its parent.
thisNode     = thisR.get('asset', assetName);
parentNodeID = thisR.assets.getparent(assetID);
parentNode   = thisR.assets.get(parentNodeID);

% Attach the new node under parent of thisNode.
newNode.type = 'branch'; % Enforce it is branch node

% The newNode is added below the parent node.
% NOTE: The name of newNode name will be changed to force it to be unique
% when it is addded to the tree.
[~, id] = thisR.set('asset', parentNodeID, 'add', newNode);

% Change the parent of thisNode to be the newNode
thisR.set('asset', thisNode.name, 'parent', id);

end