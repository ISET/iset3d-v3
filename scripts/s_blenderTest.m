%%

%%
fname = fullfile(piRootPath,'data','blender','BlenderScene','BlenderScene.pbrt');
newName = piBlender2C4D(fname);
thisR   = piRead(newName);

%% Add light
%
% This scene was exported without a light, so create and add an infinite light.
infiniteLight = piLightCreate('infiniteLight','type','infinite','spd','D65');
thisR.set('light','add',infiniteLight);

%% Change render quality
%
% Decrease the resolution and rays/pixel to decrease rendering time.
raysperpixel = thisR.get('rays per pixel');
filmresolution = thisR.get('film resolution');
thisR.set('rays per pixel', raysperpixel/2);
thisR.set('film resolution',filmresolution/2);

thisR.set('fov',60);

piWrite(thisR);
[scene,result] = piRender(thisR,'render type','radiance');
sceneWindow(scene);

%% END