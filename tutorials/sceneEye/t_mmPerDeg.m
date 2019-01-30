% Use rendering through model eye to obtain mm on retina per degree
%
% *****Warning*****
% This tutorial may be outdated. I would suggest using it only as reference
% at the moment.
%
% Description:
%    Render two spots, one red and one green, of known spatial
%    separation in terms of visual angle.  Compute separation
%    in terms of mm on the retina.
%
% History:
%   TL ISETBIO Team, 2017
%
%   06/08/18 dhb Process outcome, loop over separation.

%% Initialize ISETBIO
if isequal(piCamBio,'isetcam')
    fprintf('%s: requires ISETBIO, not ISETCam\n',mfilename); 
    return;
end

ieInit;

clear; close all;
showOi = true;
showFigs = true;

%% Parameters
renderingFovPixels = 512;
sphereDistanceMeters = 100;
sphereDiameterPixels = 10;
sphereSeparationsDegrees = [0.5 1 2.5 5 10 15 20 25 28];
fovFactor = 2.5;
% sphereSeparationsDegrees = [0.5 1 2.5 5 10 15 20];
% fovFactor = 3.5;

%% Loop over separations in degrees
for ss = 1:length(sphereSeparationsDegrees)
    %% Load scene, compute sphere specifics and add spheres
    sphereSeparationDegrees = sphereSeparationsDegrees(ss);
    renderingFovDegrees(ss) = fovFactor*sphereSeparationDegrees;
    sphereDiameterDegrees = sphereDiameterPixels*renderingFovDegrees(ss)/renderingFovPixels;
    sphereSeparationMeters = sphereDistanceMeters*tand(sphereSeparationDegrees);
    sphereRadiusMeters = tand(sphereDiameterDegrees/2)*sphereDistanceMeters;

    % Load scene
    theScene = sceneEye('blankScene');

    % Add red sphere on the optical axis
    theScene.recipe = piAddSphere(theScene.recipe,...
    'rgb',[1 0.05 0],...
    'radius',sphereRadiusMeters,...
    'location',[0 0 sphereDistanceMeters]);

    % Add horizontally offset green sphere
    theScene.recipe = piAddSphere(theScene.recipe,...
        'rgb',[0.05 1 0],...
        'radius',sphereRadiusMeters,...
        'location',[sphereSeparationMeters 0 sphereDistanceMeters]);
    
    %% Set rendering parameters
    theScene.fov = renderingFovDegrees(ss);
    theScene.resolution = renderingFovPixels;
    theScene.numRays = 256;
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
    focalLengthMm(ss) = 1e3*oiGet(oi,'focal length');
    renderingFovMm(ss) = 2*focalLengthMm(ss)*tand(oiGet(oi,'fov')/2);
    renderingMmPerDegree(ss) = renderingFovMm(ss)/renderingFovDegrees(ss);
    renderingMmPerPixel(ss) = renderingFovMm(ss)/oiGet(oi,'cols');

    % Checks
    if (abs(renderingFovDegrees(ss)-oiGet(oi,'fov')) > 1e-6)
        error('Inconsistent fov size in degrees');
    end
    if (abs(renderingFovMm(ss)-oiGet(oi,'width','mm'))/renderingFovMm(ss) > 1e-6)
        error('Inconsistent size of rendering plane');
    end
    if (renderingFovMm(ss) > 2*modelEyeRadiusMm)
        error('Field of view exceeds eye diameter\n');
    end
    
    %% Find the separation of the two spots in pixels
    %
    % Look for max and min in an RG image, with this created
    % as the difference between two images at different wavelengths.
    edgeTossPixels = 20;
    photons = oiGet(oi,'photons');
    wavelengths = oiGet(oi,'wave');
    indexGreen = find(wavelengths == 500);
    indexRed = find(wavelengths == 700);
    photonsGreen = squeeze(photons(1+edgeTossPixels:end-edgeTossPixels,1+edgeTossPixels:end-edgeTossPixels,indexGreen));
    photonsRed = squeeze(photons(1+edgeTossPixels:end-edgeTossPixels,1+edgeTossPixels:end-edgeTossPixels,indexRed));
    photonsRG = photonsRed/max(photonsRed(:))-photonsGreen/max(photonsGreen(:));
    
    % Find red peak location
    gauassianSigmaPixels = 3;
    gaussianSizePixels = 9;
    convKernal = fspecial('gaussian',[gaussianSizePixels gaussianSizePixels],gauassianSigmaPixels);
    smoothRG = conv2(photonsRG,convKernal,'same');
    [mValid,nValid] = size(smoothRG);
    centerValid = round(mValid/2);
    iRed = centerValid;
    [~,jRed] = max(smoothRG(iRed,:));
    % [~,indexRed] = max(smoothRG(:));
    % [iRed,jRed] = ind2sub(size(smoothRG),indexRed);
    
    % Find green peak location
    iGreen = centerValid;
    [~,jGreen] = min(smoothRG(iGreen,:));
    % [~,indexGreen] = min(smoothRG(:));
    % [iGreen,jGreen] = ind2sub(size(smoothRG),indexGreen);
    
    % Figure to diagnose whether we found the right place in 
    % the image.
    if (showFigs)
        figure; clf; hold on
        plot(photonsRG(iGreen,:),'y','LineWidth',2);
        plot(smoothRG(iGreen,:),'k:','LineWidth',2);
        plot([jGreen jGreen],[min(smoothRG(iGreen,:)) max(smoothRG(iGreen,:))],'g','LineWidth',2);
        plot([jRed jRed],[min(smoothRG(iGreen,:)) max(smoothRG(iGreen,:))],'r','LineWidth',2);
        xlabel('Position (pixels)')
        ylabel('Intensity');
        title({sprintf('Separation %0.1f deg, fov %0.1f (deg)', ...
            sphereSeparationDegrees,renderingFovDegrees(ss)) ; ...
            sprintf('Red ctr %d pixels, green ctr %d pixels, image %d pixels, actual ctr %d', ...
            jRed,jGreen,nValid,centerValid) });
    end
    
    % Offset in pixels and then mm
    offsetPixels(ss) = jGreen - jRed;
    offsetOnChordMm(ss) = renderingMmPerPixel(ss)*offsetPixels(ss);

    % Also add and subtract a few pixels to get some error bounds
    pixelErrorGuess = 2;
    offsetPixelsDown(ss) = offsetPixels(ss)-pixelErrorGuess;
    offsetOnChordMmDown(ss) = renderingMmPerPixel(ss)*offsetPixelsDown(ss);
    offsetPixelsUp(ss) = offsetPixels(ss)+pixelErrorGuess;
    offsetOnChordMmUp(ss) = renderingMmPerPixel(ss)*offsetPixelsUp(ss);
        
    %% Correct for the chord
    %
    % The image is on a chord drawn of the specified width
    % across the back of the spherical model eye. Correct for
    % this.
    
    % How far is chord from center of spherical model eye
    distanceToChordMm = sqrt(modelEyeRadiusMm^2-(renderingFovMm(ss)/2)^2);
    offsetInSphereDeg = atand(offsetOnChordMm(ss)/distanceToChordMm);
    offsetOnRetinaMm(ss) = offsetInSphereDeg*modelEyeRadiusMm*(pi/180);
    
    % Propagate error estimate
    offsetInSphereDegDown = atand(offsetOnChordMmDown(ss)/distanceToChordMm);
    offsetOnRetinaMmDown(ss) = offsetInSphereDegDown*modelEyeRadiusMm*(pi/180);
    offsetInSphereDegUp = atand(offsetOnChordMmUp(ss)/distanceToChordMm);
    offsetOnRetinaMmUp(ss) = offsetInSphereDegUp*modelEyeRadiusMm*(pi/180);
    
    %% Convert to mm per degree
    mmPerDegreeOnChord(ss) = offsetOnChordMm(ss)/sphereSeparationDegrees;
    mmPerDegreeOnRetina(ss) = offsetOnRetinaMm(ss)/sphereSeparationDegrees;
