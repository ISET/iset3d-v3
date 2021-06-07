%%

%%
fname = fullfile(piRootPath,'data','blender','BlenderScene','BlenderScene.pbrt');
newName = piBlender2C4D(fname);
thisR   = piRead(newName);

%% Add light
%
% This scene was exported without a light, so create and add an infinite light.
infiniteLight = piLightCreate('infiniteLight','type','infinite','spd','D65');

thisR.set('light','add',infiniteLight);

%% Change render quality
%
% Decrease the resolution and rays/pixel to decrease rendering time.
raysperpixel = thisR.get('rays per pixel');
filmresolution = thisR.get('film resolution');
thisR.set('rays per pixel', raysperpixel/2);
thisR.set('film resolution',filmresolution/2);

piWrite(thisR);
[scene,result] = piRender(thisR,'render type','radiance');
sceneWindow(scene);

% Change the gamma for improved visibility.
sceneSet(scene,'gamma',0.7);

%% Modify the scene
%
% Next, we will demonstrate how you can modify a Blender scene in iset3d by
% performing one simple modification. See the other iset3d tutorials for 
% detailed instructions on making various modifications.

%% See asset tree
%
% This brings up a window that shows the asset tree structure
thisR.show;

%% List the object names and the materials that are assigned to them.

thisR.show('assets materials')

%% Select an object to modify

% Select the object leaf named '027ID_Monkey_O'.
leafName = '001_Monkey_O';

% The leaf of the object contains its shape and material information.
% We need to get the ID of the branch of the object to manipulate the 
% object's position, orientation, or size.
% The branch node is just above the leaf.
branchID = thisR.get('asset parent id',leafName);

%% Move the Monkey object
%
% Here we translate the Monkey object's position 1 meter in the negative x
% direction.
[~,translateBranch] = thisR.set('asset', branchID, 'translate', [-1, 0, 0]);

%% Write, render, and display
% 
% Write the scene.
piWrite(thisR);

% Render and display.
scene = piRender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Translated Monkey');
sceneWindow(scene);

%% END