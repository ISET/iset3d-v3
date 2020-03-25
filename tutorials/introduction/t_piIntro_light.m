%% t_piIntro_light
%
% Render the checkerboard scene with two different light sources
%

%% Initialize ISET and Docker

% We start up ISET and check that the user is configured for docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the file
thisR = piRecipeDefault('scene name','checkerboard');

%% The output will be written here
sceneName = 'checkerboard';
outFile = fullfile(piRootPath,'local',sceneName,'checkerboard.pbrt');
thisR.set('outputFile',outFile);

%% Check the light list
piLightGet(thisR);

%% Remove all the current light
thisR    = piLightDelete(thisR, 'all');
lightList = piLightGet(thisR);

%% Add one equal energy light
thisR = piLightAdd(thisR,... 
    'type','spot',...
    'light spectrum','equalEnergy',...
    'spectrumscale', 1,...
    'cameracoordinate', true);

%% Set up the render quality

% There are many different parameters that can be set.
thisR.set('film resolution',[192 192]);
thisR.set('pixel samples',128);
thisR.set('max depth',5); % Number of bounces

%% Render
piWrite(thisR);

%% Used for scene
[scene, result] = piRender(thisR, 'render type', 'radiance');

sceneWindow(scene);

%%  Change the light and render again

% Something wrong with the coordinate camera
thisR    = piLightDelete(thisR, 'all');
thisR = piLightAdd(thisR,... 
    'type','point',...
    'light spectrum','D65',...
    'spectrumscale', 1,...
    'cameracoordinate', true);
%% Check the light list
piLightGet(thisR);

%% Render
piWrite(thisR);

%% Used for scene
[scene, result] = piRender(thisR, 'render type', 'both');

sceneWindow(scene);

%%
