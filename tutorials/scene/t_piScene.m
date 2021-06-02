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
thisR.set('max depth',3); % Number of bounces

%% Write out recipe and render. Then show.
piWrite(thisR);

% This is a pinhole case. So we are rendering a scene.
scene = piRender(thisR);
sceneWindow(scene);

%% By default we also computed the depth map.

scenePlot(scene,'depth map');

%% Simple scene

thisR = piRecipeDefault('scene name','simple scene');
thisR.set('film resolution',[192 192]);
thisR.set('pixel samples',32);
thisR.set('max depth',3); % Number of bounces

piWrite(thisR);
scene = piRender(thisR,'render type','radiance');
sceneWindow(scene);

thisR.show;

%% Chess set

thisR = piRecipeDefault('scene name','chess set');
thisR.set('film resolution',[192 192]);
thisR.set('pixel samples',32);
thisR.set('max depth',3); % Number of bounces

piWrite(thisR);
scene = piRender(thisR,'render type','radiance');
sceneWindow(scene);

%% Kitchen scene

thisR = piRecipeDefault('scene name','kitchen');
thisR.set('film resolution',[192 192]);
thisR.set('pixel samples',32);
thisR.set('max depth',3); % Number of bounces

piWrite(thisR);
scene = piRender(thisR,'render type','radiance');
sceneWindow(scene);

scene = piAIdenoise(scene);
sceneWindow(scene);

%% END
