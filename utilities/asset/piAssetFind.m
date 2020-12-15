function id = piAssetFind(thisR, param, val)
%%
% Find an asset with parameters matches vale.
%
% Synopsis:
%   id = piAssetFind(thisR, param, val)
%
% Inputs:
%   thisR   - recipe
%   param   - parameter
%   val     - value to match
%
% Returns:
%   id      - 
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
%{
thisR = piRecipeDefault;
names = thisR.assets.names;
id = piAssetFind(thisR, 'name', 'Camera');
idtwo = piAssetFind(thisR, 'name', '002ID_Camera');
%}
%%
thisTree = thisR.assets;
%%
nodeList = [0]; % 0 is always the index for root node

curIdx = 1; %
 
while curIdx <= numel(nodeList)
    IDs = thisTree.getchildren(nodeList(curIdx));
    for ii = 1:numel(IDs)
        if isequal(param, 'name')
            % Users are allowed to look for node with its ID or just the
            % name contain.
            % piAssetFind(thisR, 'name', 'XXXID_NAME') or 
            % piAssetFind(thisR, 'name', 'NAME') 
            if isequal(val, thisR.assets.stripID(IDs(ii))) || ...
                    isequal(val, piAssetGet(thisR, IDs(ii), param))
                id = IDs(ii);
                return;
            end
        else
            % All other parameters must match.
            if isequal(val, piAssetGet(thisR, IDs(ii), param))
                id = IDs(ii);
                return;
            end
        end
        nodeList = [nodeList IDs(ii)];
    end
    
    curIdx = curIdx + 1;
end

id = [];

end