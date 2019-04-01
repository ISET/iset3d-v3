%% This is the second in a series of scripts introducing iset3d calulcations
%
% Brief description:
%
%  Download and print out simple properties of the RDT scenes
%
%  You must have the Remote Data Toolbox on your path to run this.
%
% 
% Dependencies
%
%    ISET3d, ISETCam or ISETBio, JSONio, RemoteDataToolbox
%
%  Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%
% See also
%

% Notes
%
%   Directory, sceneFileName
%   ------------------------
%    coloredCube, coloredCube
%    slantedBar,  slantedBar
%    slantedBarTexture,  slantedBarTexture
%    cylinderTexture,  c ylinderTexture
%    teapot,             teapot-area-light
%    checkerboard,       checkerboard

%% Initialize ISET and Docker

% We start up ISET and check that the user is configured for docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the white-room file for the Remote Data site

% This is the INPUT file name
sceneName = 'checkerboard'; sceneFileName = 'checkerboard.pbrt';

% The output will be written here
inFolder = fullfile(piRootPath,'data','V3');
inFile = fullfile(inFolder,sceneName,sceneFileName);

%%
recipe = piRead(inFile);

% This is out the putput scene name
outFolder = fullfile(tempdir,sceneName);
outFile = fullfile(outFolder,[sceneName,'.pbrt']);
recipe.set('outputFile',outFile);

%% Change render quality
recipe.set('film resolution',[192 192]);
recipe.set('pixel samples',96);
recipe.set('max depth',1); % Number of bounces

%% Render
piWrite(recipe);

%%  Create the scene
[scene, result] = piRender(recipe);

%%  Show it and the depth map

sceneWindow(scene);
% sceneSet(scene,'gamma',0.5);

%%
scenePlot(scene,'depth map');

%% Add a realistic camera
%
% Another time another script.  Show rendering with a lens.
%
%{
recipe.set('camera','realistic');
recipe.set('lensfile',fullfile(piRootPath,'data','lens','dgauss.22deg.50.0mm.dat'));
recipe.set('filmdiagonal',35); 
%}

%%