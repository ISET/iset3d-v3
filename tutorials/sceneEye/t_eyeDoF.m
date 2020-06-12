%% t_eyeDoF.m
%
% This tutorial uses the sceneEye class and methods to calculate the effect
% of pupil diameter on the depth of field in the scene.
% 
% Depends on: iset3d, isetbio, Docker
%
% TL ISETBIO Team, 2017  

%% Initialize ISETBIO
if ~isequal(piCamBio,'isetbio')
    fprintf('%s: requires ISETBIO\n',mfilename); 
    return;
end
ieInit;

%% Load scene

myScene = sceneEye('chessSet');
myScene.name = 'chessSetTest';

%{
% Some other scenes to try
 myScene = sceneEye('snellenAtDepth');
 myScene = sceneEye('slantedBarTexture'); myScene.name = 'slantedbar';
 myScene = sceneEye('colorfulScene');
 myScene.name = 'colorfulScene';
 myScene.recipe.set('exporter','Copy')
%}
    
%% Render a quick, LQ image
% This takes roughly 10 sec to render on an 8 core machine.

myScene.accommodation = 1/0.28;
myScene.fov = 30;
myScene.numCABands = 8;
myScene.diffractionEnabled = true;
myScene.numBounces = 1;
myScene.pupilDiameter = 2;

myScene.numRays    = 128;
myScene.resolution = 256;

%% Set up the name and render

[oi,results] = myScene.render;
oiWindow(oi);

%% Loop through pupil diameters

% Increase the quality
myScene.numCABands = 8;
myScene.numBounces = 3;
myScene.numRays    = 1024;
myScene.resolution = 512;

pupilDiameter = [2 4 6];
for pd = pupilDiameter
    
    myScene.pupilDiameter = pd;
    
    myScene.name = sprintf('DoF%0.2fmm',pd);
    [oi,results] = myScene.render;
    
    oiWindow(oi);
end


%%




