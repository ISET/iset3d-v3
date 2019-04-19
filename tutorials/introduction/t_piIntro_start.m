%% t_piIntroduction01
% This is the first in a series of scripts introducing iset3d calulcations
%
% Description:
%    This introduction renders the teapot scene in the ISET3d respository's
%    data directory. This introduction sets up a very simple recipe, runs
%    the docker command, and loads the result into an ISET scene structure.
%
% Dependencies:
%   ISET3d, ISETCam or ISETBio, JSONio
%
% Notes:
%    Check that you have the updated docker image by running
%    docker pull vistalab/pbrt-v3-spectral
%
% See Also:
%   t_piIntroduction02, t_piIntroduction03, and t_piIntroduction_test
%
% History:
%    XX/XX/17  TL, BW, ZL  SCIEN 2017
%    03/13/19  JNM         Documentation pass
%    04/18/19  JNM         Merge Master in (resolve conflicts)

%% Initialize ISET and Docker
% We start up ISET and check that the user is configured for docker
ieInit;
if ~piDockerExists, piDockerConfig; end

% Determine whether you are working in ISETBio or ISETCam
fprintf('Attempting to execute using %s.\n', piCamBio);

%% Read the file
% The teapot is our test file
inFile = fullfile(piRootPath, 'data', 'V3', 'teapot', ...
    'teapot-area-light.pbrt');
recipe = piRead(inFile);

% The output will be written here
sceneName = 'teapot';
outFile = fullfile(piRootPath, 'local', sceneName, 'scene.pbrt');
recipe.set('outputFile', outFile);

%% Set up the render quality
% There are many different parameters that can be set.
recipe.set('film resolution', [192 192]);
recipe.set('pixel samples', 128);
recipe.set('max depth', 1); % Number of bounces

%% Render
piWrite(recipe);

%%  This is a pinhole case. So we are rendering a scene.
% To reuse an existing rendered file of the correct size, uncomment the
% parameter key/value pair provided below.
[scene, result] = piRender(recipe); %, 'reuse', true);

sceneWindow(scene);
scene = sceneSet(scene, 'gamma', 0.7);

%% Notice that we also computed the depth map
scenePlot(scene,'depth map');

%% END