% s_BunnyAssetCreate;
% Generate and save bunny asset leaf node

%% init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Save bunny asset
assetSceneName = 'bunny';
thisR = piRecipeDefault('scene name', assetSceneName);
assetName = 'Bunny_O';
subTree = thisR.get('asset', assetName, 'subtree');

matList = thisR.get('materials');
outputPath = fullfile(piRootPath, 'data', 'assets', 'bunny.mat');

p = piAssetTreeSave(subTree, matList, 'outFilePath', outputPath);

%% Load bunny asset
loadedAsset = piAssetTreeLoad('bunny');
