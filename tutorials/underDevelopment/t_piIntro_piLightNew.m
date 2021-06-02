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

spotLight = piLightCreate('spotLight', ...
    'type','spot',...
    'spd', 'equalEnergy', ...
    'cameracoordinate', true);
thisR.set('light','add',spotLight);

%% Test new get light function

thisR.get('print lights');

%% Test new delete light function
thisR = piLightDelete(thisR, 'all');

%%  Now add two different lights

pointLight = piLightCreate('D65', ...
    'type','point',...
    'spd', 'D65', ...
    'cameracoordinate', true);
thisR.set('light','add',pointLight);

blueSpotLight = piLightCreate('blueSpotLight', ...
    'type','spot',...
    'coneangle',10, ...
    'conedeltaangle',1,...
    'spd','blueLEDFlood', ...
    'specscale', 5000,...
    'cameracoordinate', true);
thisR.set('light','add',blueSpotLight);

%% Let's see what we have
thisR.get('print lights');

thisR = thisR.set('light', 'translate', pointLight.name, [ 1.2 0 0]);
thisR = thisR.set('light','translate',blueSpotLight.name, [-1 0 0]);


%% Write the recipe
piWrite(thisR);

%% Used for scene
[scene, result] = piRender(thisR, 'render type', 'all');

sceneWindow(scene);

%%
