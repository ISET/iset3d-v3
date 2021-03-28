%%
ieWebGet('browse')

%%
%
% fname = 'plantsDusk';  % Version 2 scene
fname = 'yeahright';
% fname = 'teapot';

thisR = piRecipeDefault('scene name',fname);

%%
piWrite(thisR);
[scene, result] = piRender(thisR,'render type','radiance');
sceneWindow(scene);

%%
%{
thisR.get('fov')

thisR.set('fov',60);

piWrite(thisR);
[scene, result] = piRender(thisR,'render type','radiance');
sceneWindow(scene);
%}

%%  Add a light inside the world

% piLightProperties('infinite')

newLight = piLightCreate('outside','type','infinite','mapname','room.exr');
% newLight = piLightCreate('inside','type','spot','cameracoordinate',true,'spd',[1 0 0]);

thisR.set('light','add',newLight);
txt = piLightWrite(thisR);

nLines = numel(txt{1}.line);
thisR.world(end) = []; % 'WorldEnd';
for ii=1:nLines
    thisR.world{end+1} = txt{1}.line{ii};
end
thisR.world{end+1} = 'WorldEnd';

%%
piWrite(thisR);
[scene, result] = piRender(thisR,'render type','radiance');
sceneWindow(scene);


%%

%%