%% Set up a simple scene as an example
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
thisR = piRecipeDefault('scene name', 'Simple Scene');

thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

%%
% thisR.assets.show;

%%
assetName = 'figure_3m_material_uber_blue';
%{
thisAsset = thisR.get('asset parent', assetName);

thisR.set('asset', thisAsset.name, 'delete');
thisR.set('to', [0 0 0]);
%}
T1 = thisR.set('asset', assetName, 'translation', [1 0 0]);
pos1 = thisR.get('asset', assetName, 'world position');
thisR.set('to', pos1);

yellowAssetName = 'figure_6m_material_uber';
posYellow = thisR.get('asset', yellowAssetName, 'world position');
thisR.set('from', posYellow + [0 0 -0.2]);
%%
rotM1 = thisR.get('asset', assetName, 'world rotation matrix');
transM1 = thisR.get('asset', assetName, 'world translation');
pos1 = thisR.get('asset', assetName, 'world position');

%%

R1 = thisR.set('asset', assetName, 'rotation', [0 0 45]);
R2 = thisR.set('asset', assetName, 'rotation', [0 45 0]);
%%
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%%

% T1 = thisR.set('asset', assetName, 'translation', [1 0 0]);
T1 = thisR.set('asset', assetName, 'world translation', [0 0.5 0]);

% R2 = thisR.set('asset', assetName, 'rotation', [45 0 0]);
% R2 = thisR.set('asset', assetName, 'rotation', [0 45 0]);

%%
% Rotate z x z - extrinsic rotation - gamma, beta, alpha
rotAng = thisR.get('asset', assetName, 'world rotation angle');

%%
rotM2 = thisR.get('asset', assetName, 'world rotation matrix');
transM2 = thisR.get('asset', assetName, 'world translation');
pos2 = thisR.get('asset', assetName, 'world position');
%%
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%%
R3 = thisR.set('asset', assetName, 'rotation', [20 78 0]);
R4 = thisR.set('asset', assetName, 'rotation', [0 0 48]);
T2 = thisR.set('asset', assetName, 'world translation', [-0.5 0 -0.5]);

%%
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%%
rotM3 = thisR.get('asset', assetName, 'world rotation matrix');
transM3 = thisR.get('asset', assetName, 'world position');


%% Set up a simple scene as an example
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
thisR = piRecipeDefault('scene name', 'simple scene');

thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

%%
% thisR.assets.show;

%%
assetName = 'figure_3m_material_uber_blue';

%%
R1 = thisR.set('asset', assetName, 'rotation', [0 90 45]);

%%
rotAng = thisR.get('asset', assetName, 'world rotation angle');


%%
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%%
thisR.set('asset', R1.name, 'delete');
thisR.set('asset', R2.name, 'delete');

R3 = thisR.set('asset', assetName, 'rotation', rotAng);
%%
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%%
thisR.set('asset', assetName, 'world rotate', [0 0 180]);

piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%%
thisR.set('asset', assetName, 'world rotate', [0 90 0]);

piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%%

% piTransformAxis
%   Get the three transformed axis with a transformation and the original
%   axis
% piTransformRotation
%   Calculate rotation matrix around a certain axis
%
% piTransformTranslation
%   Calculate translation matrix of the object position and new axis

%{
To get the equivalent rotation of an object:
for each node, get the rotation transform, multiply the matrices. Calculate
the angle of the multiplied matrix
%}
