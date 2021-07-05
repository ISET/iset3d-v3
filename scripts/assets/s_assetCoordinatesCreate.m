% s_CoordinateAssetCreate
% Create and save coordinate asset leaf node
% TODO: create recipeSet merge function
%% init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Save coordinate asset
assetSceneName = 'coordinate';
thisR = piRecipeDefault('scene name', assetSceneName);

% thisR.assets.show

%%
rotAngX = thisR.get('asset', 'x_O', 'world rotation angle');
rotAngZ = thisR.get('asset', 'y_O', 'world rotation angle');
%% Render 
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene)

%% Save
assetName = 'Coordinate_B';
subTree = thisR.get('asset', assetName, 'subtree');
matList = thisR.get('materials');

outputPath = fullfile(piRootPath, 'data', 'assets', 'coordinate.mat'); 
piAssetTreeSave(subTree, matList, 'outFilePath', outputPath);


