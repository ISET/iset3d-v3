%% Illustrating how to set the fluorescent properties in recipe

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
thisR.integrator.subtype = 'path';  
thisR.sampler.subtype = 'sobol';

%% Display all the materials in the scene

% These are the materials in this particular scene.
piMaterialList(thisR);

%% Define the fluorescent properties for the second (uber) material

% Use Porphyrins Donaldson matrix as an example.

% Set the wavelength sampling you would like
wave = 395:10:705; 

% Here is one fluorophore, read in with that wavelength sampling.
FAD = fluorophoreRead('Porphyrins','wave',wave);

% Here is the excitation emission matrix
eem = fluorophoreGet(FAD,'eem');
%{
 fluorophorePlot(Porphyrins,'donaldson mesh');
%}
%{
 dWave = fluorophoreGet(FAD,'delta wave');
 wave = fluorophoreGet(FAD,'wave');
 ex = fluorophoreGet(FAD,'excitation');
 ieNewGraphWin; 
 plot(wave,sum(eem)/dWave,'k--',wave,ex/max(ex(:)),'r:')
%}

% The data are converted to a vector like this
wave = fluorophoreGet(FAD,'wave');
flatEEM = eem';
vec = [wave(1) wave(2)-wave(1) wave(end) flatEEM(:)'];

thisR.set('fluorescent', {'Material', vec});

% Give a concentration (scaling factor) to the fluophores
thisR.set('concentration', {'Material', 1});

%% Changing the name!!!!  Important to comment and explain!!! ZL, BW
outFile = fullfile(piRootPath,'local',sceneName,sprintf('%s.pbrt',sceneName));
thisR.set('outputFile',outFile);

piWrite(thisR,'creatematerials',true);

%%
wave = 395:10:705;  % Hard coded in pbrt
nWave = length(wave);
filename = '/Users/zhenglyu/Desktop/Research/git/pbrt_fluorescent/makefile/Release/pbrt.dat';
energy = piReadDAT(filename, 'maxPlanes', nWave);
photon = Energy2Quanta(wave,energy);
scene = piSceneCreate(photon, 'wavelength', wave);
sceneWindow(scene,'display mode','hdr');