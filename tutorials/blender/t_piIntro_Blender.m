%% Render a pbrt image exported from Blender
%
% Description:
%    This tutorial demonstrates how you can use iset3d to render and modify
%    a scene that was created in Blender.
% 
%    This tutorial uses an image that was exported from Blender and which 
%    is included in the iset3d repository, but you can use your own Blender
%    scene by following the instructions found here: 
%    https://github.com/ISET/iset3d/wiki/Blender
%
%    The wiki page describes some Blender basics, how to export your
%    Blender scene as a pbrt file, and how to set up a folder in iset3d
%    that contains your scene. You can then follow the comments in this
%    tutorial to read, modify and render the scene.
%
%    For a demonstration of how you can add materials to Blender scenes 
%    exported without materials, see:
%    ~/iset3d/tutorials/introduction/t_factoidImages
%
% History:
%   11/27/20  amn  Wrote it, adapted from t_piIntro_scenefromweb.m.
%   11/29/20  dhb  Edited it.
%   04/01/21  amn  Adapted for general parser and assets/materials updates.
%   04/29/21  amn  Adapted for object naming based on object's .ply file name.
%   06/05/21  bw/zly  Were here

%% Initialize ISET and Docker
%
% We start up ISET and check that the user is configured for docker.
clear; close all; ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read scene
%
% Read and parse the pbrt file exported from Blender, and return a
% rendering recipe with the parsed scene information.
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

%% Write scene
% 
% Save the recipe information in a pbrt scene file. 
piWrite(thisR);

%% Render and display
%
% Render the scene, specifiying the 'radiance' render type only.
scene = piRender(thisR,'render type','radiance');

% Name this render and display it.
scene = sceneSet(scene,'name','Blender export');
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
% Print the asset tree structure in the command window.
thisR.show;


%% List the object names and the materials that are assigned to them.

thisR.show('assets materials')


%% Select an object to modify
% 
% Each object in this scene was assigned a branch (its position,
% orientation, and size) and a leaf (its shape and material).
% First, select an object leaf name from the list that was just
% printed in the command window. 
% In this example, we select the object leaf named '027ID_Monkey_O'.
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

%% End