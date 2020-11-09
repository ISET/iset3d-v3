function thisR = piAssetSet(thisR, id, param, val)

%%
thisNode = thisR.assets.get(id);

if ~isfield(thisNode, param)
    warning('Node %s does not have parameter: %s. Ignoring setting', thisNode.name, param);
else
    thisNode.(param) = val;
    thisR.assets = thisR.assets.set(id, thisNode);
end
end