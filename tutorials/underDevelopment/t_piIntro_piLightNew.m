% t_piIntro_piLightNew
%
% A demo to test the new way to manage lights in the scene.
% The basic idea is we don't put any information in to recipe.world.
% We manage the lights in recipe.lights. When writing the recipe using
% piWrite, we write the recipe into the world.
%
% Changes to check:
%   piRead              - line 304
%   piLightAdd
%   piLightAddToWorld
%   piLightDelete
%   piLightDeleteWorld
%   piLightGet
%   piLightGetWorld
%   piLightSet
%   piWrite             - line 384

%% Init
ieInit;

%% Init a default recipe and remove all lights
thisR = piRecipeDefault;
thisR = piLightDelete(thisR, 'all');

%% Add one equal energy light
thisR = piLightAdd(thisR,... 
    'type','spot',...
    'light spectrum','equalEnergy',...
    'spectrumscale', 1,...
    'cameracoordinate', true);

%% Test new get light function
lights = piLightGet(thisR);

%% Test new delete light function
thisR = piLightDelete(thisR, 'all');

%%
thisR = piLightAdd(thisR,... 
    'type','point',...
    'light spectrum','D65',...
    'spectrumscale', 1,...
    'cameracoordinate', true);

thisR = piLightAdd(thisR,... 
    'type','spot',...
    'light spectrum','blueLEDFlood',...
    'spectrumscale', 100,...
    'cameracoordinate', true);

%%
piLightGet(thisR);

%% Write the recipe
piWrite(thisR);

%% Used for scene
[scene, result] = piRender(thisR, 'render type', 'radiance');

sceneWindow(scene);

%% Change one of the light
lightNumber = 2;
thisR = piLightSet(thisR, lightNumber, 'spectrumscale', 10000);

%%
piLightGet(thisR);

%% Write the recipe
piWrite(thisR);

%% Used for scene
[scene, result] = piRender(thisR, 'render type', 'radiance');

sceneWindow(scene);

