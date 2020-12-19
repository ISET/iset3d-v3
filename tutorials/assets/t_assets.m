%% t_assets
%
% Introduction to the assets and their methods.
%
% The assets are stored in ISET3d using a tree structure. Each node in the
% tree has a unique name and a link to its parent node.  
%
% The asset tree includes information about (a) position and orientation,
% (b) material, and (c) shape of the asset.  This information is stored in
% different types of nodes.
%
% Position, scale and orientation information is stored in the branches of
% the tree. These values are inherited by everything below that branch.
% Shape and material properties are stored at the leafs of the tree.
%
% This tutorial illustrates how to find nodes and their parents, and how to
% adjust the position, rotation, and scale of the objects. A separate
% tutorial will illustrate how to adjust material properties.
%
% Note: Assets can be objects or lights.  We include lights as assets
% because lights can be part of an object, such as the head lamp of a car,
% or a candle on a Menorah.
%
% ISET3d Methods tested here:
%
%   print, translate, rotate, scale, add, delete, obj2light
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
thisR.assets.show;

% thisR.assets.print;
% thisR.assets.findleaves
% thisR.assets.names
% t = thisR.assets.stripID
% str = thisR.assets.tostring

%% Here is an example retrieving one of the assets

% You do not need to include the prepended XXXID_ part of the object.

% Ask for just the asset and you get the struct
thisR.get('asset','sky')

% You can request just the id and prepend the ID.  Goofy, but there it is
thisR.get('asset id','002ID_sky')

% To use the node number and get the struct, work directly with the assets
thisR.assets.get(2)

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
assetName = 'figure_3m_material_uber_blue'; 

% This places a new branch node representating a rotation just above the
% named leaf asset.  The rotation is (x,y,z) in degrees.  We are rotating
% around the z-axis in this case.
thisR.set('asset', assetName, 'rotate', [0, 0, 45]);

% Notice that there is a new node just above the 015ID_ asset.
thisR.assets.print;

%% Write and render

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Rotation');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Translate

% This is the object representing the yellow man
assetName = 'figure_6m_material_uber';

% In this example, we find the branch node that is just above the yellow
% man, representing its position, rotation and such.
thisAsset = thisR.get('asset parent id',assetName);

% We add a translation, moving yellow man 2 meters in the z direction.
thisR.set('asset', thisAsset, 'translate', [0, 0, -2]);

% This time the new branch is below the branch, but above the object (leaf)
% that contains the object shape.
thisR.assets.print;

%% Write and render
piWrite(thisR);

scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Translation');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Scale

% This is the object representing the yellow man
assetName = 'figure_6m_material_uber';

% We scale the size of the yellow man
thisR.set('asset', assetName, 'scale', 1.2);

% This time the new branch is below the branch, but above the object (leaf)
% that contains the object shape.
thisR.assets.print;

%% Write and render
piWrite(thisR);

scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Translation');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');


%% Add a copy of an existing object

% The blue man.
thisAsset = 'figure_3m_material_uber_blue'; 

% Get the blue man that we will modify into a new asset.
newAsset = thisR.get('asset',thisAsset);
newAsset.name = 'blueGuy2';

% We add the asset below the parent of the current blue man. 
parent = thisR.get('asset parent',thisAsset);     % The parent

% Calls the function to insert an asset below a parent.
thisR.set('asset',parent.name,'add',newAsset);    

thisR.assets.print;

thisR.set('asset',newAsset.name,'rotate',[0 0 -45]);
thisR.set('asset',newAsset.name,'translate',[1 0 0]);
thisR.assets.print;

%%  Show the 2nd blue guy

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'blueguy2');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Delete an existing object

thisAsset = 'figure_3m_material_uber_blue'; 
thisR.set('asset',thisAsset,'delete');
thisR.assets.print;

%% And the rotated blue guy is deleted

piWrite(thisR);
[scene, results] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'blueguy2');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Illustrate deleting the translate node.

%% Let's make one of the assets glow:  we turn it into an area light

% Create a new area light with D65 spectral power distsribution
areaLight = piLightCreate('type', 'area');
lightName = 'D65';
areaLight = piLightSet(areaLight, [], 'lightspectrum', lightName);
areaLight = piLightSet(areaLight, [], 'spectrum scale', 3e-1);

% This is the red sphere at the back
assetName = '019ID_Sphere_material_BODY'; 

% This converts the sphere asset into a glowing D65 ball.  Notice that it
% did not add any new nodes.  It simply changed the properties of the
% sphere.
thisR.set('asset', assetName, 'obj2light', areaLight);

thisR.assets.print;

%% Write and render

piWrite(thisR);

scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Obj2Arealight');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% END

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
