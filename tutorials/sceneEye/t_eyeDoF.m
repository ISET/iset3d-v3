%% t_eyeDoF.m
%
% This tutorial shows the effect of pupil diameter on the depth of field in
% the scene.
% 
% Depends on: pbrt2ISET, ISETBIO, Docker
%
% TL ISETBIO Team, 2017
    

%% Initialize ISETBIO
ieInit;

%% Load scene

% The "chessSetScaled" is the chessSet scene but scaled and shifted in a
% way that emphasizes the depth of field of the eye. The size of the chess
% pieces and the board may no longer match the real world.
myScene = sceneEye('chessSetScaled');

%% Fast test

myScene.accommodation = 1/0.28;
myScene.fov = 30;
myScene.numCABands = 0;
myScene.diffractionEnabled = false;
myScene.numBounces = 4;
myScene.pupilDiameter = 4;

myScene.numRays = 256;
myScene.resolution = 256;

myScene.name = 'chessSetTest';
[oi,results] = myScene.render;

vcAddAndSelectObject(oi);
oiWindow;


%% Loop through pupil diameter

pupilDiameter = [2 4 6 8];
for pd = pupilDiameter
    
    myScene.pupilDiameter = pd;
    
    myScene.numRays = 256;
    myScene.resolution = 256;
    
    myScene.name = sprintf('DoF%0.2fmm',pd);
    [oi,results] = myScene.render;
    
    vcAddAndSelectObject(oi);
    oiWindow;
end







