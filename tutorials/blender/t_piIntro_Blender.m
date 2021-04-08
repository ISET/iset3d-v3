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

%    The wiki page above will show you some Blender basics, how to export
%    your Blender scene as a pbrt file, and how to set up a folder in
%    iset3d that contains your scene. You will then need to follow the
%    comments in the tutorial below to modify this script for your scene.
%
%    For a demonstration of how you can add materials to Blender scenes 
%    exported without materials, see:
%    ~/iset3d/tutorials/introduction/t_factoidImages
%
% History:
%   11/27/20  amn  Wrote it, adapted from t_piIntro_scenefromweb.m.
%   11/29/20  dhb  Edited it.
%   04/01/21  amn  Adapted for general parser and assets/materials updates.

%% Initialize ISET and Docker
%
% We start up ISET and check that the user is configured for docker.
clear; close all; ieInit;
if ~piDockerExists, piDockerConfig; end

%% Set the input folder name
%
% This is currently set to a folder included in the iset3d repository
% but you can change the name to the name of your own folder, which you 
% can set up as described at: https://github.com/ISET/iset3d/wiki/Blender
sceneName = 'BlenderScene';

%% Set name of pbrt file exported from Blender
%
% This is currently set to a pbrt file included in the iset3d repository
% but you can change the file name to the name of your own scene.
pbrtName = 'BlenderScene'; 

%% Set pbrt file path
%
% This is currently set to the file included in the iset3d repository
% (which is located in ~/iset3d/data/blender/BlenderScene) but you can
% change it to the file path for your scene.
filePath = fullfile(piRootPath,'data','blender',sceneName);
fname = fullfile(filePath,[pbrtName,'.pbrt']);
if ~exist(fname,'file')
    error('File not found - see tutorial header for instructions'); 
end

%% Read scene
%
% Read and parse the pbrt file exported from Blender, and return a
% rendering recipe with the parsed scene information.
thisR = piRead(fname);

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
sceneSet(scene,'gamma',0.5);

%% Modify the scene
%
% Next, we will demonstrate how you can modify a Blender scene in iset3d by
% performing one simple modification. See the other iset3d tutorials for 
% detailed instructions on making various modifications.

%% Get the names of the objects in the scene
%
% Print the asset tree structure in the command window.
thisR.assets.print;

%% Select an object to modify
% 
% The objects were assigned names based on their order (e.g., 002ID__B).
% Naming based on the object names in Blender is pending. For now, we will
% look at the pbrt file itself to find that the Monkey is the 13th object
% listed in the pbrt file. Each object in this scene was assigned a branch
% (its position, orientation, and size) and a leaf (its shape and 
% material). The naming began with '002' and a name was given to each 
% branch (for example, the first object's branch name is 002ID__B) and each
% leaf (for example, the first object's leaf name is 003ID__O). Therefore,
% the name of the Monkey object's branch (its position, orientation, and 
% size) is: 026ID__B
assetName = '026ID__B';

%% Move the Monkey object
%
% Here we translate the Monkey object's position 1 meter in the negative x
% direction.
[~,translateBranch] = thisR.set('asset', assetName, 'translate', [-1, 0, 0]);

%% Write, render, and display
% 
% Write the scene.
piWrite(thisR);

% Render and display.
scene = piRender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Translated monkey');
sceneWindow(scene);

%% End