%% Teapot example for iset3d calculations
%
% Brief description:
%  Renders the teapot scene in the data directory of the ISET3d repository.
%
%  This introduction sets up a very simple recipe, runs the docker command,
%  and loads the result into an ISET scene structure.
% 
% Dependencies:
%    ISET3d, (ISETCam or ISETBio), JSONio
%
%  Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%
% TL, BW, ZL SCIEN 2017
%
% See also
%   t_piIntro_*

%% Initialize ISET and Docker
%
% We start up ISET and check that the user is configured for docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the scene recipe file

% This is the teapot scene
thisR = piRecipeDefault('scene name','teapot');

% Set up the render quality
thisR.set('film resolution',[192 192]);
thisR.set('pixel samples',128);
thisR.set('max depth',1); % Number of bounces
thisR = piCameraTranslate(thisR, 'x shift', -1);  % meters

%% Write out recipe and render. Then show.
piWrite(thisR);

% This is a pinhole case. So we are rendering a scene.
[scene, result] = piRender(thisR);
sceneWindow(scene);
% scene = sceneSet(scene,'gamma',0.7);

%% Notice that we also computed the depth map.
% This is the default for piRender.
% scenePlot(scene,'depth map');

%% END