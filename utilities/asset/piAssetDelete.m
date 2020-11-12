function thisR = piAssetDelete(thisR, nodeID)
% Remove a node from assets tree
%
%% Parse
p = inputParser;
p.addRequired('thisR');
p.addRequired('nodeID', @isnumeric);
p.parse(thisR, nodeID);

%% Simply do it by using removenode function
if isempty(thisR.assets.get(nodeID))
    warning('Node: %d is not in the tree. Ignoring.', nodeID);
else
    thisR.assets = thisR.assets.removenode(nodeID);
end

end