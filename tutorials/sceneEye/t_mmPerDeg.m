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
showOi = true;
showFigs = false;

%% Parameters
sphereDistanceMeters = 100; 
sphereDiameterDegrees = 0.4;
renderingFovDegrees = 40;

%% Loop over separations in degrees
sphereSeparationsDegrees = [0.5 1 2 4 6 8 10 12 14 16 18];
for ss = 1:length(sphereSeparationsDegrees)
    %% Load scene, compute sphere specifics and add spheres
    sphereSeparationDegrees = sphereSeparationsDegrees(ss);
    sphereSeparationMeters = sphereDistanceMeters*tand(sphereSeparationDegrees);
    sphereRadiusMeters = tand(sphereDiameterDegrees/2)*sphereDistanceMeters;

    % Load scene
    theScene = sceneEye('blankScene');

    % Add red sphere on the optical axis
    theScene.recipe = piAddSphere(theScene.recipe,...
    'rgb',[1 0 0],...
    'radius',sphereRadiusMeters,...
    'location',[0 0 sphereDistanceMeters]);

    % Add horizontally offset green sphere
    theScene.recipe = piAddSphere(theScene.recipe,...
        'rgb',[0 1 0],...
        'radius',sphereRadiusMeters,...
        'location',[sphereSeparationMeters 0 sphereDistanceMeters]);
    
    %% Set rendering parameters
    theScene.fov = renderingFovDegrees;
    theScene.resolution = 512;
    theScene.numRays = 128;
    theScene.accommodation = 1/sphereDistanceMeters;
    
    %% Model eye radius
    %
    % This is for the Navarro model
    % eye.  Might someday figure out
    % how to get it out of the lens structure.
    modelEyeRadiusMm = 12;
    
    %% Render
    theScene.name = 'degToMm';
    [oi, result] = theScene.render;
    if (showOi)
        vcAddAndSelectObject(oi);
        oiWindow;
    end
    
    %% Convert oi pixel units to mm
    %
    % The rendering works in mm on the retina.
    % But the oi works in degrees.  So we need
    % to know how the rendering converted converts
    % the fov in degrees to mm.  This is done using
    % simple trig and the focal length in the oi.
    focalLengthMeters = oiGet(oi,'focal length');
    renderingMmPerDegree = 1e3*tand(1)*focalLengthMeters;
    renderingFieldOfViewMm = oiGet(oi,'fov')*renderingMmPerDegree;
    renderingMmPerPixel = renderingFieldOfViewMm/oiGet(oi,'cols');
    fprintf('Model eye focal length %0.2f, mm per deg from trig = %0.3f\n', ...
        1e3*focalLengthMeters,renderingMmPerDegree);
    
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
    photonsRed(iRed,jRed) = max(photonsRed(:));
    if (showFigs)
        figure; imshow(photonsRed/max(photonsRed(:)));
    end
    
    % Green peak location
    [~,maxIndexGreen] = min(photonsRG(:));
    [iGreen,jGreen] = ind2sub(size(photonsRG),maxIndexGreen);
    photonsGreen(iGreen,jGreen) = max(photonsGreen(:));
    if (showFigs)
        figure; imshow(photonsGreen/max(photonsGreen(:)));
    end
    
    % Offset in pixels and then mm
    offsetPixels(ss) = jGreen - jRed;
    offsetOnChordMm(ss) = renderingMmPerPixel*offsetPixels(ss);
    
    %% Correct for the chord
    %
    % The image is on a chord drawn of the specified width
    % across the back of the spherical model eye. Correct for
    % this.
    
    % How far is chord from center of sperical model eye
    distanceToChordMm = sqrt(modelEyeRadiusMm^2-(renderingFieldOfViewMm/2)^2);
    offsetInSphereDeg = atand(offsetOnChordMm(ss)/distanceToChordMm);
    offsetOnRetinaMm(ss) = offsetInSphereDeg*modelEyeRadiusMm*(pi/180);
    
    %% Convert to mm per degree
    mmPerDegreeOnChord(ss) = offsetOnChordMm(ss)/sphereSeparationDegrees;
    mmPerDegreeOnRetina(ss) = offsetOnRetinaMm(ss)/sphereSeparationDegrees;
    fprintf('For %0.1f deg separation, %0.3f mm on rendering chord, %0.3f mm/deg on chord\n', ...
        sphereSeparationsDegrees(ss),offsetOnChordMm(ss),mmPerDegreeOnChord(ss));
    fprintf('For %0.1f deg separation, %0.3f mm on retina, %0.3f mm/deg on retina\n', ...
        sphereSeparationsDegrees(ss),offsetOnRetinaMm(ss),mmPerDegreeOnRetina(ss));
end

%% Use Drasdo formula
offsetOnRetinaDrasdoMm = DegreesToRetinalEccentricityMM(sphereSeparationsDegrees,'Human','DaceyPeterson');

%% Plot mm on retina versus degrees
figure; clf; hold on
plot(sphereSeparationsDegrees,offsetOnRetinaMm,'ro','MarkerFaceColor','r','MarkerSize',8);
plot(sphereSeparationsDegrees,offsetOnRetinaDrasdoMm,'r');
xlabel('Position (degrees)');
ylabel('Position (mm on retina)');
