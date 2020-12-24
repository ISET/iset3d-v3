%% Set up a simple scene as an example
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Base simple scene 
thisR = piRecipeDefault('scene name', 'simple scene');
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

%% Coordinate scene
assetSceneName = 'coordinate';
coorRecipe = piRecipeDefault('scene name', assetSceneName);
coorRecipe.assets.show;
%% Get the asset tree of coordinate
rootST = 'Coordinate_B';
coorST = coorRecipe.get('asset', rootST, 'subtree');

%% Graft the subtree under root
thisR.assets.show;
assetName = 'root';
rootST1 = thisR.set('asset', assetName, 'graft', coorST);

assetName = 'figure_3m_B';
rootST2 = thisR.set('asset', assetName, 'graft', coorST);
thisR.assets.show;

%% Check the world position
names = thisR.assets.names;
posCoor = thisR.get('asset', '039ID_origin_O', 'world position');
posCoor2 = thisR.get('asset', '052ID_origin_O', 'world position');

%% Translate coordinate next to blue guy
T1 = thisR.set('asset', '040ID_Coordinate_B', 'translate', [-0.1 0 0]);

%%
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Another way
% First chop the two coordinate tree
thisR.set('asset', rootST1.name, 'chop');
thisR.set('asset', rootST2.name, 'chop');

thisR.assets.show;

% Graft with materials
assetTreeName = 'coordinate';
rootST3 = thisR.set('asset', assetName, 'graft with materials', assetTreeName);
thisR.set('asset', rootST3.name, 'scale', 3);
T2 = thisR.set('asset', rootST3.name, 'translate', [-0.5 0 0]);
%%
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');