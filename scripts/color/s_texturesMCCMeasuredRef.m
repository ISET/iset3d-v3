% s_texturesMCCMeasuredRef
% 
% Render MCC with measured reflectance.
% 
% Warning: doesn't work very well.
%
% Zheng Lyu, 2020
%% Init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read mcc basis function and related parameters
% Specify wavelength range
wave = 365:5:705;
load('mccReflectance');

% Some parameter name translation
wgts = mcCOEF;
mWgts2lrgb = comment.mWgts2lrgb;
lrgb = mWgts2lrgb * wgts;

%{
eRefl = basis * wgts;
thisRefl = 7;
ieNewGraphWin;
plot(wave, eRefl(:,thisRefl));
%}
%%

% Read image and get RGB values
img = im2double(imread('mcc.png'));
[width, height, h] = size(img);
patchSize = 32;
rows = 1:patchSize:width;
cols = 1:patchSize:height;
[A,B] = meshgrid(rows,cols);
c=cat(2,A',B');
rowcol=reshape(c,[],2);

mccTextureMask = zeros(width,height);
for ii = 1:size(rowcol, 1)
sRow = rowcol(ii, 1); sCol = rowcol(ii, 2);
mccTextureMask(sRow:sRow+patchSize-1, sCol:sCol+patchSize-1) = ii;
end
%{
% Check if we give the correct index to texture mask
ieNewGraphWin;
imagesc(mccTextureMask);
%}

%% Create the texture map here, use it later after writing out the recipe
mccTextureWgts = piTextureImgMap(mccTextureMask, wgts);
mccTextureLrgb = piTextureImgMap(mccTextureMask, lrgb);

%{
ieNewGraphWin;
imagesc(mccTextureWgts);
%}
%% Now create a recipe
thisR = piRecipeDefault('scene name', 'flatSurfaceMCCTexture');

%% Check and remove all lights
piLightGet(thisR); % Should be nothing

% Add a new equalEnergy light
distantLight = piLightCreate('distantLight', ...
    'type','distant',...
    'spd','equalEnergy',...
    'cameracoordinate', true);
thisR.set('light','add',distantLight);

% thisR = piLightAdd(thisR, 'type', 'distant', ...
%     'camera coordinate', true,...
%     'light spectrum', 'D65');

%% Set texture don't use gamma correction
textureIdx = 1;
piTextureSet(thisR, textureIdx, 'bool gamma', 'false');
piTextureSet(thisR, textureIdx, 'stringwrap', 'absolute');
%% Check texture list
piTexturePrint(thisR);

%% Set the basis function 
basisFunctionsFileName = 'mccReflectance.mat';
piTextureSetBasis(thisR, textureIdx, wave, 'basis functions', basisFunctionsFileName);

%% Set mccTexture file.
% Change texture file name
textureIdx = 1;
piTextureSet(thisR, textureIdx, 'stringfilename', 'mcc_wgts.exr');

%% Write out the exr texture file
[fPath, ~, ~] = fileparts(thisR.outputFile);

textureImgPath = fullfile(fPath, 'mcc_wgts.exr');
exrwrite(mccTextureWgts, textureImgPath);

% Save for visualization
textureImgPath = fullfile(fPath, 'mcc_lrgb.exr');
exrwrite(mccTextureLrgb, textureImgPath);

%% Write the recipe
piWrite(thisR, 'overwritematerials', true);

%% Render the scene
thisDocker = 'vistalab/pbrt-v3-spectral:basisfunction';
[scene, ~] = piRender(thisR, 'dockerimagename', thisDocker,'wave', wave, 'render type', 'illuminant');
sceneName = 'MCC rendered with basis functions';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);