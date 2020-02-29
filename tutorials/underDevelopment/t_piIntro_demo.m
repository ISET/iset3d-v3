%% A tutorial for ISET demonstration
% t_piIntro_demo

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
    'from', thisR.lookAt.from,...
    'to', thisR.lookAt.to);

%% Used for scene
[scene, result] = piRender(thisR, 'render type', 'all');
sceneWindow(scene);

%% Translate and rotate the camera
thisR = piCameraTranslate(thisR, 'x shift', 3,...
                                 'z shift', -0.5);

thisR = piCameraRotate(thisR, 'y rot', 30);

%% Write the recipe
piWrite(thisR);

%% Used for scene
[scene, result] = piRender(thisR, 'render type', 'all');
sceneWindow(scene);