%% Set up a simple scene as an example
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read in recipe
thisR = piRecipeDefault('scene name', 'simple scene');

thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

% thisR.assets.show;
%% Checking this asset
assetName = 'figure_3m_O';

% First rotation
R1 = thisR.set('asset', assetName, 'rotation', [0 90 45]);
% Check rotation angle
rotAng = thisR.get('asset', assetName, 'world rotation angle');
% Render
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Check if we can use the rotaiton angle to reproduce the rotaiton.
thisR.set('asset', R1.name, 'delete');
thisR.set('asset', assetName, 'rotation', rotAng);
% Render
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Checking world space rotation
thisR.set('asset', assetName, 'world rotate', [0 0 180]);

piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Keep checking
thisR.set('asset', assetName, 'world rotate', [0 90 0]);

piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');