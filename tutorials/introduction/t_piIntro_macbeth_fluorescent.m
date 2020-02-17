%% t_piIntro_macbeth_fluorescent
%
% Render a MacBeth color checker.  Then make an illuminant image to
% return a spatio-spectral illuminant.
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

%% Set an output file

% All output needed to render this recipe will be written into this
% directory. 
sceneName = 'macbeth';
outFile = fullfile(piRootPath,'local',sceneName,'macbeth.pbrt');
thisR.set('outputfile',outFile);
thisR.integrator.subtype = 'path';

thisR.set('pixelsamples', 16);

thisR.set('filmresolution', [640, 360]);

%% Write 
% Write modified recipe out
piWrite(thisR, 'overwritematerials', true);

%% Now add a blue light

% Change the light to 405 nm light source
thisR = piLightDelete(thisR, 'all');
thisR = piLightAdd(thisR,...
    'type','distant',...
    'light spectrum','blueLEDFlood',...
    'spectrumscale', 1,...
    'cameracoordinate', true);

%% Show the region/material options
piMaterialList(thisR);

%% Assign fluorescent materials on some patches

concentrationUniform = 0.5;

% Set the donaldson matrix based on the type of the materials
thisR.set('eem', {'Patch19Material', 'FAD'});
thisR.set('eem', {'Patch11Material', 'Collagen'});
thisR.set('eem', {'Patch06Material', 'Porphyrins'});
thisR.set('eem', {'Patch02Material', 'NADH'});
thisR.set('eem', {'Patch18Material', 'FAD'});


% Give a concentration (scaling factor) to the fluophores
thisR.set('concentration', {'Patch19Material', concentrationUniform});
thisR.set('concentration', {'Patch11Material', concentrationUniform});
thisR.set('concentration', {'Patch06Material', concentrationUniform});
thisR.set('concentration', {'Patch02Material', concentrationUniform});
thisR.set('concentration', {'Patch18Material', concentrationUniform});

%% Write 
% Write modified recipe out
piWrite(thisR, 'overwritematerials', true);

%% Render - At some point we will make this the default (latest)

% If you want to use the fluorescent modeling, specify this docker
% container.  We will promote to the default after we test it more.
thisDocker = 'vistalab/pbrt-v3-spectral:fluorescent';

wave = 385:5:705;
[scene, result] = piRender(thisR, 'docker image name', thisDocker,'wave',wave, 'render type', 'illuminant');
scene = sceneSet(scene,'wavelength', wave);
sceneWindow(scene);

%%