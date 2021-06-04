% s_texturesMCCRefVal
% Validate reflectances between PBRT rendering and manual calculation using
% basis function and rgb values.
%
% Note:
% The resolution of MCC texture image is 128 x 192, with patch size of 32.
% The numbers are useful for figure plots.
%
% Zheng Lyu, 2020
%% Init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the flatSurfaceTexture scene
thisR = piRecipeDefault('scene name', 'flatSurfaceMCCTexture');

%% Use the original resolution
thisR.set('filmresolution', [192, 128])
thisR.sampler.pixelsamples.value = 32;
thisR.integrator.maxdepth.value = 5;

%% Check and remove all lights
piLightGet(thisR); % Should be nothing

% Add a new equalEnergy light
distantLight = piLightCreate('distantLight', ...
    'type','distant',...
    'spd','equalEnergy',...
    'cameracoordinate', true);
thisR.set('light','add',distantLight);

% thisR = piLightAdd(thisR, 'type', 'distant', 'camera coordinate', true,...
%                     'light spectrum', 'equalEnergy');
%% Check texture list

piTexturePrint(thisR);
%% Set texture not use gamma correction
% In PBRT when reading a rgb image texture, it assumes the pixel values are
% sRGB values. So it does a inverse processing and it changes the actual
% rgb value used for reflectance estimation. We should turn the gamma flag
% off do disable that inverse processing. Alternatively, we also validate
% by convert RGB value with the same way as PBRT does using srgb2lrgb()
% function. See below.
textureIdx = 1;
piTextureSet(thisR, textureIdx, 'bool gamma', 'false');
%% Now set the basis function 

basisFunctionsFileName = 'pbrtReflectance.mat';
piTextureSetBasis(thisR, textureIdx, wave, 'basis functions', basisFunctionsFileName);

%% Write the recipe
piWrite(thisR, 'overwritematerials', true);

%% Render the scene
thisDocker = 'vistalab/pbrt-v3-spectral:basisfunction';
wave = 365:5:705;
[scene, ~] = piRender(thisR, 'dockerimagename', thisDocker,'wave', wave, 'render type', 'illuminant');
sceneName = 'SVD processed basis (no srgb2lrgb)';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);

%% Get reflectance map
reflectance = sceneGet(scene, 'reflectance');

%% Read in the RGB image for comparison
img = im2double(imread('mcc.png'));
%{
ieNewGraphWin
imagesc(img)
%}
%% Select different positions for reflectance comparison
% Read in basis functions
basisFunctions = ieReadSpectra(basisFunctionsFileName, wave);

% Generate a nx2 matrix where includes n pixel points and its coordinates.
[r, c, h] = size(reflectance);
patchSize = 32;
rows = 10:patchSize:r;
cols = 10:patchSize:c;
[A,B] = meshgrid(rows,cols);
c=cat(2,A',B');
rowcol=reshape(c,[],2);

ieNewGraphWin;
for ii = 1:size(rowcol, 1)
    subplot(numel(rows), numel(cols), ii);
    rgb = squeeze(img(rowcol(ii, 1), rowcol(ii, 2), :));
    eReflectance = basisFunctions * rgb;
    rReflectance = squeeze(reflectance(rowcol(ii, 1), rowcol(ii, 2), :));
    plot(wave, rReflectance, 'r', wave, eReflectance, 'b');
    legend('Estimated in PBRT',...
           'Estimated directly');
end


%% Another comparing approach: use srgb2lrgb in iset3d on RGB values
% The only purpose is to make rendered scene closer to what image is
% displayed on screens.

%% Read the flatSurfaceTexture scene
textureIdx = 1;
piTextureSet(thisR, textureIdx, 'bool gamma', 'true');

%% Write the recipe again
piWrite(thisR, 'overwritematerials', true);

%% Render the scene
thisDocker = 'vistalab/pbrt-v3-spectral:basisfunction';
wave = 365:5:705;
[scene, ~] = piRender(thisR, 'dockerimagename', thisDocker,'wave', wave, 'render type', 'illuminant');
sceneName = 'SVD processed basis (srgb2lrgb)';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);

%% Get reflectance map
reflectance = sceneGet(scene, 'reflectance');

%% Use srgb2lrgb fur basisFUnctions
ieNewGraphWin;
for ii = 1:size(rowcol, 1)
    subplot(numel(rows), numel(cols), ii);
    rgb = squeeze(img(rowcol(ii, 1), rowcol(ii, 2), :));
    eReflectance = basisFunctions * srgb2lrgb(rgb);
    rReflectance = squeeze(reflectance(rowcol(ii, 1), rowcol(ii, 2), :));
    plot(wave, rReflectance, 'r', wave, eReflectance, 'b');
    legend('Estimated in PBRT',...
           'Estimated directly');
end