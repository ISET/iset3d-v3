%% Set up a simple scene as an example
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
thisR = piRecipeDefault('scene name', 'Simple Scene');

thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 
% thisR.assets.show;

%%
assetName = 'figure_3m_O';
%{
thisAsset = thisR.get('asset parent', assetName);

thisR.set('asset', thisAsset.name, 'delete');
thisR.set('to', [0 0 0]);
%}
T1 = thisR.set('asset', assetName, 'translation', [1 0 0]);
pos1 = thisR.get('asset', assetName, 'world position');
thisR.set('to', pos1);

yellowAssetName = 'figure_6m_O';
posYellow = thisR.get('asset', yellowAssetName, 'world position');
thisR.set('from', posYellow + [0 0 -0.2]);

%%
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