end

%% Use Drasdo formula
offsetOnRetinaDrasdoMm = DegreesToRetinalEccentricityMM(sphereSeparationsDegrees,'Human','DaceyPeterson');

%% Plot mm on retina versus degrees
figure; clf; hold on
plot(sphereSeparationsDegrees,offsetOnRetinaMm,'ro','MarkerFaceColor','r','MarkerSize',8);
errorbar(sphereSeparationsDegrees,offsetOnRetinaMm,offsetOnRetinaMm-offsetOnRetinaMmDown,offsetOnRetinaMmUp-offsetOnRetinaMm,'ro');
plot(sphereSeparationsDegrees,offsetOnRetinaDrasdoMm,'r');
xlabel('Position (degrees)');
ylabel('Position (mm on retina)');

%% Print out some useful information 
for ss = 1:length(sphereSeparationsDegrees)
    fprintf('Model eye focal length %0.2f, mm per deg from trig = %0.3f\n', ...
        focalLengthMm(ss),renderingMmPerDegree(ss));
    fprintf('For %0.1f deg separation, %0.3f mm on rendering chord, %0.3f mm/deg on chord\n', ...
        sphereSeparationsDegrees(ss),offsetOnChordMm(ss),mmPerDegreeOnChord(ss));
    fprintf('For %0.1f deg separation, %0.3f mm on retina, %0.3f mm/deg on retina\n', ...
        sphereSeparationsDegrees(ss),offsetOnRetinaMm(ss),mmPerDegreeOnRetina(ss));
    fprintf('Rendering fov: %0.1f deg, %0.1f mm, um per pixel in the rendering plane: %0.2f\n', ...
        renderingFovDegrees(ss),renderingFovMm(ss),1e3*renderingMmPerPixel(ss));
    fprintf('\n');
end

%% END