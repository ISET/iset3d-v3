%% t_mmPerDeg.m
% 
%
% TL ISETBIO Team, 2017

%% Initialize ISETBIO
ieInit;

%% Load scene
myScene = sceneEye('blankScene');

%% Add in a red sphere

% Needed because we will objects to the 3d world. This text block contains
% the "original" scene.
originalWorld = myScene.recipe.world; 

sphereDistance = 100; % meters
sphereAngle = 0.5;
sphereRadius = tand(sphereAngle/2)*sphereDistance;

% Optical axis
myScene.recipe = piAddSphere(myScene.recipe,...
    'rgb',[1 0 0],...
    'radius',sphereRadius,...
    'location',[0 0 sphereDistance]);

% To the side
angle = 1;
x = sphereDistance*tand(angle);
myScene.recipe = piAddSphere(myScene.recipe,...
    'rgb',[0 1 0],...
    'radius',sphereRadius,...
    'location',[x 0 sphereDistance]);

%% Set parameters

myScene.resolution = 256; 
myScene.numRays = 128;
myScene.accommodation = 1/sphereDistance;

myScene.name = 'test';
[oi, result] = myScene.render;
vcAddAndSelectObject(oi);
oiWindow;

