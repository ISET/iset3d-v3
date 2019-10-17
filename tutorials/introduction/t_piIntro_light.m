

%% Initialize ISET and Docker

% We start up ISET and check that the user is configured for docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the file

% The teapot is our test file
inFile = fullfile(piRootPath,'data','V3','checkerboard','checkerboard.pbrt');
recipe = piRead(inFile);

% The output will be written here
sceneName = 'checkerboard';
outFile = fullfile(piRootPath,'local',sceneName,'checkerboard.pbrt');
recipe.set('outputFile',outFile);

%% Check the light list
piLightGet(recipe);

%% Remove all the current light
recipe = piLightDelete(recipe, 1);
recipe = piLightDelete(recipe, 1);
lightList = piLightGet(recipe);

%% Add one equal energy light
recipe = piLightAdd(recipe,... 
    'type','point',...
    'light spectrum','equalEnergy',...
    'spectrumscale', 1,...
    'cameracoordinate', true);

%% Set up the render quality

% There are many different parameters that can be set.
recipe.set('film resolution',[192 192]);
recipe.set('pixel samples',128);
recipe.set('max depth',1); % Number of bounces

%% Render
piWrite(recipe);

%% Used for scene
[scene, result] = piRender(recipe, 'render type', 'radiance');

sceneWindow(scene);
