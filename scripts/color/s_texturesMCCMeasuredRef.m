% s_texturesMCCMeasuredRef
%
% Use measured reflectances of MCC checker to generate texture
%
%% Init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read measured MCC reflectances
wave = 400:10:700;
% Allow extrapolation
extrapVal = 'extrap';
mccRefl = ieReadSpectra('macbethChart', wave, extrapVal);
nSamples = size(mccRefl, 2);

%{
% Plot 4x6
rows = 6; cols = 4;
ieNewGraphWin;
for ii = 1:size(mccRefl, 2)
subplot(rows, cols, ii)
plot(wave, mccRefl(:,ii))
title(sprintf('Number %d', ii))
end
%}

%% Basis function analysis
[mccBasis, wgts] = basisAnalysis(mccRefl, wave, 'vis', true, 'nBasis', 3);

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

%% Goal here is convert wgts to lrgb space (finally) use a matrix tranasformation
% We can later inverse the matrix so we can put linear RGB values in the texture
% map
% The euqation should be:
% tmp = ((xyz2lrgb)' * xyz' * basisFunction * wgts);
% maxRGB = max(tmp(:));
% lrgb = tmp / maxRGB;
% 
% So let M = (xyz2lrgb)' * xyz' * basisFunction / maxRGB; then
% lrgb = M * wgts

% Read in XYZ
xyz = ieReadSpectra('XYZ', wave);

matrix = colorTransformMatrix('xyz2lrgb');
tmp = matrix' * xyz' * mccBasis * wgts;
maxRGB = max(tmp(:));
M = matrix' * xyz' * mccBasis / maxRGB;

% The direct transformation is:
lrgb = M * wgts;
%{
lrgb = XW2RGBFormat(lrgb', 4, 6);

rgbLarge = imageIncreaseImageRGBSize(lrgb, 20);
ieNewGraphWin;

imagesc(rgbLarge);
%}
% Clip the rgb values so they are in (0, 1) range.
lrgb = ieClip(lrgb, 0, 1);

%{
% Validate the reflectance from basis * wgts vs basis * M^-1 * lrgb
refTrue = mccBasis * wgts;
refLrgb = mccBasis * inv(M) * lrgb;

thisRefl = 11;
ieNewGraphWin;
plot(wave, refTrue(:,thisRefl), 'r', wave, refLrgb(:,thisRefl), 'b', wave, mccRefl(:,thisRefl));
legend('Basis with wgts', 'Basis with lrgb', 'Real')
%}

%% Create the texture map here, use it later after writing out the recipe
mccTextureWgts = piTextureImgMap(mccTextureMask, wgts);
mccTextureLrgb = piTextureImgMap(mccTextureMask, lrgb);
%% Save basis functions

% Save the basis functions
comment = 'MCC reflection basis functions';
fname = fullfile(piRootPath,'data','basisFunctions','mccReflectance');
ieSaveSpectralFile(wave, mccBasis * inv(M), comment, fname);
% ieSaveSpectralFile(wave, mccBasis, comment, fname);

%% Now create a recipe
thisR = piRecipeDefault('scene name', 'flatSurfaceMCCTexture');

%% Check and remove all lights
piLightGet(thisR); % Should be nothing

% Add a new equalEnergy light
thisR = piLightAdd(thisR, 'type', 'distant', 'camera coordinate', true,...
                    'light spectrum', 'equalEnergy');
%% Set texture don't use gamma correction
textureIdx = 1;
piTextureSet(thisR, textureIdx, 'bool gamma', 'false');

%% Check texture list
piTextureList(thisR);

%% Set the basis function 
basisFunctionsFileName = 'mccReflectance.mat';
piTextureSetBasis(thisR, textureIdx, wave, 'basis functions', basisFunctionsFileName);

%% Write the mccTexture file.
% Change texture file name
textureIdx = 1;
% piTextureSet(thisR, textureIdx, 'stringfilename', 'mcc_wgts.exr');
piTextureSet(thisR, textureIdx, 'stringfilename', 'mcc_lrgb.exr');

% Write out the exr file
[fPath, ~, ~] = fileparts(thisR.outputFile);
% textureImgPath = fullfile(fPath, 'mcc_wgts.exr');
% exrwrite(mccTextureWgts, textureImgPath);
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