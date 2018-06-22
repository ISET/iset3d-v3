%% t_eyeDoF.m
%
% This tutorial shows the effect of pupil diameter on the depth of field in
% the scene.
% 
% Depends on: iset3d, isetbio, Docker
%
% TL ISETBIO Team, 2017  

%% Initialize ISETBIO
ieInit;

%% Load scene

% The "chessSetScaled" is the chessSet scene but scaled and shifted in a
% way that emphasizes the depth of field of the eye. The size of the chess
% pieces and the board may no longer match the real world.
myScene = sceneEye('chessSetScaled');

%% Render a quick, LQ image
% This takes roughly 10 sec to render on an 8 core machine.

myScene.accommodation = 1/0.28;
myScene.fov = 30;
myScene.numCABands = 0;
myScene.diffractionEnabled = false;
myScene.numBounces = 1;
myScene.pupilDiameter = 4;

myScene.numRays = 128;
myScene.resolution = 128;

myScene.name = 'chessSetTest';
[oi,results] = myScene.render;

ieAddObject(oi);
oiWindow;

%% Loop through pupil diameters
% This takes roughly 5 min to render on an 8 core machine.

% Increase the quality
myScene.numCABands = 6;
myScene.numBounces = 3;
myScene.numRays = 256;
myScene.resolution = 256;
    
pupilDiameter = [2 4 6 8];
for pd = pupilDiameter
    
    myScene.pupilDiameter = pd;
    
    myScene.name = sprintf('DoF%0.2fmm',pd);
    [oi,results] = myScene.render;
    
    vcAddAndSelectObject(oi);
    oiWindow;
end







