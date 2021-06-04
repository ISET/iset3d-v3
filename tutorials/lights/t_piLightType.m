%% t_piLightType
%
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
thisR    = piLightDelete(thisR, 'all');
% not working
% lightList = piLightGet(thisR);

%% Add one equal energy light

% The cone angle describes how far the spotlight spreads
% The cone delta angle describes how rapidly the light falls off at the
% edges
spotlight = piLightCreate('new skymap',...
    'type','spot',...
    'spd','equalEnergy',...
    'spectrum scale', 1,...
    'coneangle',20,...
    'cameracoordinate', true);

thisR.set('light', 'add', spotlight);
%% Render
piWrite(thisR);

%% Used for scene
scene = piRender(thisR, 'render type', 'radiance');
val   = piLightGet(thisR,'idx',1,'param','coneangle','print',false);
scene = sceneSet(scene,'name',sprintf('EE spot %d',val));
sceneWindow(scene);

%%  Narrow the cone angle of the spot light a lot
idx = 1;
piLightSet(thisR,idx,'cone angle', 10);
piWrite(thisR);

%% Used for scene
scene = piRender(thisR, 'render type', 'radiance');
val   = piLightGet(thisR,'idx',1,'param','coneangle','print',false);
scene = sceneSet(scene,'name',sprintf('EE spot %d',val));
sceneWindow(scene);

%%  Change the light and render again
piLightSet(thisR,idx,'type','spot');
piLightTranslate(thisR,idx,...
    'z shift',2,...
    'x shift',2);
piLightSet(thisR,idx,'cone angle', 25);
piWrite(thisR);

shiftedSpotLight = piLightGet(thisR,'idx',1);

%% Used for scene
scene = piRender(thisR, 'render type', 'radiance');
val   = piLightGet(thisR,'idx',1,'param','from','print',false);
scene = sceneSet(scene,'name',sprintf('EE point [%d,%d,%d]',val));
sceneWindow(scene);

%%  Change the light and render again
piLightSet(thisR,idx,'type', 'infinite');
piWrite(thisR);

%% Used for scene
scene = piRender(thisR, 'render type', 'radiance');
val = piLightGet(thisR,'idx',idx,'param','type');
scene = sceneSet(scene,'name',sprintf('EE type %s',val));
sceneWindow(scene);

%%  Add the shifted spot light to the infinite light source
piLightAdd(thisR,'new light source',shiftedSpotLight);

