%% init
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
thisR = piRecipeDefault('scene name', 'cornell box reference');

%% A low resolution rendering as baseline
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',16);
thisR.set('fov',30);
thisR.set('nbounces',2); 

%% Turn an asset to an object
%{
    % Show 
    thisR.assets.show
%}
% Delete all lights.
piLightDelete(thisR, 'all');

areaLight = piLightCreate('type', 'area');
lightName = 'Tungsten';
areaLight = piLightSet(areaLight, [], 'lightspectrum', lightName);
areaLight = piLightSet(areaLight, [], 'spectrum scale', 1);

assetName = 'Area Light_material_areaLightMat';

thisR.set('asset', assetName, 'obj2light', areaLight);

%% Render
%{
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');
%}

%% Add bunny in the box
bunnyAsset = piAssetLoad('bunny');

% Get parent of the large cube
largeCubeName = 'Cube_Large_material_CubeLarge';
parentAsset = thisR.get('asset parent', largeCubeName);

% Add the bunny under parent node
% thisR.set('asset', parentAsset.name, 'add', bunnyAsset);
thisAsset = thisR.set('asset', 'root', 'add', bunnyAsset);

% thisR.set('asset', largeCubeName, 'delete');
%{
    % Show 
    thisR.assets.show
%}

% Translate the buny a bit
% pos = thisR.get('asset', bunnyAsset.name, 'position')

pos = thisR.get('asset', bunnyAsset.name, 'world position');


posSmallCube = thisR.get('asset', 'Cube_Small_material_CubeSmall', 'world position');
% % Get the rotation of cube
% rotation = thisR.get('asset', parentAsset.name, 'rotate');
% pos = thisR.get('asset', parentAsset.name, 'translation');


% thisR.set('asset', bunnyAsset.name, 'rotate', [0 40.8444 0]);
% R = thisR.set('asset', bunnyAsset.name, 'rotate', [0 45 0]);
% T = thisR.set('asset', bunnyAsset.name, 'translate', [-0.03 -0.07 -0.05]);
% thisR.set('asset', T.name, 'delete')
% thisR.set('asset', bunnyAsset.name, 'translate', [-0.5 0 0]);

%% Add material to bunny
% Create a spectral reflectance of bunny
wave = 400:10:700;
mccRefs = ieReadSpectra('macbethChart', wave);
thisRef = mccRefs(:, 15);

% Convert the reflectance to PBRT spd format
spdRef = piMaterialCreateSPD(wave, thisRef);

bunnyMat = piMaterialCreate('bunnyMat', 'type',...
            'matte', 'kd value', spdRef);
        
thisR.set('material', 'add', bunnyMat);  

% Change material name attached to bunny
thisR.set('asset', bunnyAsset.name, 'material name', bunnyMat.name);
%% Render
piWrite(thisR);
[scene, res] = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');
