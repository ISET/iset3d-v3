%% t_piLightSpectrum
%
% Render the checkerboard scene with two light spectra
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

%% Set up the render parameters
piCameraTranslate(thisR,'z shift',2);

%% Check the light list
piLightGet(thisR);

%% Remove all the lights
thisR     = piLightDelete(thisR, 'all');
lightList = piLightGet(thisR);

%% Add one equal energy light

% The cone angle describes how far the spotlight spreads
% The cone delta angle describes how rapidly the light falls off at the
% edges
thisR = piLightAdd(thisR,... 
    'type','spot',...
    'light spectrum','equalEnergy',...
    'spectrum scale', 1,...
    'cone angle',20,...
    'cameracoordinate', true);

%% Render
piWrite(thisR);

%% Used for scene
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Equal energy (spot)');
sceneWindow(scene);

%%  Narrow the cone angle of the spot light a lot
idx = 1;
piLightSet(thisR,idx,'spectrum', 'tungsten');
piWrite(thisR);

%% Used for scene
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Tungsten');
sceneWindow(scene);

%%
