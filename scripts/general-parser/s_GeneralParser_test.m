%% reformat pbrt file to be a standard version 
ieInit;
%%
sceneFolder = fullfile(piRootPath, 'data');
namelist = {fullfile(sceneFolder,'blender/BlenderScene/BlenderScene.pbrt'),...
fullfile(sceneFolder,'/V3/teapot/teapot-area-light.pbrt')...
fullfile(sceneFolder, 'V3/cornell_box/cornell_box.pbrt'),...
fullfile(sceneFolder, 'V3/SimpleScene/SimpleScene.pbrt'),...
'/Users/zhenyi/Downloads/kitchen/scene.pbrt'...
'/Users/zhenyi/Downloads/classroom/scene.pbrt',...
fullfile(sceneFolder,'V3/ChessSet/ChessSet.pbrt')};
%%
for ii = 7%1:numel(namelist)
fname = namelist{ii};
[~,name,~]=fileparts(fname);
thisR = piRead(fname,'toply',true);

thisR.set('film resolution',[300 300]*1.5);
thisR.set('rays per pixel',32);
thisR.set('fov',30);
thisR.set('nbounces',5); 
if ii ==1
   thisR = piLightAdd(thisR,'type','infinite','light spectrum','D65');
end
%%
piWrite(thisR);
%%
disp('*** Rendering...')
[scene,result] = piRender(thisR,'render type','radiance');
sceneWindow(scene);
scene = sceneSet(scene, 'scene name',name);
%%
% depth = piRender(thisR,'render type','depth');
% figure;imagesc(depth);

end

%% move chess set

