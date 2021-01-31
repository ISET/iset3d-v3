%% init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Save coordinate asset
assetSceneName = 'slantedbarAsset';
thisR = piRecipeDefault('scene name', assetSceneName);

% thisR.assets.show
%% Render
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene)

%% Save
assetName = 'SlantedBar_B';
subTree = thisR.get('asset', assetName, 'subtree');
matList = thisR.get('materials');

outputPath = fullfile(piRootPath, 'data', 'assets', 'slantedbar.mat');
piAssetTreeSave(subTree, matList, 'outFilePath', outputPath);