% t_assets
% Introduction to the new assets tree structure. We parse objects in the
% scene as assets with a tree structure.

%%
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Use simple scene as an example
thisR = piRecipeDefault('scene name', 'SimpleScene');

%% Set render quality
%
% This is a low resolution for speed.
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

%%
% Display the assets structure
disp(thisR.assets.tostring)

%% Write recipe and render
piWrite(thisR);

[scene, results] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'reference scene');
sceneWindow(scene);


%% Now let's get material information from asset and make some changes
assetNameOne = '017ID_figure_6m_material_uber';

% Get a 'branch' node, which has rotation and position info
mat = thisR.get('asset', assetNameOne, 'material');

% Get the material name
matName = mat.namedmaterial;

% TODO: this can be combined together
% Find this material.
matIdx = piMaterialFind(thisR, 'name', matName);
% Set the material with another property
piMaterialSet(thisR, matIdx, 'rgbkd', [0, 1, 0]);

%% Write out and render again 
piWrite(thisR);

[scene, results] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change material');
sceneWindow(scene);

%% Let's make another object an area light

assetNameTwo = '015ID_figure_3m_material_uber_blue'; 

% Create a new area light with D65
newLight = piLightCreate('type', 'area');
lightName = 'D65';
newLight = piLightSet(newLight, [], 'lightspectrum', lightName);
newLight= piLightSet(newLight, [], 'spectrum scale', 3e-3);

thisR = thisR.set('asset', assetNameTwo, 'obj2light', newLight);

%% Write and render
piWrite(thisR);

[scene, results] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Obj2Arealight');
sceneWindow(scene);
scene = sceneSet(scene, 'render flag', 'hdr');

%% Rotate assetTwo

thisR = thisR.set('asset', assetNameTwo, 'rotate', [0, 0, 45]);

% Write and render
piWrite(thisR);

[scene, results] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Rotation');
sceneWindow(scene);
scene = sceneSet(scene, 'render flag', 'hdr');

%% Translate assetOne
thisR = thisR.set('asset', assetNameOne, 'translate', [0, 0, -2]);

% Write and render
piWrite(thisR);

[scene, results] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Translation');
sceneWindow(scene);
scene = sceneSet(scene, 'render flag', 'hdr');

%% Add motion assetTwo
thisR = thisR.set('asset', assetNameTwo, 'motion',...
                    'rotation',[0, 0, 10], 'translation', [0, 0, -0.1]);

% Write and render
piWrite(thisR);

[scene, results] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Motion');
sceneWindow(scene);
scene = sceneSet(scene, 'render flag', 'hdr');