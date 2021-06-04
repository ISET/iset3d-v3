% t_material_properties - Understand Material Properties
%
% The purpose of this tutorial is to explore the properties of 4 commonly 
% used materials: matte, glass, plastic, and uber. It uses multiple lights
% to showcase how properties affect the image. This tutorial also
% demonstrates how spectral properties of materials can be changed in 2
% ways:
% 1) Assigning RGB values
% 2) Assigning Spectral Reflectance Values
%
% See also
%   t_materials.m, tls_materials.mlx, t_assets, t_piIntro*,
%   piMaterialCreate.m
%
%% Initialize
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Create recipe

thisR = piRecipeDefault('scene name', 'sphere');
thisR.set('light', 'delete', 'all');

%% Set the render quality
% A low resolution rendering for speed
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',48);
thisR.set('nbounces',5); 
thisR.set('fov',45);

%% Add in lights
% Distant Light
distLight = piLightCreate('new dist',...
                           'type', 'distant', ...
                           'spd', [1 1 1],...
                           'specscale float', 10,...
                           'cameracoordinate', true);
thisR.set('light', 'add', distLight);                       

% Environment Light
% An environment light starts from an image, in this case pngExample.png
% The image is then mapped on the inside surface of a sphere. So if you
% were standing inside this sphere, you would see a stretched out version
% of the image all around you. Every point in this space is a pixel, so we
% can construct a scene by tracing the light from the image map to every
% pixel. Then when an object is placed inside of the image map, pbrt knows
% how the light from the image map affects the object.
fileName = 'pngExample.png';
imshow(fileName); % show image map
exampleEnvLight = piLightCreate('field light','type', 'infinite',...
    'mapname', fileName);
exampleEnvLight = piLightSet(exampleEnvLight, 'rotation val', {[0 0 1 0], [-90 1 0 0]});
thisR.set('lights', 'add', exampleEnvLight); 
thisR.get('lights print');

%% Understanding the environment light
% To better visualize what the environment map does, we change the matte
% sphere to a mirror sphere
% Creating mirror material
mirrorName = 'mirror';
mirror = piMaterialCreate(mirrorName, 'type', 'mirror');
thisR.set('material', 'add', mirror);

% Assigning mirror to sphere
assetName = '001_Sphere_O';
thisR.set('asset', assetName, 'material name', mirrorName);

% Change the camera coordinate to better see the environmental light's
% effect
thisR.set('to', [0 0 0]);
thisR.set('from', [-300 0 -300]);
thisR.set('fov', 60);
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'mirror scene');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'rgb');

% Flip camera to confirm mirror is reflecting the scene 
thisR.set('to', [-600 0 -600]);
thisR.set('fov', 140);
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'flipped mirror scene');
sceneWindow(scene);


%% Return to reference scene to explore properties
% Before we begin exploring properties, we must set up our reference scene

thisR.set('asset', assetName, 'material name', 'white');
thisR.set('to', [0 0 -499]);
thisR.set('from', [0 0 -500]);
thisR.set('fov', 60);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance','meanluminance', -1);
scene = sceneSet(scene, 'name', 'reference scene');

% normalize scene luminance so all the following scenes have normalized
% luminances
meanlum = sceneGet(scene, 'meanluminance');
scale = 100/meanlum;
scene = sceneSet(scene, 'meanluminance', meanlum*scale);
sceneWindow(scene);

%% Matte properties: Setting kd using RGB values
% The material type 'matte' has two main properties: the diffuse
% reflectivity (kd) and the sigma parameter (sigma) of the Oren-Nayar model

% We'll start by getting the current the kd value
matte_kd_orig = thisR.get('material', 'white', 'kd value');

% Change value of kd to reflect a green color using RGB values
thisR.set('material', 'white', 'kd value', [0 0.4 0]);

% Set value of sigma to 0, surface will have pure Lambertian reflection
thisR.set('material', 'white', 'sigma value', 0);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance', 'meanluminance', -1);
meanlum = sceneGet(scene, 'meanluminance');
scene = sceneSet(scene, 'meanluminance',meanlum*scale);
scene = sceneSet(scene, 'name', 'Matte: kd = green, sigma=0');
sceneWindow(scene);

% To get the radiance of the sphere, either choose your own rectangles or
% use the saved coordinates below.

