function id = piAssetSet(tree, id, param, val)

%%
thisNode = tree.get(id);

if ~isfield(thisNode, param)
    warning('Node %s does not have parameter: %s. Ignoring setting', thisNode.name, param);
else
    thisNode.(param) = val;
    tree.set(id, thisNode);
end
end