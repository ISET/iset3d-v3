% Render scenes of differet types
%
% Description:
%    Use PBRT to render radiance image, depth matte,
%    radiance image with all surfaces matte, and %
%    reflectance map.
%
%    The recipe is store in local/scences/ColorfulScene.
%    The rendered data end up in the same directory.
%
%    Wavelength sampling is [400 10 31], set by precompiled
%    renderers.
%
%    There are some scenes available via RDT.  Run
%      piPBRTList
%    to get a list.  Run
%      piPBRTFetch('ColorfulScene','pbrt version',3,'destination folder',fullfile(piRootPath,'local','scenes'));
%    to get the one we use here.
%
%    After the renderings are completed, the tutorial processes these and
%    saves key images in a .mat file.  The processing provides a set of
%    intrinsic images for use in analysis and machine learning application.
%    Currently, these are provided for the rendered image at one selected
%    wavelength, but one could process all wavelengths if one wanted.
%
%    Results are written into the local directory of the iset3d repository,
%    which is not uploaded to git.

% ToolboxToolbox Command:
%{
    % BrainardLab toolbox is only needed for FigureSave, and that call is
    % skipped if not available, so that this should run if iset3d and all
    % dependencies as described in the TbTb registry iset3d.json configuration
    % are available.
    tbUse({'iset3d', 'BrainardLabToolbox'});
%}

% History
%   xx/xx/19  zl      Written
%   09/28/19  dhb     Comments, post-processing.

%% Initialize
ieInit;
if ~piDockerExists, piDockerConfig; end

%% This is if you want to use the Google cloud
%if ~mcGcloudExists, mcGcloudConfig; end

%% Specify and get scene recipe
sceneName = 'ColorfulScene';
inputFile = fullfile(piRootPath, 'local', 'scenes', sceneName, [sceneName, '.pbrt']);
thisR = piRead(inputFile);

%% Prevent zero reflectances
%thisR.set('output file', fullfile(piRootPath, 'local', sceneName, [sceneName, '_blackfix', '.pbrt']));
thisR = piZeroReflectanceCheck(thisR);

%% Set rending quality parameters
%
% These are for PBRT.  Reduce pixel samples to,
% say, 16 for testing.  Can increase max depth
% for more bounces, reduce for faster.
% thisR.set('film resolution',[1200 900]);
% thisR.set('pixel samples',4096);
% thisR.set('max depth',5); 
thisR.set('film resolution',[1200 900]/2);
thisR.set('pixel samples',16);
thisR.set('max depth',5); 

%% Render radiance and depth
%
% This basic render gets both the radiance and depth maps
piWrite(thisR);
ieObject = piRender(thisR,'render type','both');
sceneWindow(ieObject);

%% Process recipe to make all the materials to be matte
%
% Sets output file to contain '_matte' so it does not overwrite the
% rendering done just above.
matteR = thisR;
matteR.set('output file', fullfile(piRootPath, 'local', sceneName, [sceneName, '_matte', '.pbrt']));
materialNameList = fieldnames(thisR.materials.list);
for ii = 1:length(materialNameList)
    target = matteR.materials.lib.matte;
    piMaterialAssign(matteR, materialNameList{ii}, target);
end
piWrite(matteR);
ieObject = piRender(matteR,'render type','radiance');
sceneWindow(ieObject);

%% Render reflectance map return NxNx31 image data.
%
% Each pixel has the diffuse spectral reflectance spectrum
% at that location.
reflectanceMap = piRender(matteR, 'render type', 'reflectance');
figure; imagesc(reflectanceMap(:,:,1));

%% Process images into a more generic form
%
% This bit is useful for collaborating with someone who
% wants to analyze the image data but doesn't know about
% iset3D or isetbio.
thisRenderFile = fullfile(piRootPath, 'local',  sceneName, 'renderings',[sceneName, '.dat']);
thisScene = piDat2ISET(thisRenderFile,'recipe',thisR);

%% Get wavelengths and specify one to process.
wls = sceneGet(thisScene,'wavelength');
whichWavelength = 540;
wlIndex = find(wls == whichWavelength);

%% Get the LMS and luminance image data
%
% This comes to us easily via the wonders of isetbio.
lmsImage = sceneGet(thisScene,'lms');
luminanceImage = sceneGet(thisScene,'luminance');

