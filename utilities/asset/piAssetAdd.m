function id = piAssetAdd(thisR, parentInfo, node, varargin)
% Add a node to the tree below the specified parent
%
% Synopsis:
%   id = piAssetAdd(thisR, parentInfo, node, varargin)
% 
% Brief description:
%   Attach a node under a parent node.
%
% Inputs:
%   thisR      - recipe.
%   parentInfo - parent node name or id.
%   node       - the node to be added under the parent node.
%
% Returns:
%   id         - id of the newly added node.
%

% Examples:
%{
 thisR = piRecipeDefault('scene name', 'Simple scene');
 thisNode = thisR.get('asset', 'Sky1_L');
 thisNode.name = 'Sky1_L_copy';
 id = thisR.set('asset', 'Sky1_L', 'add', thisNode);
 thisR.assets.show;
 thisR.get('asset',id)
%}

%% Parse input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('parentInfo', @(x)(ischar(x) || isscalar(x)));
p.addRequired('node', @isstruct);

p.parse(thisR, parentInfo, node, varargin{:});

thisR      = p.Results.thisR;
parentInfo = p.Results.parentInfo;
node       = p.Results.node;

%% If parentInfo is a node name, find the id

if ischar(parentInfo)
    parentName = parentInfo;
    parentInfo = piAssetFind(thisR.assets, 'name', parentInfo);
    if isempty(parentInfo)
        warning('Could not find a parent with name %s:', parentName);
        return;
    end
end

%% Check if the parent node exists

if ~isempty(thisR.assets.get(parentInfo))
    [thisR.assets, id] = thisR.assets.addnode(parentInfo, node);
    % Format the new node name.
    [thisR.assets, ~] = thisR.assets.uniqueNames(id);
else
    warning('Parent node: %d does not exist, returning.', parentInfo);
end

end