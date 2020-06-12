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

%% Check and remove all lights
piLightGet(thisR); % Should be nothing

% Add a new equalEnergy light
thisR = piLightAdd(thisR, 'type', 'distant', 'camera coordinate', true,...
                    'light spectrum', 'equalEnergy');

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
piTextureCreate(thisR, 'name', 'checks',...
                       'format', 'spectrum',...
                       'type', 'checkerboard',...
                       'float uscale', 24,...
                       'float vscale', 24);
                   
                   
%% Display material list

piMaterialList(thisR);
%{
% These scitran functions may be useful some day
 tList = stPrint(thisR.textures.list,'name');
 stSelect(thisR.textures.list,'name','checks')
%}

%% Assign the new texture to a the one material

% The name of the material is Mat.  We are going to use the texture to
% describe the diffuse reflectance of the material.
idx = piTextureFind(thisR,'name','checks');
piTextureAssignToMaterial(thisR, 'Mat', 'texturekd', idx);

%% Write the recipe
piWrite(thisR, 'overwritematerials', true);

%% Render the scene radiance

[scene, ~] = piRender(thisR, 'render type', 'radiance');
sceneName = 'Checks';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);

%%
% The name of the material is Mat.  We are going to use the texture to
% describe the diffuse reflectance of the material.
idx = piTextureFind(thisR,'name','reflectanceChart_color');
piTextureAssignToMaterial(thisR, 'Mat', 'texturekd', idx);
piWrite(thisR, 'overwritematerials', true);
[scene, ~] = piRender(thisR, 'render type', 'radiance');
sceneName = 'Color repeat';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);

%%