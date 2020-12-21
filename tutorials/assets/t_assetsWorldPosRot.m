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
%{
R1 = thisR.set('asset', assetName, 'rotation', [0 0 45]);

T1 = thisR.set('asset', assetName, 'translation', [1 0 0]);

R2 = thisR.set('asset', assetName, 'rotation', [45 0 0]);

T2 = thisR.set('asset', assetName, 'translation', [0 -1 0]);
%}

%%
% T1 = thisR.set('asset', assetName, 'translation', [1 0 0]);
R1 = thisR.set('asset', assetName, 'rotation', [45 45 0]);
% R2 = thisR.set('asset', assetName, 'rotation', [0 90 0]);


% R2 = thisR.set('asset', assetName, 'rotation', [0 45 0]);

%%
res = thisR.get('asset', assetName, 'world rotation');
%%
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

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
