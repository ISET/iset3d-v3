% t_piIntro_texture
%
%   Illustrates texture management.  
%
% Textures are created and assigned to a flat surface material in the first
% few examples.  Then we assign the textures to individual assets in the
% SimpleScene.
%
%
% See also
%  t_piIntro_light, tls_assets.mlx

%% Init
ieInit;
if ~piDockerExists, piDockerConfig; end

thisR = piRecipeDefault('scene name', 'flatSurfaceRandomTexture');

%% Add a light and render

thisR.get('light')
newDistLight = piLightCreate('Distant 1',...
    'type', 'distant',...
    'cameracoordinate', true,...
    'spd', 'equalEnergy');
thisR.set('light', 'add', newDistLight);
thisR.get('light print');

% To Do:
%   Write this:  piRenderWriteShow(thisR);
piWrite(thisR, 'overwritematerials', true);
[scene, ~] = piRender(thisR, 'render type', 'radiance');
sceneName = 'Random color';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);

%% This is description of the scene

% We list the textures, lights and materials.
thisR.get('texture print');
thisR.get('lights print');
thisR.get('material print');

% There is on material, called 'Mat'.  That material is assigned thetexture
% which gives the scene its main appearance. The texture is the reflectance
% hcart you see in the window.
thisR.get('material', 'Mat', 'kd val')

%% Change the texture of the checkerboard.

% There are several built-in texture types that PBRT provides.  These
% include
%
%  checkerboard, dots, imagemap
%
% You set the parameters of the checks and dots.  You specify a PNG or an
% EXR file for the image map.
%
% Textures are attached to a material.

% Here are some black and white checks.
checksName = 'checks';
checksTexture = piTextureCreate(checksName,...
    'type', 'checkerboard',...
    'format', 'spectrum',...
    'uscale', 2,...
    'vscale', 2, ...
    'spectrum tex1', [.05 .05 .05],...
    'spectrum tex2', [.95 .95 .95]);

thisR.set('texture', 'add', checksTexture);
thisR.get('texture print');

%% Display material list

% We change the texture on the material to the checks.  We make assignment
% by placing the texture in the diffuse reflectance (kd) field.
%
% material-name, diffuse reflectance value, texture-name
thisR.set('material', 'Mat', 'kd val', checksName);

% The material has been modified so that its 'val' is now the texture name.
% PBRT figures out what to do.
thisR.get('material', 'Mat', 'kd val')

% Write and render the recipe with the new texture
piWrite(thisR, 'overwritematerials', true);
[scene, ~] = piRender(thisR, 'render type', 'radiance');
sceneName = 'Checks';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);

%%  That felt good.  Let's make colored dots.

newDotsName = 'dots';
newDotTexture = piTextureCreate(newDotsName,...
    'format', 'spectrum',...
    'type', 'dots',...
    'uscale', 8,...
    'vscale', 8, ...
    'inside', [.1 .5 .9], ...
    'outside', [.9 .5 .1]);

thisR.set('texture', 'add', newDotTexture);
thisR.set('material', 'Mat', 'kd val', newDotsName);

thisR.get('material', 'Mat', 'kd')
thisR.get('texture print');

piWrite(thisR, 'overwritematerials', true);
[scene, ~] = piRender(thisR, 'render type', 'radiance');
sceneName = 'dots';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);

%% Now we change the texture of a material in a more complex scene

thisR = piRecipeDefault('scene name', 'SimpleScene');
thisR.get('asset names')
planeMaterial = thisR.get('asset','001_Plane_O','material');
thisR.set('texture', 'add', newDotTexture);
thisR.set('material',planeMaterial.name,'kd val',newDotsName);

piWrite(thisR, 'overwritematerials', true);
[scene, ~] = piRender(thisR, 'render type', 'radiance');
sceneName = 'simpleDots';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);
if piCamBio, sceneSet(scene,'render flag','hdr');
else, sceneSet(scene,'gamma',0.7);
end

drawnow;

%%  For more complex textures, we can sample images.

% This is an PNG file that is part of the distribution.
roomName = 'room';
roomTexture = piTextureCreate(roomName,...
    'format', 'spectrum',...
    'type', 'imagemap',...
    'filename', 'pngExample.png');
thisR.get('texture print');

mirrorMaterial = thisR.get('asset','001_mirror_O','material');
thisR.set('texture', 'add', roomTexture);
thisR.set('material', mirrorMaterial.name, 'kd val', roomName);

% Write and render
piWrite(thisR, 'overwritematerials', true);

scene = piRender(thisR, 'render type', 'radiance');
sceneName = 'room';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);
if piCamBio, sceneSet(scene,'render flag','hdr');
else, sceneSet(scene,'gamma',0.7);
end
%% Let's change the texture of a the sphere to checkerboard

figureMaterial = thisR.get('asset','001_Sphere_O','material');
thisR.set('material',figureMaterial.name,'kd val',checksName);

piWrite(thisR, 'overwritematerials', true);
[scene, ~] = piRender(thisR, 'render type', 'radiance');
sceneName = 'simpleFigChecks';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);
if piCamBio, sceneSet(scene,'render flag','hdr');
else, sceneSet(scene,'gamma',0.7);
end
drawnow;

%% END