%% init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read Cornell Box
thisR = piRecipeDefault('scene name', 'cornell box bunny chart');

% Modify the film resolution
thisR.set('filmresolution', [256, 256]);

%% Add new light
thisR = piLightAdd(thisR,... 
    'type','point',...
'light spectrum','Tungsten',...
'cameracoordinate', true);

%% Write recipe
piWrite(thisR);

%% Render and visualize
[scene, results] = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);