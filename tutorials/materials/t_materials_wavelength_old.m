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

thisR = piLightAdd(thisR,... 
    'type','spot',...
    'light spectrum','equalEnergy',...
    'spectrum scale', 1,...
    'cone angle',20,...
    'cameracoordinate', true);
% thisR = piLightAdd(thisR, 'type', 'point', 'camera coordinate', true);

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

%% Change the material of the cube

% prints the asset tree and material list
thisR.assets.print;
thisR.get('material print');

% Change material to glass
assetName_1 = '004ID_Cube_O';
assetName_2 = '005ID_Cube_O';
assetName_3 = '006ID_Cube_O';
assetName_4 = '007ID_Cube_O';
assetName_5 = '008ID_Cube_O';
assetName_6 = '009ID_Cube_O';
glassName = 'glass';
glass = piMaterialCreate(glassName, 'type', 'glass');
thisR.set('material', 'add', glass);
thisR.get('print materials');

thisR.set('asset', assetName_1, 'material name', glassName);
thisR.set('asset', assetName_2, 'material name', glassName);
thisR.set('asset', assetName_3, 'material name', glassName);
thisR.set('asset', assetName_4, 'material name', glassName);
thisR.set('asset', assetName_5, 'material name', glassName);
thisR.set('asset', assetName_6, 'material name', glassName);
thisR.get('object material')

% Change the cube's scale to better see
assetName = '001_Cube_B';
thisR.set('asset',assetName, 'scale', [2 2 2]);

% Add an environmental light for more interesting spectral responses
fileLight = fullfile(piRootPath,'data','lights','roomLight.mat');
load('roomLight','roomLight')
thisR.lights{1} = roomLight;
if ~exist(fullfile(thisR.get('output dir'),'room.exr'),'file')
    exrFile = which('room.exr');
    copyfile(exrFile,thisR.get('output dir'))
end

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change cube to glass');
sceneWindow(scene);
sceneSet(scene,'render flag','hdr');

%% Changing the reflectivity using RGB values
% First we will change the reflectivity of the Green Material using RGB
% values
thisR.set('material', glassName, 'kr value', [0 0.5 0.2]);
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change kd from green to blue');
sceneWindow(scene);

% %% Rotate Camera to see different view
% thisR = piCameraRotate(thisR,'y rot', -40,'x rot', 40);
% thisR = piCameraTranslate(thisR, 'y shift', -2, 'x shift', 2);
% piWrite(thisR);
% scene = piRender(thisR, 'render type', 'radiance');
% scene = sceneSet(scene, 'name', 'Change sphere to glass');
% sceneWindow(scene);
% sceneSet(scene,'render flag','hdr');
% 
% % Return to original position
% thisR = piCameraRotate(thisR,'y rot', 40, 'x rot', -40);
% thisR = piCameraTranslate(thisR, 'y shift', 2, 'x shift', -2);

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
thisR.set('material', glassName, 'kr value', spdRef);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change to Tongue Color');
sceneWindow(scene);


%% Print the current properties of a material
% Lets say we wanted to know more about the properties of the Green
% Material. We know it is a material of type uber. We can see what type of
% properties uber materials have by looking it up in piMaterialCreate.m or
% running the following line

thisR.get('material', matName)

% Uber materials have 4 properties that are related to the spectrum: the
% coefficient of diffuse reflection ('kd'), glossy reflection ('ks'),
% specular reflection ('kr'), and specular transimssion ('kt')

% In this example we will only be changing the diffuse reflection, but all
% the properties can be changed using the set/get functions

kd_orig = thisR.get('material', matName, 'kd value')

% kd_orig is a an array containing the RGB values for the Green Material.
% Unsurprisingly, kd_orig = [0 1 0]





%% Changing reflectivity by creating array

reflectance = ones(size(wave));
reflectance(10:17) = 0.5;
reflectance(22:31) = 0.2;
ieNewGraphWin;
plotReflectance(wave,reflectance);

% Put it in the PBRT spd format.
spdRef = piMaterialCreateSPD(wave, reflectance);

% Store the reflectance as the diffuse reflectance of the material
thisR.set('material', matName, 'ks value', spdRef);

% see the change
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change ks value using reflectance array');
sceneWindow(scene);

%% Changing ks
thisR.set('material', matName, 'ks value', [0.5 0 0]);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change ks value');
sceneWindow(scene);


