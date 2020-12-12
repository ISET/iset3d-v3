function thisR = piAssetInsert(thisR, assetInfo, newNode, varargin)
%%
%
% Synopsis:
%   thisR = piAssetInsert(thisR, assetInfo, node, varargin)
% 
% Brief description:
%   Insert a node between a node and its parent.
%
% Inputs:
%   thisR      - recipe.
%   assetInfo  - asset node name or id.
%   node       - the node to insert.
%
% Returns:
%   thisR      - modified recipe.
%   id         - id of the newly inserted node.
%

% Examples:
%{
thisR = piRecipeDefault('scene name', 'Simple scene');
disp(thisR.assets.tostring)
newNode = piAssetCreate('type', 'branch');
newNode.name = 'New node';
thisR = thisR.set('asset', 'Sky1', 'insert', newNode);
disp(thisR.assets.tostring)
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

%% Insert
% Get node and its parent.
curNode = thisR.get('asset', assetInfo);

if isempty(curNode)
    % If empty, return
    warning('Parent node: %d does not exist, returning.', assetInfo);
    return;
end
parentNode = thisR.get('asset', assetInfo, 'parent');

% Attach the new node under parent node.
newNode.type = 'branch'; % Enforce it is branch node
thisR = thisR.set('asset', parentNode.name, 'add', newNode);

% Remove node and attach it under the new node. 
thisR = thisR.set('asset', curNode.name, 'delete');
thisR = thisR.set('asset', newNode.name, 'add', curNode);

end