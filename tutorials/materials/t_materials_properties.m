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

% A low resolution rendering for speed
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',48);
thisR.set('fov',45);
thisR.set('nbounces',5); 

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
assetName = '005ID_Sphere_O';
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

%% Change Matte properties
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

% Get the radiance of an inner and outer section
% Center section
% Draw rectangle in scene window and save position in rect_1
% [~,rect_1] = ieROISelect(scene);
% Convert position to integers
% roi_1 = uint64(rect_1.Position);

% Example rectangle position, this can be used or uncomment above to choose
% your own.
roi_1 = [88,66,22,21];
% Get mean energy in ROI
roiMean_1 = sceneGet(scene, 'roimeanenergy', roi_1);

% Fringe (outer) section
% [~, rect_2] = ieROISelect(scene);
% roi_2 = uint64(rect_2.Position);
roi_2 = [50,74,3,9];
roiMean_2 = sceneGet(scene, 'roimeanenergy', roi_2);

wave = 400:10:700;

ieNewGraphWin;
hold on;
plot(wave, roiMean_1); 
plot(wave, roiMean_2);
grid on;
title('Matte - Sigma = 0');
legend('Center', 'Fringe');
hold off;

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
roiMean_1 = sceneGet(scene, 'roimeanenergy', roi_1);
roiMean_2 = sceneGet(scene, 'roimeanenergy', roi_2);

ieNewGraphWin;
hold on;
plot(wave, roiMean_1); 
plot(wave, roiMean_2);
grid on;
title('Matte - Sigma = 0');
legend('Center', 'Fringe');
hold off;

% Set value of signma to 100, surface will have pure Lambertian reflection
thisR.set('material', 'white', 'sigma value', 100);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance', 'meanluminance', -1);
meanlum = sceneGet(scene, 'meanluminance');
scene = sceneSet(scene, 'meanluminance',meanlum*scale);
scene = sceneSet(scene, 'name', 'Matte: kd = green, sigma=100');
meanlum = sceneGet(scene, 'meanluminance');

sceneWindow(scene);

% Plot the inner and outer regions
roiMean_1 = sceneGet(scene, 'roimeanenergy', roi_1);
roiMean_2 = sceneGet(scene, 'roimeanenergy', roi_2);

ieNewGraphWin; hold on; grid on;
plot(wave, roiMean_1); plot(wave, roiMean_2);
title('Matte - Sigma = 100'); ylim([0 1.5*10^-3])
legend('Center', 'Fringe'); hold off;


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
roiMean_1 = sceneGet(scene, 'roimeanenergy', roi_1);
roiMean_2 = sceneGet(scene, 'roimeanenergy', roi_2);
ieNewGraphWin; hold on; grid on;
plot(wave, roiMean_1); plot(wave, roiMean_2);
title('Uber - kd'); 
legend('Center', 'Fringe'); hold off;

%% Uber Properties: Specular Reflection
% like mirror reflection
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
roiMean_1 = sceneGet(scene, 'roimeanenergy', roi_1);
roiMean_2 = sceneGet(scene, 'roimeanenergy', roi_2);
ieNewGraphWin; hold on; grid on;
plot(wave, roiMean_1); plot(wave, roiMean_2);
title('Uber - kd,kr'); 
legend('Center', 'Fringe'); hold off;

%% Uber Properties: Glossy Reflection
% midway between kd and kr, distribution at angle
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
roiMean_1 = sceneGet(scene, 'roimeanenergy', roi_1);
roiMean_2 = sceneGet(scene, 'roimeanenergy', roi_2);
ieNewGraphWin; hold on; grid on;
plot(wave, roiMean_1); plot(wave, roiMean_2);
title('Uber - kd,kr,ks');
legend('Center', 'Fringe'); hold off;

% Roughness Parameter: run this line 2 times, once with the value =0 and
% once with the value =0.01
%thisR.set('material', uberName, 'roughness value', []);

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

% Plot the radiance of the tongue data to compare to our results
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
roiMean_1 = sceneGet(scene, 'roimeanenergy', roi_1);
roiMean_2 = sceneGet(scene, 'roimeanenergy', roi_2);
ieNewGraphWin; hold on; grid on;
plot(wave, roiMean_1); plot(wave, roiMean_2);
title('Plastic - kd'); ylim([0 16]*10^-4);
legend('Center', 'Fringe', 'Location', 'SouthEast'); hold off;

%% Plastic Properties: Glossy Spectral Reflectance
% Change ks value by making own spectral array to get green-blue color
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
roiMean_1 = sceneGet(scene, 'roimeanenergy', roi_1);
roiMean_2 = sceneGet(scene, 'roimeanenergy', roi_2);
ieNewGraphWin; hold on; grid on;
plot(wave, roiMean_1); plot(wave, roiMean_2);
title('Plastic - kd,ks'); ylim([0 16]*10^-4);
legend('Center', 'Fringe','Location','SouthEast'); hold off;


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

wave = 400:10:700;
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

roiMean_1 = sceneGet(scene, 'roimeanenergy', roi_1);
roiMean_2 = sceneGet(scene, 'roimeanenergy', roi_2);
ieNewGraphWin; hold on; grid on;
plot(wave, roiMean_1); plot(wave, roiMean_2);
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

roiMean_1 = sceneGet(scene, 'roimeanenergy', roi_1);
roiMean_2 = sceneGet(scene, 'roimeanenergy', roi_2);
ieNewGraphWin; hold on; grid on;
plot(wave, roiMean_1); plot(wave, roiMean_2);
title('Glass - kt,kr'); 
legend('Center', 'Fringe','Location','NorthWest'); hold off;


%% Add an uber sphere
% 2 spheres (1 matte material, 1 glass with transmissivity) with sky map,
% have light go through glass sphere and reflect on one side of matte
% sphere
% tune parameters, keep matte reflection in the middle, glass
% transmissivity high
thisAsset = thisR.get('asset', assetName);
% duplicating the original asset
newAsset2 = thisAsset;
newAsset2.name = 'Sphere2';
parent = thisR.get('asset parent', thisAsset);
thisR.set('asset',parent.name,'add',newAsset2);
thisR.assets.print;

% change material of second sphere
thisR.set('asset', newAsset2.name, 'material name', 'uber');
% thisR.set('material', 'white', 'kd value', matte_kd_orig);
% thisR.set('material', 'white', 'sigma', 0);

%thisR.set('material', glassName, 'kr value', []);
% change fov to see both spheres
thisR.set('fov',90);

% translate spheres
% translate translates from object space, if rotate sphere the xyz axis
% change; world translate makes the new branch higher so when a rotation is
% added, the translation is taken into account
[~,translateBranch] = thisR.set('asset', thisAsset.name, 'world translate', [150, 0, 150]); 
[~,translateBranch] = thisR.set('asset', newAsset2.name, 'world translate', [300, 0, 0]);

thisR.assets.print;

piWrite(thisR);

scene = piRender(thisR, 'render type', 'radiance','meanluminance', -1);
scene = sceneSet(scene, 'name', 'Translation');
sceneWindow(scene);