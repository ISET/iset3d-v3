% Use rendering through model eye to obtain mm on retina per degree
% 
% Description:
%    Render two spots, one red and one green, of known spatial
%    separation in terms of visual angle.  Compute separation
%    in terms of mm on the retina.

% History:
%   TL ISETBIO Team, 2017

%% Initialize ISETBIO
ieInit;
clear; close all;

%% Load scene
myScene = sceneEye('blankScene');

%% Add in spheres

% Save the original scene, just in case
% we want it back later.
originalWorld = myScene.recipe.world; 

sphereDistanceMeters = 100; % meters
sphereDiameterDegrees = 0.1;
sphereRadiusMeters = tand(sphereDiameterDegrees/2)*sphereDistanceMeters;

% Add a red sphere on the optical axis
myScene.recipe = piAddSphere(myScene.recipe,...
    'rgb',[1 0 0],...
    'radius',sphereRadiusMeters,...
    'location',[0 0 sphereDistanceMeters]);

% Add a green sphere displaced horizontally
sphereSeparationDegrees = 0.5;
sphereSeparationMeters = sphereDistanceMeters*tand(sphereSeparationDegrees);
myScene.recipe = piAddSphere(myScene.recipe,...
    'rgb',[0 1 0],...
    'radius',sphereRadiusMeters,...
    'location',[sphereSeparationMeters 0 sphereDistanceMeters]);

%% Set rendering parameters
myScene.fov = 2.5;
myScene.resolution = 256; 
myScene.numRays = 128;
myScene.accommodation = 1/sphereDistanceMeters;

%% Render
myScene.name = 'degToMm';
[oi, result] = myScene.render;
vcAddAndSelectObject(oi);
oiWindow;

%% Convert oi pixel units to mm
%
% The rendering works in mm on the retina.
% But the oi works in degrees.  So we need
% to know how the rendering converted converts
% the fov in degrees to mm.  This is done using
% simple trig and the focal length in the oi.
focalLengthMeters = oiGet(oi,'focal length');
renderingMmPerDegree = 1e3*tand(1)*focalLengthMeters;
fieldOfViewMm = oiGet(oi,'fov')*renderingMmPerDegree;
mmPerPixel = fieldOfViewMm/oiGet(oi,'cols');

%% Find the separation of the two spots in pixels
%
% Look for max and min in an RG image, with this created
% as the difference between two images at different wavelengths.
photons = oiGet(oi,'photons');
wavelengths = oiGet(oi,'wave');
indexGreen = find(wavelengths == 500);
indexRed = find(wavelengths == 700);
photonsGreen = squeeze(photons(:,:,indexGreen));
photonsRed = squeeze(photons(:,:,indexRed));
photonsRG = photonsRed-photonsGreen;

% Read peak
[~,minIndexRed] = max(photonsRG(:));
[iRed,jRed] = ind2sub(size(photonsRG),minIndexRed);
figure; imshow(photonsRed/max(photonsRed(:)));
photonsRed(iRed,jRed) = max(photonsRed(:));
figure; imshow(photonsRed/max(photonsRed(:)));

% Green peak location
[~,maxIndexGreen] = min(photonsRG(:));
[iGreen,jGreen] = ind2sub(size(photonsRG),maxIndexGreen);
figure; imshow(photonsGreen/max(photonsGreen(:)));
photonsGreen(iGreen,jGreen) = max(photonsGreen(:));
figure; imshow(photonsGreen/max(photonsGreen(:)));

% Offset in pixels and then mm
offsetPixels = jGreen - jRed;
offsetMm = mmPerPixel*offsetPixels;

%% Convert to mm per degree
mmPerDegree = offsetMm/sphereSeparationDegrees;
fprintf('For %0.1d deg separation, %0.3f mm on retina, %0.3f mm/deg\n', ...
    sphereSeparationDegrees,offsetMm,mmPerDegree);