% The specular highlights make it a bit hard to
% see the detail; make a version that is tone
% mapped in a very simple way.
toneMapFactor = 3;
meanLuminance = mean(luminanceImage(:));
toneMappedLuminanceImage = luminanceImage;
toneMappedLuminanceImage(luminanceImage(:) > toneMapFactor*meanLuminance) = toneMapFactor*meanLuminance;

% Show the luminance image. The specular highlights
% make it a bit hard to see detail, so we also show
% a tone-mapped version
lumFigure = figure; clf; set(gcf,'Position',[100 100 1200 760]);
subplot(1,2,1);
imshow(luminanceImage/max(luminanceImage(:)));
title('Luminance Image');
subplot(1,2,2);
imshow(toneMappedLuminanceImage/max(toneMappedLuminanceImage(:)));
title('Luminance Image, Tone Mapped');

%% Get the radiance image in energy units
%
% Then pull out wavelength of interest as
% a grayscale image, and show raw and tone
% mapped versions
radianceImage = sceneGet(thisScene,'energy');
monoRadianceImage = squeeze(radianceImage(:,:,wlIndex));

% Create figure and show monochromatic radiance image
allFigure = figure; clf;
set(gcf,'Position',[1000 200 1300 1150]);
subplot(5,2,1); 
imshow(monoRadianceImage/max(monoRadianceImage(:)));
title(sprintf('Monochromatic Radiance, %d nm', whichWavelength));

% Tone map radiance image and add to figure.
meanLuminance = mean(monoRadianceImage(:));
toneMappedMonoRadianceImage = monoRadianceImage;
toneMappedMonoRadianceImage(monoRadianceImage(:) > toneMapFactor*meanLuminance) = toneMapFactor*meanLuminance;
figure(allFigure); subplot(5,2,2);
imshow(toneMappedMonoRadianceImage/max(toneMappedMonoRadianceImage(:)));
title(sprintf('Tone Mapped Monochromatic Radiance, %d nm', whichWavelength));

% Read in the matte version and show, both without and with tone mapping.
matteRenderFile = fullfile(piRootPath, 'local',  sceneName, 'renderings',[sceneName,'_matte','.dat']);
matteScene = piDat2ISET(matteRenderFile,'recipe',matteR);
matteRadianceImage = sceneGet(matteScene,'energy');
monoMatteRadianceImage = squeeze(matteRadianceImage(:,:,wlIndex));
figure(allFigure); subplot(5,2,3);
imshow(monoMatteRadianceImage/max(monoMatteRadianceImage(:)));
title(sprintf('Matte Monochromatic Radiance, %d nm', whichWavelength));

meanLuminance = mean(monoMatteRadianceImage(:));
toneMappedMonoMatteRadianceImage = monoMatteRadianceImage;
toneMappedMonoMatteRadianceImage(monoMatteRadianceImage(:) > toneMapFactor*meanLuminance) = toneMapFactor*meanLuminance;
figure(allFigure); subplot(5,2,4);
imshow(toneMappedMonoMatteRadianceImage/max(toneMappedMonoMatteRadianceImage(:)));
title(sprintf('Tone Mapped Matte Monochromatic Radiance, %d nm', whichWavelength));

% Add the reflectance map, which we have in memory.
monoMatteReflectanceImage = squeeze(reflectanceMap(:,:,wlIndex));
figure(allFigure); subplot(5,2,5);
imshow(monoMatteReflectanceImage);
title(sprintf('Monochromatic Reflectance Image, %d nm',whichWavelength));

% Get the depth map and show it
depthRenderFile = fullfile(piRootPath, 'local',  sceneName, 'renderings',[sceneName,'_depth','.dat']);
depthImage = piDat2ISET(depthRenderFile,'label', 'depth');
figure(allFigure); subplot(5,2,6);
imshow(depthImage/max(depthImage(:)));
title('Depth Map');

%% Compute illumination intrinsic image
%
% This is obtained by pixel-wise division of the matte radiance image
% by the reflectance image.  
%
% Need to do a little stabization to prevend divide by 0.
divideThreshold = 0.001;
monoReflectanceDivideImage = monoMatteReflectanceImage;
monoReflectanceDivideImage(monoReflectanceDivideImage < divideThreshold) = divideThreshold;
monoIlluminationImage = monoMatteRadianceImage ./ monoReflectanceDivideImage;

