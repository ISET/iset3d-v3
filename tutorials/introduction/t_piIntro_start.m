%% This is the first in a series of scripts introducing iset3d calulcations
%
% Brief description:
%
%  This introduction renders the teapot scene in the data directory of the
%  ISET3d repository. This introduction sets up a very simple recipe, runs
%  the docker command, and loads the result into an ISET scene structure.
% 
% Dependencies:
%
%    ISET3d, (ISETCam or ISETBio), JSONio
%
%  Check that you have the updated docker image by running
%
%   docker pull vistalab/pbrt-v3-spectral
%
% TL, BW, ZL SCIEN 2017
%
% See also
%

%% Initialize ISET and Docker

% We start up ISET and check that the user is configured for docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the file

% The teapot is our test file
% inFile = fullfile(piRootPath,'data','V3','teapot','teapot-area-light.pbrt');
% inFile = '/Users/zhenyi/Desktop/3dhuman/human.pbrt';
inFile = '/Users/zhenyi/Desktop/eSFR_face/eSFRandFace.pbrt';
recipe = piRead(inFile);

% The output will be written here
sceneName = 'teapot';
outFile = fullfile(piRootPath,'local',sceneName,'scene.pbrt');
recipe.set('outputFile',outFile);

%% Set up the render quality

% There are many different parameters that can be set.
recipe.set('film resolution',[300 300]);
recipe.set('pixel samples',16);
recipe.set('max depth',10); % Number of bounces
recipe.set('fov',22);
% recipe.lookAt.from = [0 0 -0.5];
% recipe.lookAt.to = [0 0 0];
% recipe.lookAt.up = [0 1 0];
%% Render
piWrite(recipe);

%%  This is a pinhole case.  So we are rendering a scene.

[scene, result] = piRender(recipe,'rendertype','radiance');

sceneWindow(scene);
scene = sceneSet(scene,'gamma',0.7);

%% Notice that we also computed the depth map
% scenePlot(scene,'depth map');

%% END