% Draw rectangle in scene window and save location first in center and
% second in outer region.
[loc_1,rect_1] = ieROISelect(scene);
centerROI = loc_1;
[loc_2,rect_2] = ieROISelect(scene);
fringeROI = loc_2;

% or use these saved positions
% centerROI = [88 65 25 22];
% fringeROI = [92 25 19 4];


% Plot mean radiance in ROI
radMean_1 = sceneGet(scene, 'roimeanenergy',centerROI);
radMean_2 = sceneGet(scene, 'roimeanenergy',fringeROI);

wave = 400:10:700;
ieNewGraphWin; hold on; grid on;
plot(wave, radMean_1); plot(wave, radMean_2);
xlab = 'Wavelength (nm)';
ylab = 'Radiance (watts/sr/nm/m^2)';
xlabel(xlab); ylabel(ylab);
title('Matte - using RGB values'); 
legend('Center', 'Fringe'); ylim([0 2*10^-3]);
hold off;

%% Matte properties: setting kd using spectral reflectance values

% Change value of kd value to reflect a green color using spectral
% reflectance values
kd_val = zeros(1,length(wave));
kd_val(wave>480 & wave<600)=0.4;
spd = piMaterialCreateSPD(wave, kd_val);
thisR.set('material', 'white', 'kd value', spd);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance', 'meanluminance', -1);
meanlum = sceneGet(scene, 'meanluminance');
scene = sceneSet(scene, 'meanluminance',meanlum*scale);
scene = sceneSet(scene, 'name', 'Matte, spectral ref val');
sceneWindow(scene);

% Get the radiance of an inner and outer section
radMean_1 = sceneGet(scene, 'roimeanenergy', centerROI);
radMean_2 = sceneGet(scene, 'roimeanenergy', fringeROI);

ieNewGraphWin; hold on; grid on;
plot(wave, radMean_1); plot(wave, radMean_2);
xlabel(xlab); ylabel(ylab);
title('Matte - using Spectral Reflectance values');
legend('Center', 'Fringe');
hold off;

%% Matte Properties: Sigma value

% Set value of signma to 100, making the surface rougher
thisR.set('material', 'white', 'sigma value', 100);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance', 'meanluminance', -1);
meanlum = sceneGet(scene, 'meanluminance');
scene = sceneSet(scene, 'meanluminance',meanlum*scale);
scene = sceneSet(scene, 'name', 'Matte: kd = green, sigma=100');


sceneWindow(scene);

% Plot the inner and outer regions
radMean_1 = sceneGet(scene, 'roimeanenergy', centerROI);
radMean_2 = sceneGet(scene, 'roimeanenergy', fringeROI);

ieNewGraphWin; hold on; grid on;
plot(wave, radMean_1); plot(wave, radMean_2);
xlabel(xlab); ylabel(ylab); ylim([0 2*10^-3]);
title('Matte - Sigma = 100');
legend('Center', 'Fringe');
hold off;


%% Set sphere to Uber
% Now we'll explore the properties of uber. 

% Creating the uber material
uberName = 'uber';
uber = piMaterialCreate(uberName, 'type', 'uber');
thisR.set('material', 'add', uber);

% Assigning the uber material to the sphere
thisR.set('asset', assetName, 'material name', uberName);

%% Uber properties: Diffuse reflectivity 

kd_val = 0.1*ones(1,length(wave));
kd_val(wave>500)=0;
spd = piMaterialCreateSPD(wave, kd_val);
thisR.set('material', uberName, 'kd value', spd);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance','meanluminance',-1);
meanlum = sceneGet(scene, 'meanluminance');
scene = sceneSet(scene, 'meanluminance',meanlum*scale);
scene = sceneSet(scene, 'name', 'Uber - kd');
sceneWindow(scene);

% Plot the inner and outer regions
radMean_1 = sceneGet(scene, 'roimeanenergy', centerROI);
radMean_2 = sceneGet(scene, 'roimeanenergy', fringeROI);

ieNewGraphWin; hold on; grid on;
plot(wave, radMean_1); plot(wave, radMean_2);
xlabel(xlab); ylabel(ylab);
title('Uber - kd');
legend('Center', 'Fringe');
hold off;

%% Uber Properties: Specular Reflection

kr_val = zeros(1, length(wave));
kr_val(wave>500 & wave<600) = 1;
spd = piMaterialCreateSPD(wave, kr_val);
thisR.set('material', uberName, 'kr value', spd);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance','meanluminance',-1);
meanlum = sceneGet(scene, 'meanluminance');
scene = sceneSet(scene, 'meanluminance',meanlum*scale);
scene = sceneSet(scene, 'name', 'sphere to uber - kd,kr');
sceneWindow(scene);

