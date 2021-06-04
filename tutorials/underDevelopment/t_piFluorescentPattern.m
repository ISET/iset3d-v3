%% Add fluorescent pattern on pbrt model
%
%   t_piFluorescentPattern
% 
% Description:
%   An example of how to generate fluorescent pattern on a selected region.
%   The core function is piFluorescentPattern(), where different pattern
%   generation algorithms will be implemented. Currently we have only one
%   algorithm called "half split". By using that algorithm, we expect to
%   split a certain region and assign fluorescent effect on half of the
%   region.
%   
% TODO:
%   Implement other algorithms so that we can generate more realistic
%   unhealthy patterns. A quick thought would be randomly select a triangle
%   mesh in the child geometry pbrt file, start from there to generate a
%   irregular shaped pattern.
%
%
% Author:
%   ZLY, BW, 2020
%
% See also:
%   piFluorescentPattern, piFluorescentHalfDivision



%% init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the recipe
sceneName = 'slantedBar';
FilePath = fullfile(piRootPath,'data','V3',sceneName);
fname = fullfile(FilePath,[sceneName,'.pbrt']);
if ~exist(fname,'file'), error('File not found'); end

% This scene contains some glass and a mirror
thisR = piRead(fname);

%{
    lightSources = piLightGet(thisR)
%}

% Delete current lights
thisR = piLightDelete(thisR, 'all');

thisR = piLightAdd(thisR,...
    'type','point',...
    'light spectrum','blueLEDFlood',...
    'spectrumscale', 1,...
    'cameracoordinate', true);

%% Set the integrator
thisR.integrator.subtype = 'path';

%% Show the region/material options
piMaterialPrint(thisR);

%% Assign fluorescent materials 
concentrationUniform = 0.05;

% Set the donaldson matrix based on the type of the materials
thisR.set('eem', {'WhiteMaterial', 'FAD'});

% Give a concentration (scaling factor) to the fluophores
thisR.set('concentration', {'WhiteMaterial', concentrationUniform});

%% Write 

% Write modified recipe out
piWrite(thisR, 'overwritematerials', true);

%% Add fluorescent pattern 

unhealthyRegion = 'WhiteMaterial';
baseRegion = 'WhiteMaterial';

algorithm = 'halfsplit';
piFluorescentPattern(thisR, 'location', unhealthyRegion,...
                     'base', baseRegion, 'algorithm', algorithm);

%% Render
thisDocker = 'vistalab/pbrt-v3-spectral:fluorescent';
wave = 365:5:705;
[scene, result] = piRender(thisR, 'dockerimagename', thisDocker,'wave',wave, 'render type', 'illuminant');
scene = sceneSet(scene,'name',sprintf('%s',sceneName));
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