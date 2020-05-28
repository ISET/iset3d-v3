%% t_piIntro_macbeth
%
% Render a MacBeth color checker. We render both an illuminant image
% and a depth image.  The illuminant is spatio-spectral.
%
% The depth map is the distance from the camera position to the point
% in the image.  So even though the MCC is flat, the distance from the
% camera to the points on the surface increases as we measure off
% axis.
%
% See t_piIntro_macbeth_zmap to calculate the zmap rather than the
% depth map.
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
%
% See also
%   t_piIntro_cameraposition, piLightSet(examples)

%% init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the recipe

% Reads the MCC by default.  We do not write it out yet because we are
% going to change the parameters
thisR = piRecipeDefault;

%% Change the light

% There is a default point light.  We delete that.
thisR = piLightDelete(thisR, 'all');

% Add an equal energy distant light for uniform lighting
spectrumScale = 1;
lightSpectrum = 'EqualEnergy';
thisR = piLightAdd(thisR,...
    'type','distant',...
    'light spectrum',lightSpectrum,...
    'spectrumscale', spectrumScale,...
    'cameracoordinate', true);

%% Set an output file

% All output needed to render this recipe will be written into this
% directory. 
sceneName = 'macbeth';
outFile = fullfile(piRootPath,'local',sceneName,'macbeth.pbrt');
thisR.set('outputfile',outFile);
thisR.integrator.subtype = 'path';

% This is pretty high resolution given the nature of the target.
thisR.set('pixelsamples', 16);
thisR.set('filmresolution', [640, 360]);

%% Write 

% Write modified recipe out
piWrite(thisR, 'overwritematerials', true);

%% Render the scene and the illuminant

% This case uses the default docker image, that does not incorporate
% fluorescence rendering.  'all' means the illuminant, depth, and
% radiance.
thisDocker = 'vistalab/pbrt-v3-spectral';
wave = 400:10:700;
[scene, result] = piRender(thisR, 'wave', wave, 'dockerimage name', thisDocker, 'render type','illuminant');
sceneWindow(scene);

%%