% Plot the inner and outer regions
radMean_1 = sceneGet(scene, 'roimeanenergy', centerROI);
radMean_2 = sceneGet(scene, 'roimeanenergy', fringeROI);
ieNewGraphWin; hold on; grid on;
plot(wave, radMean_1); plot(wave, radMean_2);
xlabel(xlab); ylabel(ylab);
legend('Center', 'Fringe'); title('Uber - kd & kr'); 
hold off;

%% Uber Properties: Glossy Reflection

ks_val = ones(1, length(wave));
ks_val(wave<600) = 0;
spd = piMaterialCreateSPD(wave, ks_val);
thisR.set('material', uberName, 'ks value', spd);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance','meanluminance',-1);
meanlum = sceneGet(scene, 'meanluminance');
scene = sceneSet(scene, 'meanluminance',meanlum*scale);
scene = sceneSet(scene, 'name', 'Uber - kd,kr,ks');
sceneWindow(scene);

% Plot the inner and outer regions
radMean_1 = sceneGet(scene, 'roimeanenergy', centerROI);
radMean_2 = sceneGet(scene, 'roimeanenergy', fringeROI);
ieNewGraphWin; hold on; grid on;
plot(wave, radMean_1); plot(wave, radMean_2);
xlabel(xlab); ylabel(ylab);
legend('Center', 'Fringe'); title('Uber - kd, kr, & ks'); 
hold off;


%% Set sphere to plastic
% 'plastic' materials have 2 spectral properties: diffuse reflectivity
% ('kd') and glossy specular reflectivity ('ks')

% Create plastic material
plasticName = 'plastic';
plastic = piMaterialCreate(plasticName, 'type', 'plastic');
thisR.set('material', 'add', plastic);
thisR.set('asset', assetName, 'material name', plasticName);


%% Plastic Properties: diffuse relectivity

% Change kd value using RGB to tongue color
tongueRefs = ieReadSpectra('tongue', wave);
% The tongue data has reflectances for 12 subjects, we'll just use subject
% 7's data
thisRef = tongueRefs(:, 7);
spdRef = piMaterialCreateSPD(wave, thisRef);
thisR.set('material', plasticName, 'kd value', spdRef);

% Plot the reflectance of the tongue data to compare to our results
ieNewGraphWin;
plotReflectance(wave,thisRef);
title('Tongue data');

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance', 'meanluminance',-1);
meanlum = sceneGet(scene, 'meanluminance');
scene = sceneSet(scene, 'meanluminance',meanlum*scale);
scene = sceneSet(scene, 'name', 'Plastic - kd');
sceneWindow(scene);

% Plot the inner and outer regions
radMean_1 = sceneGet(scene, 'roimeanenergy', centerROI);
radMean_2 = sceneGet(scene, 'roimeanenergy', fringeROI);
ieNewGraphWin; hold on; grid on;
plot(wave, radMean_1); plot(wave, radMean_2);
xlabel(xlab); ylabel(ylab); ylim([0 16*10^-4]);
legend('Center', 'Fringe', 'Location', 'SouthEast');
title('Plastic - kd'); hold off;

%% Plastic Properties: Glossy Spectral Reflectance
% Change ks value by making own reflectance array to get green-blue color
ks_val = linspace(1, 0, size(wave,2));
spdRef = piMaterialCreateSPD(wave, ks_val);

% Plot SPD
ieNewGraphWin; hold on; grid on;
plot(wave, ks_val); 
title('Plastic - ks SPD'); 
hold off;

% Store the reflectance as the specular reflectance of the material
thisR.set('material', plasticName, 'ks value', spdRef);

% see the change
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance', 'meanluminance',-1);
meanlum = sceneGet(scene, 'meanluminance');
scene = sceneSet(scene, 'meanluminance',meanlum*scale);
scene = sceneSet(scene, 'name', 'Plastic - kd,ks');
sceneWindow(scene);

