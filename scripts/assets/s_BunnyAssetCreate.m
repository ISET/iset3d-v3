% s_BunnyAssetCreate;
% Generate and save bunny asset leaf node

%% init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Save bunny asset
assetSceneName = 'bunny';
assetName = 'Bunny_material_BunnyMat';

thisR = piRecipeDefault('scene name', 'bunny');

thisAsset = thisR.get('asset', assetName);

outputPath = fullfile(piRootPath, 'data', 'assets', 'bunny.mat');
p = piAssetSave(thisAsset, 'outFilePath', outputPath);

%% Load bunny asset
loadedAsset = piAssetLoad('bunny');
