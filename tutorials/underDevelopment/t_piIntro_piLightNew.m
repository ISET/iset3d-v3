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
if ~piDockerExists, piDockerConfig; end

%% Init a default recipe 

% This the MCC scene
thisR = piRecipeDefault;

%% Delete all the lights
thisR = piLightDelete(thisR, 'all');

%% Add one equal energy light

thisR = piLightAdd(thisR,... 
    'type','spot',...
    'light spectrum','equalEnergy',...
    'spectrumscale', 1,...
    'cameracoordinate', true);

%% Test new get light function

lights = piLightGet(thisR);

% This returns a cell array of the lights
disp(lights{1})

%% Test new delete light function
thisR = piLightDelete(thisR, 'all');

%%  Now add two different lights

% The flag puts the lights at the position of the camera
thisR = piLightAdd(thisR,... 
    'type','point',...
    'light spectrum','D65',...
    'spectrum scale', 1,...
    'camera coordinate', true);

thisR = piLightAdd(thisR,... 
    'type','spot',...
    'cone angle',10, ...
    'cone delta angle',1,...
    'light spectrum','blueLEDFlood',...
    'spectrum scale', 5000,...
    'camera coordinate', true);

%% Let's see what we have

thisR = piLightSet(thisR,1,'name','D65');
thisR = piLightTranslate(thisR, 1, 'x shift', 1.2);

thisR = piLightSet(thisR,2,'name','BlueFlood');
thisR = piLightTranslate(thisR, 2, 'x shift', -1);


% This returns a cell array of the lights
lights = piLightGet(thisR);
for ii=1:length(lights)
    disp(lights{ii})
    fprintf('\n----\n');
end

%% Write the recipe
piWrite(thisR);

%% Used for scene
[scene, result] = piRender(thisR, 'render type', 'all');

sceneWindow(scene);

%%
