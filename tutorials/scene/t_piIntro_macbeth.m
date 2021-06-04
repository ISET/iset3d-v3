%% Render MacBeth color checker
%
% Description:
%   Render a MacBeth color checker along with its illumination
%   and depth map.
% 
% Index numbers for MacBeth color checker:
%          ---- ---- ---- ---- ---- ----
%         | 01 | 05 | 09 | 13 | 17 | 21 |
%          ---- ---- ---- ---- ---- ----
%         | 02 | 06 | 10 | 14 | 18 | 22 | 
%          ---- ---- ---- ---- ---- ----
%         | 03 | 07 | 11 | 15 | 19 | 23 | 
%          ---- ---- ---- ---- ---- ----
%         | 04 | 08 | 12 | 16 | 20 | 24 | 
%          ---- ---- ---- ---- ---- ----
%
% Dependencies:
%
%    ISET3d, (ISETCam or ISETBio), JSONio
%
% Author:
%   ZLY, BW, 2020
%
% See also
%   t_piIntro_*

% History:
%   10/28/20  dhb  Explicitly show how to compute and look at depth map and
%                  illumination map. The header comments said it did the
%                  latter two, and now it does.

%% init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the recipe
%
% The MCC image is the default recipe.  We do not write it out yet because
% we are going to change the parameters
thisR = piRecipeDefault;

%% Change the light
%
% There is a default point light.  We delete that.
thisR = piLightDelete(thisR, 'all');

% Add an equal energy distant light for uniform lighting
spectrumScale = 1;
lightSpectrum = 'equalEnergy';
newDistant = piLightCreate('new distant',...
                           'type', 'distant',...
                           'specscale float', spectrumScale,...
                           'spd spectrum', lightSpectrum,...
                           'cameracoordinate', true);
thisR.set('light', 'add', newDistant);
%% Set an output file
%
% This is pretty high resolution given the nature of the target.
thisR.set('integrator subtype','path');
thisR.set('rays per pixel', 16);
thisR.set('fov', 30);
thisR.set('filmresolution', [640, 360]*2);

%% Write the scene
%
% Write modified recipe out.  We changed the materials, so we overwrite the
% material file.
piWrite(thisR);

%% Render and display.
%
% By default we get the radiance map and the depth map. The depth map is
% distance from camera to each point along the line of sight.  See
% t_piIntro_macbeth_zmap for how to compute a zmap.
[scene, result] = piRender(thisR,'render type','all',...
                                'scaleIlluminance', false);
sceneWindow(scene);

% Plot the depth map.  For some reason scenePlot just shows this as all
% black, probably an issue of scaling. The code below normalizes and you
% can see it.  Hard to tell that it isn't flat from the image,
%
% scenePlot(scene,'depth map');
theDepthMap = sceneGet(scene,'depthMap');
figure; imshow(theDepthMap/max(theDepthMap(:)))
title('Depth Map');

% The illumination map is in the scene.  Get it and show it.
wavelengths = sceneGet(scene,'wavelength');
illuminantHyperspectralImage = sceneGet(scene,'illuminant photons');
theWavelength = 550;
illuminantImagePlane = illuminantHyperspectralImage(:,:,wavelengths == theWavelength);
figure; imshow(illuminantImagePlane/max(illuminantImagePlane(:)));
title(sprintf('Illumination Map (%d nm)',theWavelength));
