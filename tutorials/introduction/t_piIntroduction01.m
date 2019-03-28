%% This is the first in a series of scripts introducing iset3d calulcations
%
% Brief description:
%
%  This introduction renders a local file in the data directory of the
%  ISET3d repository. This introduction sets up a very simple recipe, runs
%  the docker command, and loads the result into an ISET scene structure.
% 
% Dependencies:
%
%    ISET3d, ISETCam or ISETBio, JSONio
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
inFile = fullfile(piRootPath,'data','V3','teapot','teapot-area-light.pbrt');
recipe = piRead(inFile);

% The output will be written here
sceneName = 'teapot';
outFile = fullfile(piRootPath,'local',sceneName,'scene.pbrt');
recipe.set('outputFile',outFile);

%% Set up the render quality

% There are many different parameters that can be set.
recipe.set('film resolution',[192 192]);
recipe.set('pixel samples',128);
recipe.set('max depth',1); % Number of bounces

%% Render
piWrite(recipe);

%%  This is a pinhole case.  So we are rendering a scene.

[scene, result] = piRender(recipe);

ieAddObject(scene); sceneWindow;
scene = sceneSet(scene,'gamma',0.5);

% Notice that we also computed the depth map
scenePlot(scene,'depth map');

%% END