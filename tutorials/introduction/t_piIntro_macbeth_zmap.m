%% Render a MacBeth color checker and show how to get a zmap image.
%
% Description:
%   The zmap differs from the depth map.  It is the z-coordinate, not
%   the distance from the camera to the point.
%
%   See t_piIntro_macbeth to calculate the depth map rather than the
%   zmap, and how to compute an illumination map.
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

% History:
%   10/28/20  dhb  Comments said this rendered an illuminant image, but it
%                  doesn't.  Removed those comments, and point to
%                  p_piIntro_macbeth for illumination map.

%% init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the recipe
thisR = piRecipeDefault('write',false);

%% Change the light

% There is a default point light.  We delete that.
%{
    thisR.get('light print');
%}
thisR.set('light', 'delete', 'all');

% Add an equal energy distant light
lName = 'new dist light';
lightSpectrum = 'equalEnergy';

newDistLight = piLightCreate(lName,...
                            'type', 'distant',...
                            'spd', lightSpectrum,...
                            'cameracoordinate', true);
thisR.set('light', 'add', newDistLight);                        
%% Set rendering parameters 

thisR.set('integrator subtype','path');
thisR.set('pixelsamples', 16);
thisR.set('filmresolution', [640, 360]);

%% Write and render
piWrite(thisR, 'overwritematerials', true);

% This case uses the default docker image, that does not incorporate
% fluorescence rendering.  'all' means the illuminant, depth, and
% radiance. Here we just render the radiance image.
[scene,  result] = piRender(thisR, 'render type','radiance'); %#ok<ASGLU>
sceneWindow(scene);

% Compute the zmap.
%
% Start by doing a rendering that returns the XYZ 3D coordinates of the visible
% surfaces.
[coords, result] = piRender(thisR, 'render type','coordinates');

% Get where camera is looking from
cameraCoord = thisR.lookAt.from;

% Compute the zmap
zmap = coords(:,:,3) - cameraCoord(3);

%% Call this the 'depth map' and plot.
%
%  The z-map is flat.  The depth map is curved
scene = sceneSet(scene,'depthmap',zmap);
scenePlot(scene,'depth map');
title('Z Map');


