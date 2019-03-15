%% t_eyeDoF.m
% Demonstrate the effect of pupil diameter on scene field depth.
%
% Description:
%    This tutorial shows the effect of pupil diameter on the depth of field
%    in the scene.
%
% Dependencies:
%   iset3d, isetbio, Docker
%
% History:
%    XX/XX/17  TL   ISETBIO Team, 2017
%    03/14/19  JNM  Documentation Pass

%% Initialize ISETBIO
if isequal(piCamBio, 'isetcam')
    fprintf('%s: requires ISETBIO, not ISETCam\n', mfilename); 
    return;
end
ieInit;

%% Load scene
% The "chessSetScaled" is the chessSet scene but scaled and shifted in a
% way that emphasizes the depth of field of the eye. The size of the chess
% pieces and the board may no longer match the real world.
myScene = sceneEye('chessSetScaled');

%% Render a quick, LQ image
% This takes roughly 10 sec to render on an 8 core machine.
myScene.accommodation = 1 / 0.28;
myScene.fov = 30;
myScene.numCABands = 0;
myScene.diffractionEnabled = false;
myScene.numBounces = 1;
myScene.pupilDiameter = 4;

myScene.numRays = 128;
myScene.resolution = 128;
myScene.name = 'chessSetTest';

% to reuse an existing rendered file of the correct size, uncomment the
% parameter provided below.
[oi, results] = myScene.render(); %'reuse');

ieAddObject(oi);
oiWindow;

%% Loop through pupil diameters
% This takes roughly 5 min to render on an 8 core machine.

% Increase the quality
myScene.numCABands = 6;
myScene.numBounces = 3;
myScene.numRays = 256;
myScene.resolution = 256;

pupilDiameter = [2 4 6];
for pd = pupilDiameter
    myScene.pupilDiameter = pd;

    myScene.name = sprintf('DoF%0.2fmm', pd);
    [oi, results] = myScene.render;
    % [Note: JNM - reusing is inadvisable here as the parameters being
    % rendered change between instances.]
    % [oi, results] = myScene.render('reuse');

    vcAddAndSelectObject(oi);
    oiWindow;
end
