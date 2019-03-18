%% t_slantedBarMTF.m
% Estimate the MTF of the optical system using a slanted bar.
%
% Description:
%    This tutorial shows how you can render a retinal image of "slanted
%    bar." We can then use this slanted bar to estimate the modulation
%    transfer function of the optical system.
%
%    We also show how the color fringing along the edge of the bar due to
%    chromatic aberration.
%
%    We recommend you go through t_rayTracingIntroduction.m before running
%    this tutorial.
%
% Dependencies:
%   pbrt2ISET, ISETBIO, Docker, ISET
%
% History:
%    XX/XX/17  TL   ISETBIO Team, 2017
%    01/05/19  dhb  This broken because it calls a function
%                   calculateMTFFromSlantedBar that does not
%                   exist in iset3d or isetbio.
%    03/15/19  JNM  Documentation Pass

%% Initialize ISETBIO
if isequal(piCamBio, 'isetcam')
    fprintf('%s: requires ISETBio, not ISETCam\n', mfilename);
    return;
end
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Render a fast image of the slanted bar first
% The slanted bar scene consists of a square plane (1x1 m) that is split in
% half diagonally. The bottom left half is white while the top right half
% is black. By default the plane is placed at [0 0 1] meters, but we can
% change that by given sceneEye an optional 'planeDistance' input.
%
% Create a slanted bar at 0.5 meter
myScene = sceneEye('slantedBar', 'planeDistance', 0.5);
myScene.name = 'slantedBarFast';
myScene.numRays = 64;
myScene.resolution = 128;

myScene.accommodation = 2;
myScene.pupilDiameter = 4;
myScene.fov = 4;

myScene.debugMode = true;
% to reuse an existing rendered file of the correct size, uncomment the
% parameter provided below.
scene = myScene.render; %('reuse');

vcAddObject(scene);
sceneWindow;

%% Try moving the slanted bar in and out of focus
% A note on chromatic aberration:
%   We can render chromatic aberration in the eye by tracing one ray per
%   band of wavelength. The parameter, numCABands determines the number of
%   band we will sample. We will trace a total of numRay x numCABands rays,
%   meaning that the rendering will be ~(numCABands) times slower.
%
% As we move the plane in and out of focus we can see the color fringes
% change due to longitudinal chromatic aberration.
planeDistance = [0.3 0.5 0.8]; % meters

for ii = 1:length(planeDistance)
    myScene = sceneEye('slantedBar', 'planeDistance', planeDistance(ii));
    myScene.name = sprintf('slantedBar_%0.2fm', planeDistance(ii));

    myScene.numRays = 64;
    myScene.resolution = 128;
    myScene.numCABands = 8;

    myScene.accommodation = 1/0.5;
    myScene.pupilDiameter = 4;
    myScene.fov = 3;

    % to reuse an existing rendered file of the correct size, uncomment the
    % parameter provided below.
    oi = myScene.render; %('reuse');

    ieAddObject(oi);
    oiWindow;
end

%% Calculate the MTF
% We can use the ISO12233 standard to calculate the MTF from a slanted bar.
%
% First render the slanted bar. You might want to increase the numRays and
% resolution for less noisy results. With numRays = 256 and resolution =
% 256, and numCABands = 16, this takes roughly 3 min to render on an 8 core
% machine.
myScene = sceneEye('slantedBar', 'planeDistance', 1);
myScene.name = 'slantedBarForMTF';
myScene.accommodation = 1;
myScene.fov = 2;
myScene.numCABands = 8;
myScene.numRays = 256;
myScene.resolution = 256;
% to reuse an existing rendered file of the correct size, uncomment the
% parameter provided below.
oi = myScene.render; %('reuse');

ieAddObject(oi);
oiWindow;

% If you have isetlens-eye ( https://github.com/ISET/isetlens-eye) on your
% path, you can run the following:
%{
[freq, mtf] = calculateMTFfromSlantedBar(oi);
figure();
plot(freq, mtf);
xlabel('Spatial Frequency (cycles/deg)');
ylabel('Contrast Reduction (SFR)');
grid on;
axis([0 60 0 1])
%}

% Otherwise, you can run this, which is essentially what
% calculateMTFfromSlantedBar does.

% Crop the image so we only have the slanted line visible. The ISO12233
% routine will be confused by the edges of the retinal image if we don't
% first crop it.
cropRadius = myScene.resolution / (2 * sqrt(2)) - 5;
oiCenter = myScene.resolution / 2;
barOI = oiCrop(oi, round([oiCenter-cropRadius oiCenter-cropRadius ...
    cropRadius*2 cropRadius*2]));

% Convert to illuminance (resulting in a polychromatic MTF)
barOI = oiSet(barOI, 'mean illuminance', 1);
barImage = oiGet(barOI, 'illuminance');

% Calculate MTF
figure;
deltaX_mm = oiGet(oi, 'sample spacing') * 10 ^ 3; % Get pixel pitch
[results, fitme, esf, h] = ...
    ISO12233(barImage, deltaX_mm(1), [1/3 1/3 1/3], 'none');

% Convert to cycles per degree
% Approximate (assuming a small FOV and an focal length of 16.32 mm)
mmPerDeg = 0.2852;
plot(results.freq * mmPerDeg, results.mtf);
xlabel('Spatial Frequency (cycles/deg)');
ylabel('Contrast Reduction (SFR)');
grid on;
axis([0 60 0 1])