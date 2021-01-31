%% init
% Deprecated

ieInit;


%% 
t = tree('root');

%% Create a 'branch' asset node
node = piAssetCreate('type', 'branch');

%% Create an 'object' asset node
object = piAssetCreate('type', 'object');

%% Create a 'light' asset node
light = piAssetCreate('type', 'light');

%% add nodes
[t, nID] = t.addnode(1, node);
% disp(t.tostring)
[t, oID] = t.addnode(nID, object);
[t, lID] = t.addnode(nID, light);
% disp(t.tostring)

%% get nodes
nodeGet = t.get(nID);
objectGet = t.get(oID);
lightGet = t.get(lID);

%% Get the parent of a node
pId = t.getparent(oID);
t.get(pId)

%%
sId = t.getsiblings(lID)
t.get(sId(1))
t.get(sId)

%% Add another node
[t, nID2] = t.addnode(nID, node);
% disp(t.tostring)

%% Get siblings
sIDs = t.getsiblings(nID)
t = t.removenode(5);
disp(t.tostring)

%% 
nodeID = piAssetFind(t, 'name', 'light');

%%
t1 = tree('root');
t2 = tree();
t2 = t2.addnode(1, 'rr');
t2 = t2.addnode(1, 'cc');
try
	t2 = t2.removenode(1);
    fprintf('*** Surprisingly, was able to remove root node ***\n');
catch
    fprintf('*** As expected, cannot remove root node from tree ***\n');
end
t1 = t1.graft(1, t2);
disp(t1.tostring)

%%

thisR = piRecipeDefault('scene name', 'Simple Scene');
disp(thisR.assets.tostring)

thisR.assets = thisR.assets.setparent(10, 12);
disp(thisR.assets.tostring)



