% t_piIntro_texture
%
% Illustrates texture management with some simple objects.
%
% Textures are assigned to a material.  We create some textures and attach
% them to the material in a simple scene.
%
%
% See also
%

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
newTextureName = 'checks';
newTexture = piTextureCreate(newTextureName,...
    'type', 'checkerboard',...
    'format', 'spectrum',...
    'uscale', 24,...
    'vscale', 24, ...
    'spectrum tex1', [.05 .05 .05],...
    'spectrum tex2', [.95 .95 .95]);

thisR.set('texture', 'add', newTexture);
thisR.get('texture print');

%% Display material list

% We change the texture on the material to the checks.  We make assignment
% by placing the texture in the diffuse reflectance (kd) field.
%
% material-name, diffuse reflectance value, texture-name
thisR.set('material', 'Mat', 'kd val', newTextureName);

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

%%  For more complex textures, we can sample images.

% This is an PNG file that is part of the distribution.
newImgName = 'room';
newImgTexture = piTextureCreate(newImgName,...
    'format', 'spectrum',...
    'type', 'imagemap',...
    'filename', 'pngExample.png');
thisR.set('texture', 'replace', 'dots', newImgTexture);
thisR.get('texture print');
thisR.set('material', 'Mat', 'kd val', newImgName);

% Write and render
piWrite(thisR, 'overwritematerials', true);

scene = piRender(thisR, 'render type', 'radiance');
sceneName = 'room';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);
sceneSet(scene,'render flag','hdr');

%{ 
TODO
%% We think we can change the specularity by assigning a monochrome image

thisR.set('light','delete','all');

% Specularity will be more apparent for a point source
thisR.get('light')
pointLight = piLightCreate('Point 1',...
    'type', 'point',...
    'cameracoordinate', false,...
    'spd', 'equalEnergy');
thisR.set('light','add',pointLight);

cameraFrom = thisR.get('from');
lightFrom = cameraFrom + [5 5 -300];
thisR.set('light',pointLight.name,'from',lightFrom);

% thisR.set('light', 'replace', 'Distant 1',pointLight);
thisR.get('light print');

%% Add the face texture image in the specular channel

% We also turn down the diffuse reflectance (kd).
newImgName = 'face';
newImgTexture = piTextureCreate(newImgName,...
    'format', 'spectrum',...
    'type', 'imagemap',...
    'filename', 'monochromeFace.png');
thisR.set('texture', 'add', newImgTexture);
thisR.get('texture print');

% We create a specular material.
newMaterial = 'Uber specular';
uberSpecular = piMaterialCreate(newMaterial, 'type','uber');
uberSpecular = piMaterialSet(uberSpecular,'ks val',newImgName);
uberSpecular = piMaterialSet(uberSpecular,'kd val',[0.5 0.5 0.5]);

% thisR.set('material','replace',newMaterial,uberSpecular);
thisR.set('material','add',uberSpecular);

% We were using the Mat material
thisR.get('assets','Cube_O','material name')

% We change to the specular uber material
thisR.set('assets','Cube_O','material name',newMaterial);
thisR.get('assets','Cube_O','material name')

%% Write and render
piWrite(thisR, 'overwritematerials', true);

[scene, result] = piRender(thisR, 'render type', 'radiance');
sceneName = 'point light';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);
%}

%% END