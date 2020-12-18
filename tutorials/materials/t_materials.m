%% Create a new material

%% Initialize
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Create recipe
thisR = piRecipeDefault('scene name', 'SimpleScene');

%% A low resolution rendering as baseline
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

piWrite(thisR);
[scene, res] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'reference scene');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Print material list
thisR.get('material print');

%% Get a material and check its properties

% Find this material
matName = 'uber_blue';
thisMat = thisR.get('material', matName)

% Check roughness
roughness = thisR.get('material', matName, 'roughness')

% Check diffuse property
kd = thisR.get('material', matName, 'kd')

% Check specular reflection property
ks = thisR.get('material', matName, 'ks')

% Check mirror reflection property
kt = thisR.get('material', matName, 'kr')

% Check the value of property kd
kdVal = thisR.get('material', matName, 'kd value')

% Check property type
kdType = thisR.get('material', matName, 'kd type')

%% Now change material color

% Change diffuse property
thisR.set('material', matName, 'kd value', [0 0.5 0]);

piWrite(thisR);
[scene, res] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change diffuse proerty');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Assign a new material to the object
glass = 'newGlass';
newMat = piMaterialCreate(glass, 'type', 'glass');
thisR.set('material', 'add', newMat);

% Find the figure asset
% n = thisR.assets.names;

assetName = 'figure_3m_material_uber_blue';

curName = thisR.get('asset', assetName, 'material name');

thisR.set('asset', assetName, 'material name', glass);

piWrite(thisR);
[scene, res] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change figure to glass');

sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Change the blackboard to a mirror
mirror = 'newMirror';

newMat = piMaterialCreate(mirror, 'type', 'mirror');
thisR.set('material', 'add', newMat);

% Find the blackboard
assetName = 'mirror_material_mirror';

curName = thisR.get('asset', assetName, 'material name');

thisR.set('asset', assetName, 'material name', mirror);

piWrite(thisR);
[scene, res] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change board to mirror');

sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Change the mirror to a matte material with spectral reflectance
matte = 'newMatte';
newMatte = piMaterialCreate(matte, 'type', 'matte');
thisR.set('material', 'add', newMatte);

% Set a spectral reflectance to the matte material.
wave = 400:10:700;
mccRefs = ieReadSpectra('macbethChart', wave);
thisRef = mccRefs(:, 10);

% Make reflectance have PBRT spd format
spdRef = piMaterialCreateSPD(wave, thisRef);
thisR.set('material', matte, 'kd value', spdRef);

% Assign material
thisR.set('asset', assetName, 'material name', matte);

piWrite(thisR);
[scene, res] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Board with spectral reflectance');

sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Delete material that is not used
thisR.get('material print');

% Delete uber_blue material
deleteName = 'uber_blue';
thisR.set('material', 'delete', deleteName);

% Check it's really deleted.
thisR.get('material print');