% There really should not be any inf pixels, but check anyway and set to
% NaN
if (any(isinf(monoIlluminationImage)))
    fprintf('Surprising infinite values in illumination intrinsic image\n')
else
    fprintf('No infinite values in illumination intrinsic image - good\n');
end
monoIlluminationImage(isinf(monoIlluminationImage)) = NaN;

% Add to figure, without and with tone mapping.
figure(allFigure); subplot(5,2,7);
imshow(monoIlluminationImage/nanmax(monoIlluminationImage(:)));
title(sprintf('Monochromatic Illumination Image, %d nm',whichWavelength));

meanLuminance = nanmean(monoIlluminationImage(:));
toneMappedMonoMatteIlluminationImage = monoIlluminationImage;
toneMappedMonoMatteIlluminationImage(monoIlluminationImage(:) > toneMapFactor*meanLuminance) = toneMapFactor*meanLuminance;
figure(allFigure); subplot(5,2,8);
imshow(toneMappedMonoMatteIlluminationImage / nanmax(toneMappedMonoMatteIlluminationImage(:)));
title(sprintf('Tone Mapped Monochromatic Illumination Image, %d nm',whichWavelength));

% Get specular highlight image
%
% This is the full radiance image less the matte radiance image.
% Add to figure without and with tone mapping.
monoHighlightImage = monoRadianceImage - monoMatteRadianceImage;
figure(allFigure); subplot(5,2,9);
imshow(monoHighlightImage/nanmax(monoHighlightImage(:)));
title(sprintf('Monochromatic Highlight Image, %d nm',whichWavelength));

meanLuminance = nanmean(monoHighlightImage(:));
toneMappedMonoHighlightImage = monoHighlightImage;
toneMappedMonoHighlightImage (monoHighlightImage(:) > toneMapFactor*meanLuminance) = toneMapFactor*meanLuminance;
figure(allFigure); subplot(5,2,10);
imshow(toneMappedMonoHighlightImage /nanmax(toneMappedMonoHighlightImage(:)));
title(sprintf('Tone Mapped Monochromatic Highlight Image, %d nm',whichWavelength));

%% Reconstruct the radiance image from the intrinsic image pieces
%
% Show in a separate figure, without and with tone mapping.
monoReconstructedImage = (monoMatteReflectanceImage  .* monoIlluminationImage) + monoHighlightImage;
reconFigure = figure; clf; set(gcf,'Position',[100 100 1200 760]);
subplot(1,2,1);
imshow(toneMappedMonoRadianceImage/max(toneMappedMonoRadianceImage(:)));
title(sprintf('Tone Mapped Monochromatic Radiance, %d nm', whichWavelength));

meanLuminance = nanmean(monoReconstructedImage(:));
toneMappedMonoReconstructedImage = monoReconstructedImage;
toneMappedMonoReconstructedImage(monoReconstructedImage(:) > toneMapFactor*meanLuminance) = toneMapFactor*meanLuminance;
subplot(1,2,2);
imshow(toneMappedMonoReconstructedImage/max(toneMappedMonoReconstructedImage(:)));
title(sprintf('Tone Mapped Reconstructed Monochromatic Radiance, %d nm', whichWavelength));

%% Save image data into a matte file, as well as some figures.
%
% Figures
saveDir = fullfile(piRootPath, 'local',  sceneName, 'processedRenderings');
if (~exist(saveDir,'dir'))
    mkdir(saveDir);
end
if (exist('FigureSave','file'))
    FigureSave(fullfile(saveDir,[sceneName '_ReconstructedImage']),reconFigure,'pdf');
    FigureSave(fullfile(saveDir,[sceneName '_AllImages']),allFigure,'pdf');
end

% Images saved:
%   monoRadianceImage: monochromatic radiance image
%   monoMatteRadianceImage: monochromatic radiance image, all surfaces matte
%   monoReflectanceImage: monochromatic surface reflectance image
%   monoIlluminationImage: monoMatteRadianceImage ./ monoReflectanceImage
%      Values in monoReflectanceImage below a threshold are set
%      to the threshold.  Currently threshold is 0.001.
%   monoHighlightImage: (monoRadianceImage-monoMatteRadianceImage)
%   depthImage: distance to surface at each pixel
save(fullfile(saveDir,[sceneName '_TestImages']),'monoRadianceImage','monoMatteRadianceImage','monoMatteReflectanceImage','monoIlluminationImage','monoHighlightImage','monoReconstructedImage','depthImage');
