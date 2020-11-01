%% How to move, scale, and rotate a checkerboard
%
% Description:
%   Shows how to change the position of an object, 
%   how to scale an object, and how to rotate an object.

% History:
%   11/01/20  an  Wrote from t_piIntro_start.

%% Initialize ISET and Docker
%
% We start up ISET and check that the user is configured for docker
clear; close all; ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the file
thisR = piRecipeDefault('scene name','checkerboard'); 

%% Add a point light
thisR = piLightAdd(thisR, 'type', 'point', 'camera coordinate', true);

%% Set up the render quality
%
% There are many different parameters that can be set.  This is the just an
% introductory script, so we do a minimal number of parameters.  Much of
% what is described in other scripts expands on this section.
thisR.set('film resolution',[192 192]);
thisR.set('rays per pixel',128);
thisR.set('n bounces',1); % Number of bounces

%% Write and render
piWrite(thisR);
[scene, result] = piRender(thisR);
sceneWindow(scene);

%% Modification of t_piIntro_start.m: demonstrates how to change object position along the x-axis

% Note the current position of the object
priorposition = thisR.assets.groupobjs.position;

% Change the position of the object along the x-axis (leftwards)
thisR.assets.groupobjs.position(1) = priorposition(1) + 1;

% Save the recipe information
piWrite(thisR);

% Render 
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('Moved leftward'));
sceneWindow(scene);

%% Modification of t_piIntro_start.m: demonstrates how to change object position along the z-axis

% Change the position of the object along the z-axis (farther away)
thisR.assets.groupobjs.position(3) = priorposition(3) - 5;

% Save the recipe information
piWrite(thisR);

% Render 
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('Moved farther away'));
sceneWindow(scene);

%% Modification of t_piIntro_start.m: demonstrates how to scale object size along the x-axis

% Note the current scaling of the object
priorscale = thisR.assets.groupobjs.scale;

% Change the scaling of the object along the x-axis (stretches its width)
thisR.assets.groupobjs.scale(1) = priorscale(1) * 2;

% Save the recipe information
piWrite(thisR);

% Render 
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('Stretched width'));
sceneWindow(scene);

%% Modification of t_piIntro_start.m: demonstrates how to rotate an object
% The default rotation matrix is a 4x4 that includes a row of the 3 rotation terms and a 3x3 affine term

% Note the current rotation of the object
priorrotation = thisR.assets.groupobjs.rotate;

% Change the rotation of the object
thisR.assets.groupobjs.rotate(1,2) = priorrotation(1,2) + 30;

% Save the recipe information
piWrite(thisR);

% Render 
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('Rotated'));
sceneWindow(scene);
