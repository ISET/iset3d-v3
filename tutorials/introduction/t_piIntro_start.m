%% The first in a series of scripts introducing iset3d calculations
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
%  The scripts uses a very simple recipe for a sphere that is included in
%  the iset3d repository.  It sets up the recipe properties by adding a
%  light, setting some resolution parameters, and then calling the render
%  method.  That method invokes the PBRT docker.  The output of PBRT is
%  loaded into an ISET scene structure.
%
% Authors
%  TL, BW, ZL, ZLy SCIEN 2017
%
% See also
%   t_piIntro_*
%

% History:
%   10/18/20  dhb  Cleaned up comments a bit.

%% Initialize ISET and Docker
%
% We start up ISET and check that the user is configured for docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the file
thisR = piRecipeDefault('scene name','sphere');

%% Add a point light
thisR = piLightAdd(thisR, 'type', 'point', 'camera coordinate', true);

% You can also try this light if you like, which is more blue and distant
% 
% Just comment the line above and uncomment this one
% thisR = piLightAdd(thisR, 'type', 'distant', 'light spectrum', [9000 0.001],...
%                         'camera coordinate', true);

%% Set up the render quality
%
% There are many different parameters that can be set.  This is the just an
% introductory script, so we do a minimal number of parameters.  Much of
% what is described in other scripts expands on this section.
thisR.set('film resolution',[192 192]);
thisR.set('rays per pixel',128);
thisR.set('n bounces',1); % Number of bounces

%% Save the recipe information
piWrite(thisR);

%% Render 
%
% There is no lens, just a pinhole.  In that case, we are rendering a
% scene. If we had a lens, we would be rendering an optical image.
[scene, result] = piRender(thisR);
sceneWindow(scene);

%% Note that we also computed the depth map
%
% Show it by uncommenting the line below.
% scenePlot(scene,'depth map');

