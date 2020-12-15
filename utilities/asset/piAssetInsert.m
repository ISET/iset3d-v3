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
thisR = thisR.set('asset', '004ID_Sky1', 'insert', newNode);
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

% Change the parent of curNode to the new node
% NOTE: name of newNode will be changed when adding in the tree. The new
% node will be the last node in the node cell array, so checking the last
% element.
thisR = thisR.set('asset', curNode.name, 'parent',...
            thisR.get('asset', thisR.assets.nnodes, 'name'));

end