% t_assets
% Introduction to the new assets tree structure. We parse objects in the
% scene as assets with a tree structure.

%%
ieInit;

%% Use simple scene as an example
thisR = piRecipeDefault('scene name', 'SimpleScene');

% Use a smaller rays per pixel for faster rendering 
thisR.set('raysperpixel', 8);

% Display the assets structure
disp(thisR.assets.tostring)

piWrite(thisR);

[scene, results] = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);

%% Now let's get material information from asset and make some changes

% Get a 'node' node, which has rotation and position info
assetId = piAssetFind(thisR, 'name', 'figure_6m');

% Get its child 'object' node id, which has surface geometry and material
thisAssetID = piAssetGet(thisR, assetId, 'children');

% Check the material of this asset
mat = piAssetGet(thisR, thisAssetID, 'material');

% Get the material name
matName = mat.namedmaterial;

% Find this material.
matIdx = piMaterialFind(thisR, 'name', matName);

% Set the material with another property
piMaterialSet(thisR, matIdx, 'rgbkd', [0, 1, 0]);

piWrite(thisR);

[scene, results] = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);

%% Let's make another object an area light
assetTwoID = piAssetGet(thisR, piAssetFind(thisR, 'name', 'figure_3m'), 'children');

% Create a new area light with D65
newLight = piLightCreate('type', 'area');
lightName = 'D65';
newLight = piLightSet(newLight, [], 'lightspectrum', lightName);
newLight= piLightSet(newLight, [], 'spectrum scale', 3e-3);

thisR = piAssetObject2Light(thisR, assetTwoID, newLight);

piWrite(thisR);

[scene, results] = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
scene = sceneSet(scene, 'render flag', 'hdr');

