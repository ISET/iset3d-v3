function thisR = piAssetAdd(thisR, parentID, node)
% Attach a node under a parent node.

%%
p = inputParser;
p.addRequired('thisR');
p.addRequired('parent_id', @isnumeric);
p.addRequired('node', @isstruct);

p.parse(thisR, parentID, node);
thisR = p.Results.thisR;
parentID = p.Results.parentID;
node = p.Results.node;

%% Check if the parent node exists
if ~isempty(thisR.assets.get(parentID))
    thisR.assets = thisR.assets.addnode(parentID, node);
else
    error('Parent node: %d does not exist', parentID);
end

end