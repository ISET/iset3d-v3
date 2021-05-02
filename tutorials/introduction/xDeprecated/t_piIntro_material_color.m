%% How to change the color of an object in a scene
%
% Description: 
%   Shows how to change color of an object in a scene.

% History:
%   11/01/20  an  Wrote from t_piIntro_material\
%   11/01/20  dhb A little cleaning.

%% Initialize ISET and Docker
clear; close all; ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read pbrt files
sceneName = 'simple scene';
thisR = piRecipeDefault('scene name',sceneName);

%% Set render quality
%
% This is a low resolution for speed.
thisR.set('film resolution',[400 300]);
thisR.set('rays per pixel',64);

%% List material library
%
% These all the possible materials. 
mType = piMateriallib;
disp(mType);
thisR.materials.lib

% These are the materials in this particular scene.
piMaterialList(thisR);

%% Write out the pbrt scene file, based on thisR.
thisR.set('fov',45);
thisR.set('film diagonal',10);
thisR.set('integrator subtype','bdpt');
thisR.set('sampler subtype','sobol');
piWrite(thisR);

%% Render
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('Uber %s',sceneName));
sceneWindow(scene);
sceneSet(scene,'render flag','hdr');

%% Change the color of an object

% Select an object in the scene
% The list of objects was displayed above (uncomment the next line to display again)
% piMaterialList(thisR);
%
% The object named 'mirror' is in slot 5 of the list of objects
% (It may be helpful to know that the 'mirror' object is located in the top part of the simple scene
% and that it does not currently have the 'mirror' material - See t_piIntro_material.m 
% for a tutorial that changes the material of the 'mirror' object to 'mirror')
partName = 'mirror';
slotnum  = 5;

% Demonstrates where the material information for each object can be found
%
% Get the material information for each object in the scene
material_per_object = thisR.get('materials');

% Note the material type of the 'mirror' object
currentmaterial = material_per_object{slotnum}.type;

% Note the color of that material (rgb values for the diffuse component)
currentcolor = material_per_object{slotnum}.kd.value;
fprintf('The current material of the mirror object is: %s\n', currentmaterial);
fprintf('The current color of that material is: %.0f %.0f %.0f\n', currentcolor);

% Change the material and material color of the chosen object
%
% Get the 'plastic' material from the library
% The library is always part of any recipe
target = thisR.materials.lib.plastic;

% Select a new color for the diffuse component of the 'plastic' material
target.kd.value = [1 0 0]; % red color

% Assign the 'mirror' object the 'plastic' material with the new color (red)
piMaterialAssign(thisR,partName,target);

% Because we changed the material assignment, we need to set the
% 'creatematerials' argument to true
piWrite(thisR);

%% Render
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('Changed mirror object to have red plastic material'));
sceneWindow(scene);
sceneSet(scene,'render flag','hdr');

%% Change the material and material color of a different object

% The object named 'uber_blue' is in slot 1 of the list of objects 
% (This object is the closer person in the simple scene)
personName = 'uber_blue';

% Select a new color for the diffuse component of the 'plastic' material
target.rgbkd = [0 1 1]; %cyan color

% Assign the 'uber_blue' object the 'plastic' material with the new color (cyan)
piMaterialAssign(thisR,personName,target);

% Write and render
piWrite(thisR);
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('Changed front person to have cyan plastic material'));
sceneWindow(scene);
sceneSet(scene,'render flag','hdr');
