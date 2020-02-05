%% Illustrating how to set the fluorescent properties in recipe
% 
% This is an example of how to define fluorescent material. We define the
% material in two parts: the reflective and the fluorescent part. For the
% fluorescent part, we define the properties with data called Donaldson
% matrix, which will be generated and used in pbrt scirpts.
%
% Dependencies:
%
%    ISET3d, (ISETCam or ISETBio), JSONio, isetfluorescent
%
%
% ZLY, BW, 2020
%
% See also
%   t_piIntro_*


%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read pbrt files
sceneName = 'SimpleScene';
FilePath = fullfile(piRootPath,'data','V3',sceneName);
fname = fullfile(FilePath,[sceneName,'.pbrt']);
if ~exist(fname,'file'), error('File not found'); end

% This scene contains some glass and a mirror
thisR = piRead(fname);

%% Change the lights
% Delete current lights
thisR = piLightDelete(thisR, 'all');

thisR = piLightAdd(thisR,...
    'type','point',...
    'light spectrum','blueLEDFlood',...
    'spectrumscale', 10,...
    'cameracoordinate', true);

%% Set render quality

% This is a low resolution for speed.
thisR.set('film resolution',[400 300]);
thisR.set('pixel samples',64);

%% Write out the pbrt scene file, based on thisR.

thisR.set('fov',45);
thisR.film.diagonal.value = 10;
thisR.film.diagonal.type  = 'float';
thisR.integrator.subtype = 'path';% The fluorescent effect only implemented in path integrator for now.

%% Display all the materials in the scene

% These are the materials in this particular scene.
piMaterialList(thisR);

%% Define the fluorescent properties for the second (uber) material

% Set the donaldson matrix based on the type of the materials
thisR.set('eem', {'uber', 'FAD'});
thisR.set('eem', {'uber_blue', 'Porphyrins'});

% Give a concentration (scaling factor) to the fluophores
thisR.set('concentration', {'uber', 0.05});
thisR.set('concentration', {'uber_blue', 0.01});

%% Changing the name
outFile = fullfile(piRootPath,'local',sceneName,sprintf('%s.pbrt',sceneName));
thisR.set('outputFile',outFile);

piWrite(thisR,'creatematerials',true);


%% Render(not applicable now since we don't have fluorescence version pbrt in Docker)
%{
[scene, result] = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('%s',sceneName));
sceneWindow(scene);
%}

%% This is used to visualize the rendered result
%{
wave = 395:10:705;  % Hard coded in pbrt
nWave = length(wave);
filename = '/Users/zhenglyu/Desktop/Research/git/pbrt_fluorescent/makefile/Release/pbrt.dat';
energy = piReadDAT(filename, 'maxPlanes', nWave);
photon = Energy2Quanta(wave,energy);
scene = piSceneCreate(photon, 'wavelength', wave);
sceneWindow(scene,'display mode','hdr');
%}