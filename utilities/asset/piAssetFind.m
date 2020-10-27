function id = piAssetFind(tree, param, val)
%%

% See also:
%   piAssetGet, piAssetSet;

% Example
%{
t = tree('root');
[t, nID] = t.addnode(1, node);
[t, oID] = t.addnode(nID, object);
[t, lID] = t.addnode(nID, light);
disp(t.tostring)

thisID = piAssetFind(t, 'name', 'object');
nodeObject = t.get(thisID);
%}
%%
nodeList = [0]; % 0 is always the index for root node

curIdx = 1; %
 
while curIdx <= numel(nodeList)
    IDs = tree.getchildren(nodeList(curIdx));
    for ii = 1:numel(IDs)
        if isequal(val, piAssetGet(tree, IDs(ii), param))
            id = IDs(ii);
            return;
        end
        nodeList = [nodeList IDs(ii)];
    end
    
    curIdx = curIdx + 1;
end

id = [];

end