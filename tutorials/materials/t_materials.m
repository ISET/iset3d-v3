% t_materials - Control material properties
%
% ********* DEPRECATED
%
% We illustrate how to find the material associated with an asset.  We then
% change the material by replacing it.
%
% We then create a new material and switch the asset to use that material
% instead.
%
% Finally, we delete a material
%
% See also
%   tls_materials.mlx, t_assets, t_piIntro*
%

%% Initialize
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Create recipe

% A low resolution rendering as baseline
thisR = piRecipeDefault('scene name', 'SimpleScene');

thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',48);
thisR.set('fov',45);
thisR.set('nbounces',5); 

% Show it
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'reference scene');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Print a list of the materials in the scene

thisR.get('material print');

%% Print the material of a particular asset

% This is the black surface at the ceiling.  It is supposed to be a mirror,
% but it is not.  Let's check its material name and type.
assetName = '001_mirror_O';
thisR.get('asset',assetName,'material name')
thisR.get('asset',assetName,'material type')

% It has the right name, but the wrong type!!!
% We fix!!! 

%% Change the black ceiling material into a mirror

% Find the name of the material for the mirror
materialName = thisR.get('asset',assetName,'material name');

% This is the wrong material we will replace
oldMat = thisR.get('asset',assetName,'material');

% Create a real mirror
newMat = piMaterialCreate(materialName, 'type', 'mirror');

% Replace the material with a real mirror
thisR.set('material','replace', materialName, newMat);

% Nothing looks changed here
thisR.get('print materials');

% But the actual material properties in the materials list are now correct.
% You can compare olMat and newMat to see they are very different!

%%  Have a look

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change board to mirror');
sceneWindow(scene);

%% Add a new material

% Change the mirror to a matte material with a specific spectral
% reflectance.  Firs, we create a red matte material.
matteName = 'redMatte';
newMatte = piMaterialCreate(matteName, 'type', 'matte');
thisR.set('material', 'add', newMatte);

% Set the spectral reflectance of the matte material to the reflectance of
% the 10th chip in the MCC.  It is very red.
wave = 400:10:700;
mccRefs = ieReadSpectra('macbethChart', wave);
thisRef = mccRefs(:, 10);
ieNewGraphWin;
plotReflectance(wave,thisRef);

% Convert the spectral reflectance to PBRT's spd format
spdRef = piMaterialCreateSPD(wave, thisRef);

% Store the spd reflectance as the diffuse reflectance of the redMatte
% material
thisR.set('material', matteName, 'kd value', spdRef);

% See the new material in the list?
thisR.get('print materials');

% Assign the new material to the asset
thisR.set('asset', assetName, 'material name', matteName);

%% Let's have a look at the red surface

piWrite(thisR);
[scene, res] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Board with spectral reflectance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Delete the unused mirror material

% Some people like to clean things up.  Some don't.
thisR.get('material print');

% Delete uber_blue material
deleteName = 'mirror';
thisR.set('material', 'delete', deleteName);

% Check it's really deleted.
thisR.get('material print');

%% END
