%% t_assets
%
% Introduction to the assets organization.
%
% The assets are now stored in ISET3d using a tree structure. Each node in
% the tree has a unique name.  This tutorial illustrates how to get
% information about the nodes and to set their properties.
%
% Assets can be objects or lights.  The reason we include lights in the
% assets is because lights can be part of an object, such as the head lamp
% of a car, or a candle on a Menorah. 
%
% The asset tree includes information about (a) position and orientation,
% (b) material, and (c) shape of the asset.  The position and orientation
% information is stored in the branches of the tree, and these values are
% inherited by everything below that branch.  The shape information and
% material properties are stored at the leaf of the tree.
%
%
% See also
%   t_assetsMotion.m


%% Set up a simple scene as an example
ieInit;

if ~piDockerExists, piDockerConfig; end

%% The assets slot in the recipe is a tree

thisR = piRecipeDefault('scene name', 'SimpleScene');

thisR.assets

% You can display the assets tree structure in the command window.

str = thisR.assets.print;

% TODO:  Create an option to print the str in a window, not the command
% line.
% T = thisR.assets.show;
%
%% Here is an example retrieving one of the assets

% You do not need to include the prepended XXXID_ part of the object.
thisR.get('asset','sky')

% But you can
thisR.get('asset','002ID_sky')

% Or just the node number
thisR.get('asset',2)

% You can also retrieve the properties of an object
thisR.get('asset','sky','position')

%% Here is a low resolution rendering of the scene as baseline

% We set a low resolution for speed.  We are going to manipulate the assets
% in what follows.
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

piWrite(thisR);

scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'reference scene');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Manipulate the front figure

% This is a leaf asset describing the blue man in the SimpleScene
thisAsset = 'figure_3m_material_uber_blue'; 

% This places a new branch node representating a rotation just above the
% named leaf asset.  The rotation is (x,y,z) in degrees.  We are rotating
% around the z-axis in this case.
thisR = thisR.set('asset', thisAsset, 'rotate', [0, 0, 45]);

% Notice that there is a new node just above the 015ID_ asset.
thisR.assets.print;

%% Write and render
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Rotation');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Translate

% Here is another one of the figures.  This time, we select asset 16, which
% is a branch that defines the position and rotation of the yellow guy at
% the  back of the scene.
thisAsset = thisR.get('asset',16,'name');

% We add a translation, moving him 2 meters in the z direction.
thisR = thisR.set('asset', thisAsset, 'translate', [0, 0, -2]);

% This time the new branch is below the branch we selected, but above the
% leaf (017ID_...uber) representing the asset shape.
thisR.assets.print;

%% Write and render
piWrite(thisR);

scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Translation');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Add a copy of an existing object

% We want a copy asset with new name function
thisAsset = 'figure_3m_material_uber_blue'; 

newAsset = thisR.get('asset',thisAsset);
newAsset.name = 'blueGuy2';

% Add the asset, but notice we need the parent
parent = thisR.get('asset',thisAsset,'parent');
thisR.set('asset',parent.name,'add',newAsset);

thisR.assets.print;

thisR.set('asset',newAsset.name,'rotate',[0 0 -45]);
thisR.set('asset',newAsset.name,'translate',[1 0 0]);
thisR.assets.print;

%%
piWrite(thisR);

scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'blueguy2');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');


%% Delete an existing object

thisAsset = 'figure_3m_material_uber_blue'; 

thisR.set('asset',thisAsset,'delete');

thisR.assets.print;

%%
piWrite(thisR);

[scene, results] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'blueguy2');
sceneWindow(scene);
scene = sceneSet(scene, 'render flag', 'hdr');

%% Let's make one of the assets glow:  we turn it into an area light

% Create a new area light with D65 spectral power distsribution
areaLight = piLightCreate('type', 'area');
lightName = 'D65';
areaLight = piLightSet(areaLight, [], 'lightspectrum', lightName);
areaLight = piLightSet(areaLight, [], 'spectrum scale', 3e-1);

% This is the red sphere at the back
thisAsset = thisR.get('asset',18,'name');

% This converts the sphere asset into a glowing D65 ball.  Notice that it
% did not add any new nodes.  It simply changed the properties of the
% sphere.
thisR = thisR.set('asset', thisAsset, 'obj2light', areaLight);

thisR.assets.print;
% T = thisR.assets.show;


%% Write and render
piWrite(thisR);

scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Obj2Arealight');
sceneWindow(scene);
scene = sceneSet(scene, 'render flag', 'hdr');


%% Now let's get material information from asset and make some changes
% We are ignoring this now until the material sets/gets are finished.
%
%{
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
%}

%% Add motion assetTwo
%{
thisR = thisR.set('asset', assetNameTwo, 'motion',...
                    'rotation',[0, 0, 10], 'translation', [0, 0, -0.1]);

% Write and render
piWrite(thisR);

[scene, results] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Motion');
sceneWindow(scene);
scene = sceneSet(scene, 'render flag', 'hdr');
%}
