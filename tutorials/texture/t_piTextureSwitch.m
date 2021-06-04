% t_piTextureSwitch
%
% Should this be t_piTextureSwitch
%
% Change an object texture and render
%
%
% See also
%  

%% init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the recipe
thisR = piRecipeDefault('scene name', 'flatSurfaceRandomTexture');

thisR.get('texture print');
%% Check and remove all lights
thisR.set('light', 'delete', 'all');
thisR.get('light')

newDistLight = piLightCreate('new dist light',...
                            'type', 'distant',...
                            'cameracoordinate', true,...
                            'spd', 'equalEnergy');
thisR.set('light', 'add', newDistLight);                        

thisR.get('light print');
%% Write the recipe
piWrite(thisR, 'overwritematerials', true);

%% Render the scene
[scene, ~] = piRender(thisR, 'render type', 'radiance');
sceneName = 'Random color';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);                
                
%% Add a new texture of the checkerboardd. 

%{
% This will be the second texture in thisR.textures.list
piTextureCreate(thisR, 'name', 'checks',...
                       'format', 'spectrum',...
                       'type', 'checkerboard',...
                       'float uscale', 8,...
                       'float vscale', 8,...
                       'spectrum tex1', [.01 .01 .01],...
                       'spectrum tex2', [.99 .99 .99]);
%}

% This will be the second texture in thisR.textures.list
newTextureName = 'checks';
newTexture = piTextureCreate(newTextureName,...
                       'format', 'spectrum',...
                       'type', 'checkerboard',...
                       'float uscale', 24,...
                       'float vscale', 24);
                   
thisR.set('texture', 'add', newTexture);   

thisR.get('texture print');
%% Display material list

thisR.get('material print');
%{
% These scitran functions may be useful some day
 tList = stPrint(thisR.textures.list,'name');
 stSelect(thisR.textures.list,'name','checks')
%}

%% Assign the new texture to a the one material

% The name of the material is Mat.  We are going to use the texture to
% describe the diffuse reflectance of the material.
thisR.set('material', 'Mat', 'kd val', newTextureName);
thisR.get('material', 'Mat', 'kd')
%{
idx = piTextureFind(thisR,'name','checks');
piTextureAssignToMaterial(thisR, 'Mat', 'texturekd', idx);
%}

%% Write the recipe
piWrite(thisR, 'overwritematerials', true);

%% Render the scene radiance

[scene, ~] = piRender(thisR, 'render type', 'radiance');
sceneName = 'Checks';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);

%{
%%
% The name of the material is Mat.  We are going to use the texture to
% describe the diffuse reflectance of the material.
piTextureAssignToMaterial(thisR, 'Mat', 'texturekd', 'reflectanceChart_color');
piWrite(thisR, 'overwritematerials', true);
[scene, ~] = piRender(thisR, 'render type', 'radiance');
sceneName = 'Color repeat';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);
%}

%%
newDotsName = 'dots';
newDotTexture = piTextureCreate(newDotsName,...
                       'format', 'spectrum',...
                       'type', 'dots',...
                       'float uscale', 8,...
                       'float vscale', 8);
thisR.set('texture', 'add', newDotTexture);   
thisR.set('material', 'Mat', 'kd val', newDotsName);

thisR.get('material', 'Mat', 'kd')                   
thisR.get('texture print');

%% Write the recipe
piWrite(thisR, 'overwritematerials', true);

%% Render the scene radiance

[scene, ~] = piRender(thisR, 'render type', 'radiance');
sceneName = 'dots';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);

%%
newImgName = 'room';
newImgTexture = piTextureCreate(newImgName,...
                       'format', 'spectrum',...
                       'type', 'imagemap',...
                       'filename', 'room.exr');
thisR.set('texture', 'replace', 'dots', newImgTexture);
thisR.get('texture print');
thisR.set('material', 'Mat', 'kd val', newImgName);
%% Write the recipe
piWrite(thisR, 'overwritematerials', true);

%% Render the scene radiance

[scene, result] = piRender(thisR, 'render type', 'radiance');
sceneName = 'room';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);

%% END