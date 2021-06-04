%% Introducing iset3d calculations with the Chess Set
%
% Brief description:
%  This script renders the sphere scene in the data directory of the ISET3d
%  repository.
% 
% Dependencies:
%    ISET3d, (ISETCam or ISETBio), JSONio
%
%  Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%
% Description
%  The scripts introduces how to read one of the ISET3d default scenes to
%  create recipe.  
%
%  The script 
%
%    * initializes the recipe
%    * sets film resolution parameters
%    * calls the renderer that invokes the PBRT docker
%    * loads the radiance and depth map into an ISET scene structure.
%    * adds a point light
%
% Authors
%  TL, BW, ZL, ZLy SCIEN 2017
%
% See also
%   t_piIntro_*, piRecipeDefault, recipe
%

%% Initialize ISET and Docker

% Start up ISET and check that docker is configured 
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the recipe

thisR = piRecipeDefault('scene name','chessset');

%% Set up the render quality

% There are many rendering parameters.  This is the just an introductory
% script, so we do a minimal number of parameters.  Much of what is
% described in other scripts expands on this section.
thisR.set('film resolution',[256 256]);
thisR.set('rays per pixel',64);
thisR.set('n bounces',3); % Number of bounces

%% Save the recipe and render
piWrite(thisR);

% There is no lens, just a pinhole.  In that case, we are rendering a
% scene. If we had a lens, we would be rendering an optical image.
scene = piRender(thisR);
sceneWindow(scene);

%% By default, we also compute the depth map

scenePlot(scene,'depth map');

%% Add a bright point light near the front where the camera is

pointLight = piLightCreate('point','type','point','cameracoordinate', true);
thisR.set('light','add',pointLight);

piWrite(thisR);
[scene, result] = piRender(thisR);
sceneWindow(scene);

%% END
