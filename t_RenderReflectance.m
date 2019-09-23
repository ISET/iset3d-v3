%% render scenes for differet types

ieInit;
if ~piDockerExists, piDockerConfig; end
if ~mcGcloudExists, mcGcloudConfig; end
%%
sceneName = 'colorfulScene';
InputFile = fullfile(piRootPath, 'local', 'scenes', sceneName, [sceneName, '.pbrt']);
thisR = piRead(InputFile);

thisR.set('film resolution',[1200 900]/2);
thisR.set('pixel samples',32);
thisR.set('max depth',5); 
%% Render radiance and depth
piWrite(thisR);
ieObject = piRender(thisR,'render type','both');% both radiance and depth
sceneWindow(ieObject);
%% Assign all the material to be matte
materialNameList = fieldnames(thisR.materials.list);
for ii = 1:length(materialNameList)
target = thisR.materials.lib.matte; 
piMaterialAssign(thisR, materialNameList{ii}, target);
end
piWrite(thisR);
ieObject = piRender(thisR,'render type','radiance');
sceneWindow(ieObject);
%% render reflectance map return an NxNx31 data.
reflectanceMap = piRender(thisR, 'render type', 'reflectance');
figure;imagesc(reflectanceMap(:,:,1));