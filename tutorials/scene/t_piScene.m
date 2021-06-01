%% Render some example scenes
%

%% Initialize ISET and Docker
%
% We start up ISET and check that the user is configured for docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% This is the teapot scene

% Why is this so slow to be read?
thisR = piRecipeDefault('scene name','teapot');
% Set up the render quality
thisR.set('film resolution',[192 192]);
thisR.set('pixel samples',128);
thisR.set('max depth',5); % Number of bounces

%% Write out recipe and render. Then show.
piWrite(thisR);

% This is a pinhole case. So we are rendering a scene.
scene = piRender(thisR);
sceneWindow(scene);
scene = sceneSet(scene,'gamma',0.7);

%% Notice that we also computed the depth map.
% This is the default for piRender.
scenePlot(scene,'depth map');

%% Kitchen scene

thisR = piRecipeDefault('scene name','kitchen');
thisR.set('film resolution',[512 512]);
thisR.set('pixel samples',256);
thisR.set('max depth',5); % Number of bounces

piWrite(thisR);
scene = piRender(thisR,'render type','radiance');
sceneWindow(scene);
scene = piAIdenoise(scene);
sceneWindow(scene);


%% END
