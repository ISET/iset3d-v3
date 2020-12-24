%% Set up a simple scene as an example
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
thisR = piRecipeDefault('scene name', 'simple scene');

thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

% thisR.assets.show;

%% Check rotation matrix and position
rotM1 = thisR.get('asset', assetName, 'world rotation matrix');
transM1 = thisR.get('asset', assetName, 'world translation');
pos1 = thisR.get('asset', assetName, 'world position');

%% Add two rotations
R1 = thisR.set('asset', assetName, 'rotation', [0 0 45]);
R2 = thisR.set('asset', assetName, 'rotation', [0 45 0]);
% Render 
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Translate along y axis in world space
T1 = thisR.set('asset', assetName, 'world translation', [0 0.5 0]);
% Check rotation matrix and position
rotM2 = thisR.get('asset', assetName, 'world rotation matrix');
transM2 = thisR.get('asset', assetName, 'world translation');
pos2 = thisR.get('asset', assetName, 'world position');
% Render
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% More Random testing
R3 = thisR.set('asset', assetName, 'rotation', [20 78 0]);
R4 = thisR.set('asset', assetName, 'rotation', [0 0 48]);
T2 = thisR.set('asset', assetName, 'world translation', [-0.5 0 -0.5]);
% Render
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Check rotation matrix and position
rotM3 = thisR.get('asset', assetName, 'world rotation matrix');
transM3 = thisR.get('asset', assetName, 'world translation');
pos3 = thisR.get('asset', assetName, 'world position');