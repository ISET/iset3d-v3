%% piAssetTreeCreate

%{
% The Stanford Bunny
 assetSceneName = 'bunny';
 assetName = 'Bunny_B';
 thisR    = piRecipeDefault('scene name', 'bunny');
 thisST   = thisR.get('asset', assetName, 'subtree');
 fullPath = piAssetTreeSave(thisST, thisR.materials.list,'outFilePath',fullfile(piRootPath,'data','assets','bunny.mat'));
%}
%{
% XYZ coordinate axis to insert in a scene
 assetSceneName = 'coordinate';
 assetName = 'Coordinate_B';
 thisR     = piRecipeDefault('scene name', 'coordinate');
 thisST    = thisR.get('asset', assetName, 'subtree');
 fullPath  = piAssetTreeSave(thisST, thisR.materials.list,'outFilePath',fullfile(piRootPath,'data','assets','coordinate.mat'));
%}
%{
  flatR = piRecipeDefault('scene name','flatsurface');

%}