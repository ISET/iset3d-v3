% s_MCCCBAssetCreate;
% Generate and save Macbeth Color Checker for Cornell Box project.

%% init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read MCCCB recipe
assetSceneName = 'MacBethCheckerCB';
thisR = piRecipeDefault('scene name', assetSceneName);
% thisR.assets.show;

%% Assign spectral reflectance data
% Load MCC reflectance data
wave = 400:10:700;
reflList = ieReadSpectra('MiniatureMacbethChart', wave);
%{
plotReflectance(wave, reflList);
%}

piMaterialPrint(thisR);
for ii=1:size(reflList, 2)
    thisMatName = sprintf('Patch%02d', ii);
    thisRefl = piMaterialCreateSPD(wave, reflList(:, ii));
    thisR.set('material', thisMatName, 'kd value', thisRefl);
end

%% Create the MCC asset subtree
assetName = 'MCC_B';
subTree = thisR.get('asset', assetName, 'subtree');
matList = thisR.get('materials');
outputPath = fullfile(piRootPath, 'data', 'assets', 'mccCB.mat');

p = piAssetTreeSave(subTree, matList, 'outFilePath', outputPath);

%{
piWrite(thisR);
scene = piRender(thisR, 'render type', 'illuminant', 'scaleIlluminance', false);
sceneWindow(scene);
%}

%% Load mcc asset
loadedAsset = piAssetTreeLoad('mccCB');