% s_texturesMouthMeasuredRef
%
% Render mouth model with measured mouth reflectance data. Evaluate the
% effectiveness by checking chromaticity map.
%
% Zheng Lyu, 2020
%% Init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read mouth basis function and related parameters
% Specify wavelength range
wave = 365:5:705;
load('mouthReflectance');

% Some parameter name translation
wgts = mcCOEF;
mWgts2lrgb = comment.mWgts2lrgb;
lrgb = mWgts2lrgb * wgts;
%% Generate texture map with 2D texture map

% Read in the image
mouthFolder = fullfile(piRootPath, 'local', 'pose_realistic');
colorImgPath = fullfile(mouthFolder, 'Mouth color map.png');
mouthImg = im2double(imread(colorImgPath));
mouthImg = imresize(mouthImg, [256, 256]);
%{
ieNewGraphWin;
imagesc(mouthImg);
%}
[rows, cols, ~] = size(mouthImg);
mouthTextureMask = zeros(rows, cols);

whichSample = 1;
mouthTextureMask(mouthImg(:,:, 1) ~= 0 | mouthImg(:,:, 2) ~= 0 |...
                 mouthImg(:,:, 3) ~= 0) = whichSample;

mouthTextureWgts = piTextureImgMap(mouthTextureMask, wgts);

% This is used for visualization
mouthTextureLrgb = piTextureImgMap(mouthTextureMask, lrgb);

%{
ieNewGraphWin;
imagesc(mouthTextureLrgb);
%}

%{
% Check the estimated reflectance and measured data
thisRefl = 1;
eReflectance1 = mouthBasis * wgts(:,thisRefl);
eReflectance2 = mouthBasis * inv(mWgts2lrgb) * lrgb(:,thisRefl);

ieNewGraphWin;
plot(wave, eReflectance1, wave, eReflectance2, wave, mouthRefl(:,thisRefl));
grid on; ylim([0 1])
legend('Estimated (wgts)', 'Estimated(lrgb)', 'Measured');
xlabel('wavelength (nm)'); ylabel('Reflectance')
%}

%% Write out mouthImgBinary (texture map) as exr image
textureImgPathWgts = fullfile(mouthFolder, 'Mouth_color_map_wgts_uniform.exr');
exrwrite(mouthTextureWgts, textureImgPathWgts);

% For visualization
textureImgPathLrgb = fullfile(mouthFolder, 'Mouth_color_map_lrgb_uniform.exr');
exrwrite(mouthTextureLrgb, textureImgPathLrgb);
%% Check image
%{
im = exrread(textureImgPath);
ieNewGraphWin;
imagesc(im);

img = imread(textureImgPathLrgb);
ieNewGraphWin;
imagesc(img)
%}

%% 
fname = fullfile(piRootPath, 'local', 'mouth_model',...
                'higher_res_mesh_segmentation_mouth.pbrt');
thisR = piRead(fname);

%% Use lower resolution
thisR.set('filmresolution', [360, 360])
thisR.sampler.pixelsamples.value = 32;
thisR.integrator.maxdepth.value = 1;

%% Clear all light and add oraleye light

piLightDelete(thisR, 'all');
distantLight = piLightCreate('distantLight', ...
    'type','distant',...
    'spd','OralEye_UV',...
    'cameracoordinate', true);
thisR.set('light','add',distantLight);

% thisR = piLightAdd(thisR,...
%     'type','distant',...
%     'light spectrum','OralEye_UV',...
%     'spectrumscale', 1,...
%     'cameracoordinate', true); 
piLightGet(thisR);
%% Check texture list
piTexturePrint(thisR);

%% Change the texture info
textureIdx = 3;
piTextureSet(thisR, textureIdx, 'bool gamma', 'false');
piTextureSet(thisR, textureIdx, 'stringwrap', 'absolute');
piTextureSet(thisR, textureIdx, 'stringfilename', 'Mouth_color_map_wgts_uniform.exr');

%%
basisFunctionsFileName = 'mouthReflectance.mat';
piTextureSetBasis(thisR, textureIdx, wave, 'basis functions', basisFunctionsFileName);
%% Write the recipe
piWrite(thisR, 'overwritematerials', true);

%% Render the scene
thisDocker = 'vistalab/pbrt-v3-spectral:basisfunction';
[scene, ~] = piRender(thisR, 'dockerimagename', thisDocker,'wave', wave, 'render type', 'illuminant');
sceneName = 'Mouth rendered with basis functions';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);

%% Validate the effectiveness of this method by evaluating chromaticity map.
% To do so, we need to run through the rest parts of imaging pipeline:
% Optical image, sensor, and ip.

%% Compute optical image
oi = oiCreate;
oi = oiCompute(oi, scene);

oiWindow(oi);

%% Compute sensor data
sensor = oeSensorCreate('wave', wave);
quanMethod = '12 bit';
sensor = sensorSet(sensor,'quantization method',quanMethod);
sensor = sensorSet(sensor, 'size', [400, 400]);
sensor = sensorSet(sensor, 'noise flag', 2);
sensor = sensorCompute(sensor, oi);

qe = sensorGet(sensor, 'spectral QE');
ieNewGraphWin;
plot(wave, qe)
% sensorWindow(sensor)

%%  Get digital image and demosaic 
im = sensorGet(sensor, 'digital values');
im = demosaic(uint16(im), 'grbg');
im = double(im) / double(2^12);
im = ieClip(im, 0, 1);
imshow(im)
%% Check chromaticity
rect = [125, 317, 20, 20];
roi = imcrop(im, rect);
% imshow(roi)

roirgEdge = chromaticity(roi);
meanR = roirgEdge(:,:,1); meanR = mean(meanR(:));
meanG = roirgEdge(:,:,2); meanG = mean(meanG(:));

ieNewGraphWin;
hold on
plot(roirgEdge(:,:,1),roirgEdge(:,:,2),'r.');
plot(meanR, meanG, 'bo');
set(gca,'xlim',[0 1],'ylim',[0 1]); grid on
xlabel('r'); ylabel('g');
