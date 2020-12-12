function [thisR, id] = piAssetAdd(thisR, parentInfo, node, varargin)
%%
%
% Synopsis:
%   [thisR, id] = piAssetAdd(thisR, parentInfo, node, varargin)
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
%   thisR      - modified recipe.
%   id         - id of the newly added node.
%

% Examples:
%{
thisR = piRecipeDefault('scene name', 'Simple scene');
disp(thisR.assets.tostring)
thisNode = thisR.get('asset', 'Sky1');
thisNode.name = 'Sky1_copy';
thisR = thisR.set('asset', 'Sky1', 'add', thisNode);
disp(thisR.assets.tostring)
%}
%% Parse input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));
p.addRequired('parentInfo', @(x)(ischar(x) || isscalar(x)));
p.addRequired('node', @isstruct);

p.parse(thisR, parentInfo, node, varargin{:});
thisR = p.Results.thisR;
parentInfo = p.Results.parentInfo;
node = p.Results.node;

%%
% If assetInfo is a node name, find the id
if ischar(parentInfo)
    parentName = parentInfo;
    parentInfo = piAssetFind(thisR, 'name', parentInfo);
    if isempty(parentInfo)
        warning('Couldn not find a parent with name %s:', parentName);
        return;
    end
end

%% Check if the parent node exists
if ~isempty(thisR.assets.get(parentInfo))
    [thisR.assets, id] = thisR.assets.addnode(parentInfo, node);
else
    warning('Parent node: %d does not exist, returning.', parentInfo);
end

end