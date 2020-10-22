function val = piAssetGet(tree, id, param)
%%
% Get the value of a node parameter in the asset tree
%
%% 
thisNode = tree.get(id);

if ~isfield(thisNode, param)
    if ischar(thisNode) % In the case of a string
        name = thisNode;
    else
        name = thisNode.name;
    end
    warning('Node %s does not have field: %s. Empty return', name, param)
    val = [];
else
    val = thisNode.(param);
end
end