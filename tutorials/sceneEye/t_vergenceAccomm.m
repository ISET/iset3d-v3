%% t_vergenceAccomm.m
%
% Depends on: pbrt2ISET, ISETBIO, Docker
%
% TL ISETBIO Team, 2017

%% Initialize ISETBIO
ieInit;

%% Load scene
myScene = sceneEye('chessSet');

%% Set parameters

myScene.resolution = 128; 
myScene.numRays = 128;

ipd = 64e-3; % Average interpupillary distance

originalPos = myScene.eyePos;
originalWorld = myScene.recipe.world;
startingPos = originalPos + [0 0 0.1];

% oi = myScene.render;
% 
% ieAddObject(oi);
% oiWindow;

%% Create binocular retinal images

vergenceZ = [-0.3 0.0 0.2]; % Along z-axis

for ii = 1:length(vergenceZ)
    
    vergencePoint = [0 startingPos(2) vergenceZ(ii)];
    
    leftEyePos = startingPos - [ipd/2 0 0];
    rightEyePos = startingPos + [ipd/2 0 0];
    
    myScene.eyeTo = vergencePoint;
    
    % Reset world (Important!)
    myScene.recipe.world = originalWorld;
    
    % Add the target sphere
    myScene.recipe = piAddSphere(myScene.recipe,...
        'rgb',[1 0 0],...
        'radius',0.005,...
        'location',vergencePoint);
    
    % Set accommodation to the right distance
    dist = sqrt(sum((vergencePoint -leftEyePos).^2)); % in mm
    myScene.accommodation = 1/dist;
    
    myScene.eyePos = leftEyePos;
    myScene.name = sprintf('leftEye_%0.2fm',vergenceZ(ii));
    oi = myScene.render;
    vcAddAndSelectObject(oi);
    oiWindow;
    
    myScene.eyePos = rightEyePos;
    myScene.name = sprintf('rightEye%0.2fm',vergenceZ(ii));
    oi = myScene.render;
    vcAddAndSelectObject(oi);
    oiWindow;
    
end