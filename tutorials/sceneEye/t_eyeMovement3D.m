%% Demonstrate how to translate and rotate the eye using chess set scene.
%
% Description:
%    This tutorial shows how to translate and rotate the eye throughout the
%    scene. We will use the chess set scene for this tutorial.
%
% Dependencies:
%   iset3d, isetbio, Docker, RemoteDataToolbox
%
% History:
%    XX/XX/17  TL   ISETBIO Team, 2017
%    03/15/19  JNM  Documentation pass

%% Initialize ISETBIO
if isequal(piCamBio,'isetcam')
    error('%s: requires ISETBIO, not ISETCam\n',mfilename);
end
ieInit;

%% Translate eye
% We can translate the position of the eye by changing the "eyeFrom"
% parameter in the sceneEye.
% This section takes around 5 min to render on a 2 core machine.
%
% This scene consists of several chess pieces on a chess set. The
% dimensions match a real world chess set.
myScene = sceneEye('chessSet');

% Since we will be rendering many images, let's keep the quality fairly low
myScene.resolution = 128;
myScene.numRays = 256;

% [Note: XXX - We have to be careful around the "to" point. For example, a
% render of from = [0 0 0] and to = [0 1 1] is going to be very different
% than a render from = [0 0 0] and to = [0 100 1]. One rotates the camera
% from the y-axis by 45 degrees, the other rotates it by 0.5 degrees!]

% Shift in the x-direction
xShift = [-50 -25 0 25 50] .* 10 ^ -3; % convert from mm to meters
originalPos = myScene.eyePos;
imageFrames = cell(length(xShift),1);
for ii = 1:length(xShift)
    myScene.eyePos = originalPos + [xShift(ii) 0 0];
    myScene.name = sprintf('eyePos_%0.2f',xShift(ii));

    % to reuse an existing rendered file of the correct size, uncomment the
    % parameter provided below.
    oi = myScene.render; %('reuse', true);
    imageFrames{ii} = oiGet(oi,'rgb');

    vcAddAndSelectObject(oi);
    oiWindow;
end

% Loop through images like a video
% TODO: Best way to do this?

%% Rotate the eye
% We can rotate the eye by changing the "eyeTo" point. Another way to say
% this is that we are changing where the eye is looking.
% This section takes around 5 min to render on a 2 core machine.

% Set the position back to the original.
myScene.eyePos = originalPos;

% Scan the scene
xShift = [-100 -50 0 50 100] .* 10 ^ -3; % convert from mm to meters;
originalTo = myScene.eyeTo;
imageFrames = cell(length(xShift),1);
for ii = 1:length(xShift)
    myScene.eyeTo = originalTo + [xShift(ii) 0 0];
    myScene.name = sprintf('eyeTo_%0.2f',xShift(ii));

    % to reuse an existing rendered file of the correct size, uncomment the
    % parameter provided below.
    oi = myScene.render; %('reuse', true);
    imageFrames{ii} = oiGet(oi,'rgb');

    vcAddAndSelectObject(oi);
    oiWindow;
end

% Loop through images like a video
% TODO: Best way to do this?
