%% t_slantedBarMTF.m
%
% We recommend you go through t_rayTracingIntroduction.m before running
% this tutorial.
%
% This tutorial renders a retinal image of "slanted bar." We can then use
% this slanted bar to estimate the modulation transfer function of the
% optical system.
%
% We also show how the color fringing along the edge of the bar due to
% chromatic aberration. 
%
% Depends on: pbrt2ISET, ISETBIO, Docker, ISET
%
% TL ISETBIO Team, 2017

%% Check ISETBIO and initialize

if piCamBio
    fprintf('%s: requires ISETBio, not ISETCam\n',mfilename); 
    return;
end
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Render a fast image of the slanted bar first

% Create an empty sceneEye object
thisEye = sceneEye('slantedbar');

% Create a simple scene.  It is possible to use any scene recipe.
% thisR = piRecipeDefault('scene name','Simple scene');
% thisR = piCreateSlantedBarScene('planeDepth',0.2);
% thisEye.set('recipe',thisR);

thisEye.set('camera',piCameraCreate('humaneye','lens file','navarro.dat'));
thisEye.set('film resolution',320);
thisEye.set('mm units',false);

thisEye.usePinhole = true;
scene = thisEye.render;
sceneWindow(scene);

%% Now an OI

% We still need to deal with some of the units, I think.
thisEye.usePinhole = false;
oi = thisEye.render;
oiWindow(oi);

%%
% TL had this sceneUnits flag.  Can we make sure that we are always in meters? 
% It looks to me like the 'nodes'
% in the scene planes have values like 40, which probably is interpreted as
% 40 meters.  The intention might have been 40 mm.  Anyway, something like
% that needs easy checking.  Like
% 
%   'thisR.get('asset size',idx)'
%

%}

%}
%{
% How we originally did this.
myScene = sceneEye('slantedBar');
piWrite(myScene.recipe);
[oi, result] = piRender(myScene.recipe,'render type','radiance');
oiWindow(oi);

% This calls loadPbrtScene with some parameters
% ('planeDepth', p.Results.planeDistance, 'eccentricity', p.Results.eccentricity);); % Create a slanted bar at 0.5 meter
%}
%{
% Now set the'planeDistance' to 0.5 meters
thisR = myScene.recipe;                               % This is the slanted bar scene PBRT recipe
thisR = piAssetTranslate(thisR,assetIDX,newPosition); % Set the back plane to its new position
%}

%%
% The slanted bar scene consists of a square plane (1x1 m) that is
% split in half diagonally. The bottom left half is white while the top
% right half is black. By default the plane is placed at [0 0 1] meters,
% but we can change that by given sceneEye an optional 'planeDistance'
% input.
%{
myScene = sceneEye('slantedBar'); % Create a slanted bar at 0.5 meter
myScene.set('mm units',false);
myScene.set('rays per pixel',64);
myScene.set('film resolution',[256 256]); 
myScene.set('accommodation',2);  % Diopters
myScene.set('pupil diameter',3); % mm
%}

% myScene.set('retina semidiam',1);  % mm
% myScene.set('retina radius',12);  % mm
% myScene.get('retina radius','m');  % mm
% myScene.get('retina semidiam','mm');  % mm


%% Try moving the slanted bar in and out of focus
%{
% A note on chromatic aberration:
% We can render chromatic aberration in the eye by tracing one ray per band
% of wavelength. The parameter, numCABands determines the number of band we
% will sample. We will trace a total of numRay x numCABands rays, meaning
% that the rendering will be ~(numCABands) times slower.
% 
% As we move the plane in and out of focus we can see the color fringes
% change due to longitudinal chromatic aberration.

planeDistance = [0.3 0.5 0.8]; % meters
% planeDistance = 0.8;  % Meters
for ii = 1:length(planeDistance)
    
    % myScene = sceneEye('slantedBar');
    
    myScene = sceneEye('slantedBar','planeDistance',planeDistance(ii)); % Create a slanted bar at 0.5 meter

    myScene.name = sprintf('slantedBar_%0.2fm',planeDistance(ii));
    
    myScene.numRays    = 64;
    myScene.resolution = 128;
    myScene.numCABands = 8;
    
    myScene.accommodation = 1/0.5; % Diopters
    myScene.pupilDiameter = 4;     % mm
    myScene.fov = 3;               % deg

    % Not in debug mode, so we have an OI
    oi = myScene.render;
    
    oiWindow(oi);

end
%}
%% Calculate the MTF 
% We can use the ISO12233 standard to calculate the MTF from a slanted bar.

% First render the slanted bar. You might want to increase the numRays and
% resolution for less noisy results. With numRays = 256 and resolution =
% 256, and numCABands = 16, this takes roughly 3 min to render on an 8 core
% machine.

%{
myScene = sceneEye('slantedBar','planeDistance',1);
myScene.name = 'slantedBarForMTF';
myScene.accommodation = 1;
myScene.fov = 2;
myScene.numCABands = 8;
myScene.numRays = 256;
myScene.resolution = 256;
oi = myScene.render;

oiWindow(oi);
%}

%% If you have isetlens-eye ( https://github.com/ISET/isetlens-eye) on your
% path, you can run the following:
% [freq,mtf] = calculateMTFfromSlantedBar(oi);
% figure();
% plot(freq,mtf);
% xlabel('Spatial Frequency (cycles/deg)');
% ylabel('Contrast Reduction (SFR)');
% grid on;
% axis([0 60 0 1])

%%  Otherwise, you can run this, which is essentially what
% calculateMTFfromSlantedBar does.

%{
% Crop the image so we only have the slanted line visible. The ISO12233
% routine will be confused by the edges of the retinal image if we don't
% first crop it.
cropRadius = myScene.resolution/(2*sqrt(2))-5;
oiCenter = myScene.resolution/2;
barOI = oiCrop(oi,round([oiCenter-cropRadius oiCenter-cropRadius ...
    cropRadius*2 cropRadius*2]));

% Convert to illuminance (resulting in a polychromatic MTF)
barOI = oiSet(barOI,'mean illuminance',1);
barImage = oiGet(barOI,'illuminance');

% Calculate MTF
figure;
deltaX_mm = oiGet(oi,'sample spacing')*10^3; % Get pixel pitch
[results, fitme, esf, h] = ISO12233(barImage, deltaX_mm(1),[1/3 1/3 1/3],'none');

% Convert to cycles per degree
mmPerDeg = 0.2852; % Approximate (assuming a small FOV and an focal length of 16.32 mm)
plot(results.freq*mmPerDeg,results.mtf);
xlabel('Spatial Frequency (cycles/deg)');
ylabel('Contrast Reduction (SFR)');
grid on;
axis([0 60 0 1])
%}

%%