%% Render MacBeth checker 
%
% t_mabceth
%
%  
% Index numbers for MacBeth checker:
%          ---- ---- ---- ---- ---- ----
%         | 01 | 02 | 03 | 04 | 05 | 06 |
%          ---- ---- ---- ---- ---- ----
%         | 07 | 08 | 09 | 10 | 11 | 12 | 
%          ---- ---- ---- ---- ---- ----
%         | 13 | 14 | 15 | 16 | 17 | 18 | 
%          ---- ---- ---- ---- ---- ----
%         | 19 | 20 | 21 | 22 | 23 | 24 | 
%          ---- ---- ---- ---- ---- ----
%
% Dependencies:
%
%    ISET3d, (ISETCam or ISETBio), JSONio, isetfluorescent
%
% Author:
%   ZLY, BW, 2020

%% init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the recipe

sceneName = 'MacBethChecker';
FilePath = fullfile(piRootPath,'data','V3',sceneName);
fname = fullfile(FilePath,[sceneName,'.pbrt']);
if ~exist(fname,'file'), error('File not found'); end

thisR = piRead(fname);

%% Change the light condition
thisR = piLightDelete(thisR, 'all');

%{
    lightSources = piLightGet(thisR)
%}
thisR = piLightAdd(thisR,...
    'type','distant',...
    'light spectrum','D65',...
    'spectrumscale', 1,...
    'cameracoordinate', true);

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

%% Render the scene
%{
[scene, result] = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('%s',sceneName));
sceneWindow(scene);
%}

%% Now add some fluorescent effect on the patterns
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

%% Render 
thisDocker = 'vistalab/pbrt-v3-spectral:fluorescent';

wave = 395:10:705;
[scene, result] = piRender(thisR, 'docker image name', thisDocker,'wave',wave);
scene = sceneSet(scene,'name',sprintf('%s',sceneName));

scene = sceneSet(scene,'wavelength', wave);
sceneWindow(scene);
%% After render the scene
%{
%% Used to visualize the result
wave = 385:5:705;
nWave = length(wave);
filename = '/Users/zhenglyu/Desktop/Research/git/pbrt_fluorescent/makefile/Release/pbrt.dat';
energy = piReadDAT(filename, 'maxPlanes', nWave);
photon = Energy2Quanta(wave,energy);
scene = piSceneCreate(photon, 'wavelength', wave);
sceneWindow(scene,'display mode','hdr');
%}