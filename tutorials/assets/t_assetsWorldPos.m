%% How to get positions and rotations in World coordinates
%
% Many of the rotations and translations in graphics are specified with
% respect to the asset coordinate frame, or relative to the current
% position and rotation of the asset.
%
% Using 'world' methods, we can determine the position and rotation of
% objects in the world coordinates.  Using 'world' means that we march our
% way back up the asset tree, collecting the rotations and translations
% along the way, to specify where the asset is in the 'world', which is to
% say the whole frame.
%
%
% Author:  ZLy, BW
%
% See also
%   t_assetsWorld*
%

%% Set up a simple scene as an example
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Simple scene, low resolution rendering

thisR = piRecipeDefault('scene name', 'simple scene');
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

% thisR.assets.show;

%% Render 
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Get information

% The blue stick figure
assetName = 'figure_3m_O';

rotM1   = thisR.get('asset', assetName, 'world rotation matrix');

transM1 = thisR.get('asset', assetName, 'world translation');

pos1    = thisR.get('asset', assetName, 'world position');

%% Add two rotations and render

[~,R1] = thisR.set('asset', assetName, 'rotation', [0 0 45]);
[~,R2] = thisR.set('asset', assetName, 'rotation', [0 45 0]);

% Render 
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Translate along y axis in world space

% This moves the object up in the screen
[~,T1] = thisR.set('asset', assetName, 'world translation', [0 0.5 0]);

% Check rotation matrix and position
rotM2   = thisR.get('asset', assetName, 'world rotation matrix');
transM2 = thisR.get('asset', assetName, 'world translation');
pos2    = thisR.get('asset', assetName, 'world position');

% Render
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Compare with standard translation

% Delete the world translation
thisR.set('asset',T1.name,'delete');

% Insert the standard translation
thisR.set('asset', assetName, 'translation', [0 0.5 0]);

% Render and note that the y-direction is w.r.t. the stick figure
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% More examples

% These are object-coordinate transforms
[~,R3] = thisR.set('asset', assetName, 'rotation', [20 78 0]);

[~,R4] = thisR.set('asset', assetName, 'rotation', [0 0 48]);

% World transform
[~,T2] = thisR.set('asset', assetName, 'world translation', [-0.5 0 -0.5]);

% Render
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Return rotation matrix and position

rotM3   = thisR.get('asset', assetName, 'world rotation matrix');
transM3 = thisR.get('asset', assetName, 'world translation');
pos3    = thisR.get('asset', assetName, 'world position');

% To the left (-x) and up (+y)
disp(pos3)

%% Put the red sphere at the world origin

spherePos = thisR.get('asset','Sphere_O','world position');

% place it at the origin

thisR.set('asset','Sphere_O','translate',-spherePos);

% Render
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%%
