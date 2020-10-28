%% Render MacBeth color checker
%
% Description:
%   Render a MacBeth color checker.
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
%   10/28/20  dhb  The comments said this rendered a depth map and an
%                  illuminant image, but it doesn't do either.  Removed
%                  those comments. It might be nice to have this do those
%                  two things, but I don't know how.

%% init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the recipe

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
thisR = piLightAdd(thisR,...
    'type','distant',...
    'light spectrum',lightSpectrum,...
    'spectrumscale', spectrumScale,...
    'cameracoordinate', true);

%% Set an output file
%
% This is pretty high resolution given the nature of the target.
thisR.set('integrator subtype','path');
thisR.set('rays per pixel', 16);
thisR.set('filmresolution', [640, 360]);

%% Write 
%
% Write modified recipe out.  We changed the materials, so we overwrite the
% material file.
piWrite(thisR, 'overwritematerials', true);

%% Render and display
[scene, result] = piRender(thisR,'render type','radiance');
sceneWindow(scene);

