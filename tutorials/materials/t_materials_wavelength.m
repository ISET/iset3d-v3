% t_material_wavelength - Control wavelength samples
%
% We illustrate how to change the spectral properties of an asset's material
% three different ways:
% 1) RGB values
% 2) Data from a reflectance file
% 3) Making a reflectance array
%
% See also
%   t_materials.m, tls_materials.mlx, t_assets, t_piIntro*,
%   piMaterialCreate.m
%
%% Initialize
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Create recipe

thisR = piRecipeDefault('scene name', 'coloredCube');

% A low resolution rendering for speed
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',48);
thisR.set('fov',45);
thisR.set('nbounces',5); 

% Show it
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'reference scene');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'rgb');

%% Print a the asset tree and the list of materials in the scene

thisR.assets.print;
thisR.get('material print');

% Knowing the asset and material names are necessary when trying to change
% the properties of an asset's material
% We can see which asset has which material by doing the following:
assetName = '005ID_Cube_O';
matName = thisR.get('asset',assetName,'material name')

%% Print the current properties of a material
% Lets say we wanted to know more about the properties of the Green
% Material. We know it is a material of type uber. We can see what type of
% properties uber materials have by looking it up in piMaterialCreate.m or
% running the following line

thisR.get('material', matName)

% Uber materials have 4 properties that are related to the spectrum: the
% coefficient of diffuse reflection ('ks'), glossy reflection ('ks'),
% specular reflection ('kr'), and specular transimssion ('kt')

% In this example we will only be changing the diffuse reflection, but all
% the properties can be changed using the set/get functions

kd_orig = thisR.get('material', matName, 'kd value')

% kd_orig is a an array containing the RGB values for the Green Material.
% Unsurprisingly, kd_orig = [0 1 0]

%% Changing the reflectivity using RGB values
% First we will change the reflectivity of the Green Material using RGB
% values
thisR.set('material', matName, 'kd value', [0 0 1]);
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change kd from green to blue');
sceneWindow(scene);

%% Change the reflectivity using a reflectance data file
% In the data folder of isetcam, reflectance data files can be found for
% different surfaces

wave = 400:10:700;
tongueRefs = ieReadSpectra('tongue', wave);
% The tongue data has reflectances for 12 subjects, we'll just use subject
% 7's data
thisRef = tongueRefs(:, 7);
ieNewGraphWin;
plotReflectance(wave,thisRef);
 
% Convert the spectral reflectance to PBRT's spd format
spdRef = piMaterialCreateSPD(wave, thisRef);

% Store the spd reflectance as the diffuse reflectance of the material
thisR.set('material', matName, 'kd value', spdRef);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change to Tongue Color');
sceneWindow(scene);

%% Changing reflectivity by creating array

reflectance = ones(size(wave));
reflectance(10:17) = 0.5;
reflectance(22:31) = 0;
ieNewGraphWin;
plotReflectance(wave,reflectance);

% Put it in the PBRT spd format.
spdRef = piMaterialCreateSPD(wave, reflectance);

% Store the reflectance as the diffuse reflectance of the material
thisR.set('material', matName, 'kd value', spdRef);

% see the change
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change kd value using reflectance array');
sceneWindow(scene);
