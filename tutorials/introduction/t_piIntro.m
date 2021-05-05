%% Introducing iset3d calculations
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
%    * adds a light
%    * sets film resolution parameters
%    * calls the renderer that invokes the PBRT docker
%    * loads the radiance and depth map into an ISET scene structure.
%
% Authors
%  TL, BW, ZL, ZLy SCIEN 2017
%
% See also
%   t_piIntro_*, piRecipeDefault, recipe
%

% History:
%   10/18/20  dhb  Cleaned up comments a bit.

%% Initialize ISET and Docker

% Start up ISET and check that docker is configured 
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the recipe

thisR = piRecipeDefault('scene name','sphere');

% Add a point light, needed by this scene.
pointLight = piLightCreate('point','type','point','cameracoordinate', true);
thisR.set('light','add',pointLight);

%{
% You can also try this light if you like, which is more blue and distant
distantLight = piLightCreate('distant','type','distant',...
    'spd', [9000 0.001], ...
    'cameracoordinate', true);
thisR.set('light','delete',pointLight.name);
thisR.set('light','add',distantLight);
%}

%% Set up the render quality
%
% There are many different parameters that can be set.  This is the just an
% introductory script, so we do a minimal number of parameters.  Much of
% what is described in other scripts expands on this section.
thisR.set('film resolution',[192 192]);
thisR.set('rays per pixel',128);
thisR.set('n bounces',1); % Number of bounces

%% Save the recipe and render
piWrite(thisR);

% There is no lens, just a pinhole.  In that case, we are rendering a
% scene. If we had a lens, we would be rendering an optical image.
[scene, result] = piRender(thisR);
sceneWindow(scene);

%% By default, we also compute the depth map

scenePlot(scene,'depth map');

%% END
