%%
ieInit;
%{
fname = fullfile(piRootPath,'local',...
    'traffic_scene_origin','traffic_scene.pbrt');

formattedFname = piPBRTReformat(fname);

thisR = piRead(formattedFname);

thisR.get('film resolution')
thisR.summarize

%% Change camera to pinhole
cam = piCameraCreate('pinhole');
thisR.set('camera', cam);

%% 
thisR.set('film resolution',[300 200]*1.5);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',1);

piWrite(thisR);

%%
disp('*** Rendering...')
[scene,result] = piRender(thisR,'render type','radiance');
sceneWindow(scene);
%}
%%

% ieWebGet2('browse')
sceneName = ieWebGet2('op','fetch','resourcename','glasses');

thisR = piRead(fullfile(sceneName,'glasses.pbrt'));
thisR.set('film resolution',[300 200]*1.5);
thisR.set('rays per pixel',128);
thisR.set('fov',45);
thisR.set('nbounces',3);

piWrite(thisR);
scene = piRender(thisR,'render type','radiance');
sceneWindow(scene);

%% Make the glass glass

piMaterialList(thisR)
matName = '10 - Default';
glass = piMaterialCreate(matName, 'type', 'glass');
thisR.set('material', matName, glass);

piWrite(thisR);
scene = piRender(thisR,'render type','radiance');
sceneWindow(scene);

thisR.assets.show;

% We might try deleting some of these branches (subtrees)
% 
% thisR.set('assets','Group001_B','delete');

%% Save the asset
assetName = '074_B';
thisR.set('asset', assetName, 'scale', 2);
piWrite(thisR);
scene = piRender(thisR,'render type','radiance');
sceneWindow(scene);

%%
subTree = thisR.get('asset', assetName, 'subtree');
matList = thisR.get('materials');
txtList = thisR.textures.list;
% thisR.assets.showUI

outputPath = fullfile(piRootPath, 'data', 'assets', 'glasses.mat');
piAssetTreeSave(subTree, matList, 'outFilePath', outputPath);

%% Put the glasses in the simple scene
thisRSS = piRecipeDefault('scene name', 'simple scene');
thisRSS.set('film resolution',[300 200]);
thisRSS.set('rays per pixel',32);
thisRSS.set('fov',45);
thisRSS.set('nbounces',6);

assetTreeName = 'glasses';
[~, rootST1] = thisRSS.set('asset', 'root', 'graft with materials', assetTreeName);

%%
assetName = 'mirror_O';
materialName = thisRSS.get('asset',assetName,'material name');
% Create a real mirror
newMat = piMaterialCreate(materialName, 'type', 'mirror');

% Replace the material with a real mirror
thisRSS.set('material', materialName, newMat);

%%
% Put the glasses at the same position of blue guy
thisRSS.set('asset', rootST1.name, 'world rotation', [0 -90 0]);
thisRSS.set('asset', rootST1.name, 'world translation', [0.25 0.5 -13]);

% thisRCB.assets.showUI;

piWrite(thisRSS);
%%
disp('*** Rendering...')
[scene,result] = piRender(thisRSS,'render type','radiance');
sceneWindow(scene);