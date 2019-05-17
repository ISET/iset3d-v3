%% Simple simulation of vergence and accommodation via convergence.
%
% Description:
%    We can do a simple simulation of vergence and accommodation by having
%    the eyes converge and accommodate to a "moving" red sphere.
%
% Dependencies:
%   iset3d, isetbio, Docker, RemoteDataToolbox
%
% History:
%    XX/XX/17  TL   ISETBIO Team, 2017
%    03/15/19  JNM  Documentation Pass

%% Initialize ISETBIO
if isequal(piCamBio, 'isetcam')
    fprintf('%s: requires ISETBio, not ISETCam\n', mfilename);
    return;
end
ieInit;

%% Load scene
myScene = sceneEye('chessSet');

%% Set parameters
myScene.resolution = 128;
myScene.numRays = 128;
ipd = 64e-3; % Average interpupillary distance

% We save the original parameters so we have them around even after moving
% and rotating the eye.
originalPos = myScene.eyePos;
startingPos = originalPos + [0 0 0.1]; % This looks a little better.

% Needed because we will objects to the 3d world. This text block contains
% the "original" scene.
originalWorld = myScene.recipe.world;

%% Create binocular retinal images
% Move the red sphere to these distances along the z-axis (optical axis).
sphereZ = [-0.2 0.0 0.2]; % Along z-axis

for ii = 1:length(sphereZ)
    % We want the sphere to be at same height as the eye but at different
    % distances away from it.
    spherePos = [0 startingPos(2) sphereZ(ii)]; % [x y z]

    % Move the two eyes apart
    leftEyePos = startingPos - [ipd/2 0 0];
    rightEyePos = startingPos + [ipd/2 0 0];

    % Make them point at the sphere
    myScene.eyeTo = spherePos;

    % Reset world (Important!)
    % We want to start from the original, vanilla version of the 3d scene
    % with no sphere.
    myScene.recipe.world = originalWorld;

    % Add the red sphere
    myScene.recipe = piAddSphere(myScene.recipe, ...
        'rgb', [1 0 0], ...
        'radius', 0.005, ...
        'location', spherePos);

    % Accommodate to the sphere
    dist = sqrt(sum((spherePos - leftEyePos) .^ 2)); % in mm
    myScene.accommodation = 1 / dist;

    % Render the left eye
    myScene.eyePos = leftEyePos;
    myScene.name = sprintf('leftEye_%0.2fm', sphereZ(ii));
    [oi, result] = myScene.render;
    % [Note: JNM - reusing is inadvisable here as the parameters being
    % rendered change between instances.]
    % [oi, result] = myScene.render('reuse', true);
    vcAddAndSelectObject(oi);
    oiWindow;

    % Render the right eye
    myScene.eyePos = rightEyePos;
    myScene.name = sprintf('rightEye%0.2fm', sphereZ(ii));
    oi = myScene.render;
    % [Note: JNM - reusing is inadvisable here as the parameters being
    % rendered change between instances.]
    % oi = myScene.render('reuse', true);
    vcAddAndSelectObject(oi);
    oiWindow;

end