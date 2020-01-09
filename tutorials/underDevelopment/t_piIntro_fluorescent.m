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

%% Set render quality

% This is a low resolution for speed.
thisR.set('film resolution',[400 300]);
thisR.set('pixel samples',64);

%% Write out the pbrt scene file, based on thisR.

thisR.set('fov',45);
thisR.film.diagonal.value = 10;
thisR.film.diagonal.type  = 'float';
thisR.integrator.subtype = 'path';% The fluorescent effect only implemented in path integrator for now.
thisR.sampler.subtype = 'sobol';

%% Display all the materials in the scene

% These are the materials in this particular scene.
piMaterialList(thisR);

%% Define the fluorescent properties for the second (uber) material

% Set the donaldson matrix based on the type of the materials
thisR.set('eem', {'Material', 'Porphyrins'});

% Give a concentration (scaling factor) to the fluophores
thisR.set('concentration', {'Material', 1});

%% Changing the name
outFile = fullfile(piRootPath,'local',sceneName,sprintf('%s.pbrt',sceneName));
thisR.set('outputFile',outFile);

piWrite(thisR,'creatematerials',true);


%% NOTE: piRender is not ready to use yet as we used a edited version of pbrt for fluorescent effect


%% This is used to visualize the rendered result
wave = 395:10:705;  % Hard coded in pbrt
nWave = length(wave);
filename = '/Users/zhenglyu/Desktop/Research/git/pbrt_fluorescent/makefile/Release/floorFluorescentPorphyrins.dat';
energy = piReadDAT(filename, 'maxPlanes', nWave);
photon = Energy2Quanta(wave,energy);
scene = piSceneCreate(photon, 'wavelength', wave);
sceneWindow(scene,'display mode','hdr');