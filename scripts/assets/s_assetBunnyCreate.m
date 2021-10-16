% s_BunnyAssetCreate;

%% Init

ieInit;
if ~piDockerExists, piDockerConfig; end

assetDir = fullfile(piRootPath,'data','assets');

%% Save bunny asset
sceneName = 'bunny';
thisR = piRecipeDefault('scene name', sceneName);
thisR.set('from',[0 0 0]);
thisR.set('to',[0 0 1]);
thisR.set('asset', 'Bunny_B', 'world position', [0 0 1]);
mergeNode = 'Bunny_B';
oFile = thisR.save(fullfile(assetDir,[sceneName,'.mat']));
save(oFile,'mergeNode','-append');
%%
%{
%% Save bunny asset
assetSceneName = 'bunny';
thisR = piRecipeDefault('scene name', assetSceneName);
assetName = 'Bunny_B';
subTree = thisR.get('asset', assetName, 'subtree');

matList = thisR.get('materials');
outputPath = fullfile(piRootPath, 'data', 'assets', 'bunny.mat');

p = piAssetTreeSave(subTree, matList, 'outFilePath', outputPath);

%% Load bunny asset
loadedAsset = piAssetTreeLoad('bunny');
%}
