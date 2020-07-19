%% t_piIntro_light
%
% Render the checkerboard scene with two different light sources
%

%% Initialize ISET and Docker

% We start up ISET and check that the user is configured for docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the file
thisR = piRecipeDefault('scene name','MacBethChecker');

%% The output will be written here
sceneName = 'MacBethChecker';
outFile = fullfile(piRootPath,'local',sceneName,'MacBethChecker.pbrt');
thisR.set('outputFile',outFile);

%% Check the light list
piLightGet(thisR);

%% Remove all the lights
thisR    = piLightDelete(thisR, 'all');
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

%% Set up the render parameters
piCameraTranslate(thisR,'z shift',2);  % Meters

%% Render
piWrite(thisR);

%% Used for scene
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Equal energy (spot)');
sceneWindow(scene);

%%  Narrow the cone angle of the spot light a lot
idx = 1;
piLightSet(thisR,idx,'cone angle', 10);

%% Render
piWrite(thisR);

%% Used for scene
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Equal energy (spot)');
val = piLightGet(thisR,'idx',1,'param','coneangle','print',false);
scene = sceneSet(scene,'name',sprintf('EE spot %d',val));
sceneWindow(scene);

%%  Change the light and render again

thisR    = piLightDelete(thisR, 'all');
thisR = piLightAdd(thisR,... 
    'type','point',...
    'light spectrum','Tungsten',...
    'spectrumscale', 1,...
    'cameracoordinate', true);
%% Check the light list
piLightGet(thisR);

%% Render
piWrite(thisR);

%% Used for scene
[scene, result] = piRender(thisR, 'render type', 'both');
scene = sceneSet(scene,'name','Tungsten (point)');
sceneWindow(scene);

%% END