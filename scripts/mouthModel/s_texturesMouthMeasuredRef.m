% s_texturesMouthMeasuredRef
%
% Generate basis functions for Use measured reflectances of mouth 
%
%% Init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read measured mouth reflectances
wave = 365:5:705;
% Allow extrapolation
% extrapVal = 'extrap';
extrapVal = 0;
mouthRefl = ieReadSpectra('reflectances', wave, extrapVal);
% Manually set reflectance out of 380:5:700 to be zero
% mouthRefl(wave < 380 | wave > 700, :) = 0;
nSamples = size(mouthRefl, 2);

%% Basis function analysis
[mouthBasis, wgts] = basisAnalysis(mouthRefl, wave, 'vis', true);

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
tmp = matrix' * xyz' * mouthBasis * wgts;
maxRGB = max(tmp(:));
M = matrix' * xyz' * mouthBasis / maxRGB;

% The direct transformation is:
lrgb = M * wgts;

% Clip the rgb values so they are in (0, 1) range (this can cost some error).
lrgb = ieClip(lrgb, 0, 1);

%{
% Validate the reflectance from basis * wgts vs basis * M^-1 * lrgb
refTrue = mouthBasis * wgts;
refLrgb = mouthBasis * inv(M) * lrgb;

max(abs(refTrue - refLrgb))
thisRefl = 1;
ieNewGraphWin;
plot(wave, refTrue(:,thisRefl), 'r', wave, refLrgb(:,thisRefl), 'b');
legend('Basis with wgts', 'Basis with lrgb')

%}

%% Save basis functions
comment = 'Mouth reflection basis functions';
fname = fullfile(piRootPath,'data','basisFunctions','mouthReflectance');
newMouthBasis = mouthBasis * inv(M);
ieSaveSpectralFile(wave, newMouthBasis, comment, fname);

%%

% Read in the image
mouthFolder = fullfile(piRootPath, 'local', 'mouth_model');
colorImgPath = fullfile(mouthFolder, 'Mouth color map.png');
mouthImg = im2double(imread(colorImgPath));
mouthImg = imresize(mouthImg, [256, 256]);
%{
ieNewGraphWin;
imagesc(mouthImg);
%}
[rows, cols, ~] = size(mouthImg);
mouthTextureMask = zeros(rows, cols);

mouthTextureMask(mouthImg(:,:, 1) ~= 0 | mouthImg(:,:, 2) ~= 0 |...
                 mouthImg(:,:, 3) ~= 0) = 1;

mouthTextureWgts = piTextureImgMap(mouthTextureMask, wgts);
mouthTextureLrgb = piTextureImgMap(mouthTextureMask, lrgb);
%{
mouthTexture(:,:,1) = mouthTextureMask * lrgb(1, 1);
mouthTexture(:,:,2) = mouthTextureMask * lrgb(2, 1);
mouthTexture(:,:,3) = mouthTextureMask * lrgb(3, 1);
%}

%{
ieNewGraphWin;
imagesc(mouthTextureLrgb);
%}

%{
% Check the estimated reflectance and measured data
thisRefl = 1;
eReflectance1 = mouthBasis * wgts(:,thisRefl);
eReflectance2 = mouthBasis * inv(M) * lrgb(:,thisRefl);

ieNewGraphWin;
plot(wave, eReflectance1, wave, eReflectance2, wave, mouthRefl(:,thisRefl));
grid on; ylim([0 1])
legend('Estimated (wgts)', 'Estimated(lrgb)', 'Measured');
xlabel('wavelength (nm)'); ylabel('Reflectance')
%}

%% Write out mouthImgBinary (texture map) as exr image
textureImgPathWgts = fullfile(mouthFolder, 'Mouth_color_map_wgts.exr');
exrwrite(mouthTextureWgts, textureImgPathWgts);

textureImgPathLrgb = fullfile(mouthFolder, 'Mouth_color_map_lrgb.exr');
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
thisR = piLightAdd(thisR,...
    'type','distant',...
    'light spectrum','OralEye_UV',...
    'spectrumscale', 1,...
    'cameracoordinate', true); 
piLightGet(thisR);
%% Check texture list
piTextureList(thisR);

%% Change the texture info
textureIdx = 3;
piTextureSet(thisR, textureIdx, 'bool gamma', 'false');
piTextureSet(thisR, textureIdx, 'stringfilename', 'Mouth_color_map_lrgb.exr');
% piTextureSet(thisR, textureIdx, 'stringfilename', 'Mouth_color_map_wgts.exr');

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
