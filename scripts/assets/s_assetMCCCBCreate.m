% s_MCCCBAssetCreate;
%
%   Generate and save Macbeth Color Checker for Cornell Box project. This
%   is a more extensive asset than the macbeth asset created by
%   piChartCreate and used in s_assetsRecipe. This one includes the
%   spectral data for the patches in the chart. 
%
% Zheng Lyu
%
% See also
%

%% Init

ieInit;
if ~piDockerExists, piDockerConfig; end

assetDir = fullfile(piRootPath,'data','assets');

%% Read MCCCB recipe
assetSceneName = 'mccCB';
thisR = piRecipeDefault('scene name', assetSceneName);
% thisR.set('assets', '001_Substrate_O', 'world translation', [0 0 0.0025]);
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
    thisR.set('material', thisMatName, 'type', 'matte');
    thisR.set('material', thisMatName, 'kd value', thisRefl);
end

%%
mergeNode = 'MCC_B';
oFile = thisR.save(fullfile(assetDir, [assetSceneName, '.mat']));
save(oFile, 'mergeNode', '-append');

%{
[~, results] = piWRS(thisR);
%}

%%
%{
%% Create the MCC asset subtree
assetName = 'MCC_B';
subTree = thisR.get('asset', assetName, 'subtree');
matList = thisR.get('materials');
outputPath = fullfile(piRootPath, 'data', 'assets', 'mccCB.mat');

p = piAssetTreeSave(subTree, matList, 'outFilePath', outputPath);

%{
piWrite(thisR);
scene = piRender(thisR, 'render type', 'all', 'scaleIlluminance', false);
sceneWindow(scene);
%}

%% Load mcc asset
loadedAsset = piAssetTreeLoad('mccCB');
%}