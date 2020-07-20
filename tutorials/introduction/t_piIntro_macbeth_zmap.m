%% t_piIntro_macbeth_zmap
%
% Render a MacBeth color checker. We render both an illuminant image
% and a zmap image.  The illuminant is spatio-spectral.  
%
% The zmap differs from the depth map.  It is the z-coordinate, not
% the distance from the camera to the point.
%
% See t_piIntro_macbeth to calculate the depth map rather than the
% zmap.
% 
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

%% init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the recipe
thisR = piRecipeDefault('write',false);

%% Change the light

% There is a default point light.  We delete that.
%{
    lightSources = piLightGet(thisR)
%}
thisR = piLightDelete(thisR, 'all');

% Add an equal energy distant light
spectrumScale = 1;
lightSpectrum = 'equalEnergy';
thisR = piLightAdd(thisR,...
    'type','distant',...
    'light spectrum',lightSpectrum,...
    'spectrumscale', spectrumScale,...
    'cameracoordinate', true);

%% Set rendering parameters 

thisR.set('integrator subtype','path');
thisR.set('pixelsamples', 16);
thisR.set('filmresolution', [640, 360]);

%% Write 

piWrite(thisR, 'overwritematerials', true);

%% Render the scene and the illuminant

% This case uses the default docker image, that does not incorporate
% fluorescence rendering.  'all' means the illuminant, depth, and
% radiance.
[scene,  result] = piRender(thisR, 'render type','radiance'); %#ok<ASGLU>
[coords, result] = piRender(thisR, 'render type','coordinates');

cameraCoord = thisR.lookAt.from;
zmap = coords(:,:,3) - cameraCoord(3);
scene = sceneSet(scene,'depthmap',zmap);
sceneWindow(scene);

%%  The z-map is flat.  The depth map is curved

scenePlot(scene,'depth map');
title('Z Map');

%%