% Plot the inner and outer regions
radMean_1 = sceneGet(scene, 'roimeanenergy', centerROI);
radMean_2 = sceneGet(scene, 'roimeanenergy', fringeROI);
ieNewGraphWin; hold on; grid on;
plot(wave, radMean_1); plot(wave, radMean_2);
xlabel(xlab); ylabel(ylab); ylim([0 16*10^-4]);
legend('Center', 'Fringe', 'Location', 'SouthEast');
title('Plastic - kd & ks'); hold off;


%% Set sphere to glass 
% the glass material has 2 spectral properties: specular reflection and
% transmissivity

glassName = 'glass';
glass = piMaterialCreate(glassName, 'type', 'glass');
thisR.set('material', 'add', glass);
thisR.set('asset', assetName, 'material name', glassName);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance', 'meanluminance', -1);
meanlum = sceneGet(scene, 'meanluminance');
scene = sceneSet(scene, 'meanluminance',meanlum*scale);
scene = sceneSet(scene, 'name', 'Glass');
sceneWindow(scene);

%% Glass Properties: Transmissivity

kt_val = zeros(1,length(wave));
kt_val(wave>500)=linspace(0,0.4,20);
spd = piMaterialCreateSPD(wave, kt_val);
thisR.set('material', glassName, 'kt value', spd);

kr_val = zeros(1,length(wave));
spd = piMaterialCreateSPD(wave, kr_val);
thisR.set('material', glassName, 'kr value', spd);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance', 'meanluminance', -1);
meanlum = sceneGet(scene, 'meanluminance');
scene = sceneSet(scene, 'meanluminance',meanlum*scale);
scene = sceneSet(scene, 'name', 'Glass - kt');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'rgb');

radT_1 = sceneGet(scene, 'roimeanenergy', centerROI);
radT_2 = sceneGet(scene, 'roimeanenergy', fringeROI);
ieNewGraphWin; hold on; grid on;
plot(wave, radT_1); plot(wave, radT_2);
xlabel(xlab); ylabel(ylab); ylim([0 1.4*10^-4]);
title('Glass - kt'); 
legend('Center', 'Fringe','Location','NorthWest'); hold off;

%% Glass Properties: Reflectivity

kr_val = 1-kt_val;
spd = piMaterialCreateSPD(wave, kr_val);
thisR.set('material', glassName, 'kr value', spd);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance', 'meanluminance', -1);
meanlum = sceneGet(scene, 'meanluminance');
scene = sceneSet(scene, 'meanluminance',meanlum*scale);
scene = sceneSet(scene, 'name', 'Glass - kt,kr');
sceneWindow(scene);

radMean_1 = sceneGet(scene, 'roimeanenergy', centerROI);
radMean_2 = sceneGet(scene, 'roimeanenergy', fringeROI);
ieNewGraphWin; hold on; grid on;
plot(wave, radMean_1); plot(wave, radMean_2);
xlabel(xlab); ylabel(ylab);
title('Glass - kt & kr'); 
legend('Center', 'Fringe','Location','SouthEast'); hold off;

%% Comparing the reflections with the surrounding
% To compare the sphere's reflections with its surroundings, we'll draw 4
% rectangles: 1) in the top region of the sphere, 2) in the sky, 3) in the
% bottom region of the sphere, and 4) on the ground

[topROI,rect_top] = ieROISelect(scene);
[skyROI,rect_sky] = ieROISelect(scene);
[botROI,rect_bot] = ieROISelect(scene);
[gndROI,rect_gnd] = ieROISelect(scene);

% topROI = [95 25 17 2];
% skyROI = [94 6 19 5];
% botROI = [124 103 12 11];
% gndROI = [148 133 14 12];

rad_top = sceneGet(scene, 'roimeanenergy', topROI);
rad_sky = sceneGet(scene, 'roimeanenergy', skyROI);

ieNewGraphWin; hold on; grid on;
plot(wave, rad_sky); plot(wave, rad_top); plot(wave, radT_1); 
xlabel(xlab); ylabel(ylab);
title('Glass - Sky reflections'); 
legend('Sky','Top','No Reflections','Location','SouthEast'); 
hold off;

rad_bot = sceneGet(scene, 'roimeanenergy', botROI);
rad_gnd = sceneGet(scene, 'roimeanenergy', gndROI);

ieNewGraphWin; hold on; grid on;
plot(wave, rad_gnd); plot(wave, rad_bot); plot(wave, radT_1);
xlabel(xlab); ylabel(ylab);
title('Glass - Ground reflections'); 
legend('Ground','Bottom','No Reflections','Location','SouthEast'); 
hold off;

% END