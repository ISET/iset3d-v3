% t_textureSwitch
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
                
%% Change the texture to checker
piTextureCreate(thisR, 'name', 'checks',...
                       'format', 'spectrum',...
                       'type', 'checkerboard',...
                       'float uscale', 8,...
                       'float vscale', 8,...
                       'spectrum tex1', [.01 .01 .01],...
                       'spectrum tex2', [.99 .99 .99]);
                   
%% Display material list
piMaterialList(thisR);
%% Assign texture on fbm
piTextureAssignToMaterial(thisR, 'Matte', 'spectrum Kd', 2);

%% Write the recipe
piWrite(thisR, 'overwritematerials', true);

%% Render the scene
[scene, ~] = piRender(thisR, 'render type', 'radiance');
sceneName = 'Checks';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);