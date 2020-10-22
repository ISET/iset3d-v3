%%
ieInit;

%%
thisR = piRecipeDefault('scene name', 'SimpleScene');

%% utilities
piAssetList(thisR); % Print the asset list
[gnames, cnames] = piAssetNames(thisR); %
piAssetPrint(thisR); % Same as piAssetList

%% Demo different structures

thisR.assets
thisR.assets.groupobjs(1)
groupobjs = thisR.assets.groupobjs(1).groupobjs(1);
children = thisR.assets.groupobjs(1).groupobjs(1).children;

%% Show node structs
groupobjs
groupobjs.size
groupobjs.rotate

%% Show children
children
%% Show new assets template
obj = piAssetCreate;