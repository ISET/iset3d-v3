%% Demonstrate how to control material properties
%
%
% See also
%   t_assets, t_piIntro*
%

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
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'reference scene');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Print a list of the materials in the scene

thisR.get('material print');

%% Print the material of a particular asset

thisR.assets.show;

assetName = 'figure_3m_material_uber_blue'; 
thisR.get('asset',assetName,'material name')

% This will become a mirror.  For now it is the black surface at the
% ceiling.
assetName = 'mirror_material_mirror';
thisR.get('asset',assetName,'material name')

%% Get a material and check its properties

% Find a material and print its properties
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

%% Now change material color using the RGB format

% Change diffuse reflectance to be green
thisR.set('material', matName, 'kd value', [0 0.5 0]);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change diffuse proerty');
sceneWindow(scene);

%% Assign a new material to the object

% We are going to turn the blue stick figure into a glass figure.
glass = 'newGlass';
newMat = piMaterialCreate(glass, 'type', 'glass');
thisR.set('material', 'add', newMat);

% Find the figure asset
% n = thisR.assets.names;

assetName = 'figure_3m_material_uber_blue';
curName = thisR.get('asset', assetName, 'material name');
disp(['The current material is',curName]);

% We turn it into glass
thisR.set('asset', assetName, 'material name', glass);

%% Render it
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change figure to glass');
sceneWindow(scene);

%% Change the black ceiling material into a mirror
mirror = 'newMirror';

newMat = piMaterialCreate(mirror, 'type', 'mirror');
thisR.set('material', 'add', newMat);

% Find the blackboard
assetName = 'mirror_material_mirror';

curName = thisR.get('asset', assetName, 'material name');

thisR.set('asset', assetName, 'material name', mirror);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change board to mirror');
sceneWindow(scene);

%% Change the mirror to a matte material with spectral reflectance

assetName = 'mirror_material_mirror';

matteName = 'newMatte';
newMatte = piMaterialCreate(matteName, 'type', 'matte');
thisR.set('material', 'add', newMatte);

% Set the spectral reflectance of the matte material to the reflectance of
% the 10th chip in the MCC.  It is very red.
wave = 400:10:700;
mccRefs = ieReadSpectra('macbethChart', wave);
thisRef = mccRefs(:, 10);
ieNewGraphWin;
plotReflectance(wave,thisRef);

% Convert the reflectance to PBRT spd format
spdRef = piMaterialCreateSPD(wave, thisRef);

% Store the spd reflectance as the diffuse reflectance of the newMatte
% material
thisR.set('material', matteName, 'kd value', spdRef);

% Assign material
thisR.set('asset', assetName, 'material name', matteName);

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

%% END
