%% Render a pbrt image exported from Blender
%
% Description:
%    A tutorial on rendering a pbrt image that was exported from Blender
%    using the Blender-to-pbrt exporter:
%    https://github.com/stig-atle/io_scene_pbrt

%    A detailed tutorial for users new to Blender 
%    on how to use the Blender-to-pbrt exporter to export Blender images
%    either created by the user or downloaded from the web
%    can be found here: <<<<<INSERT LINK TO GITHUB WIKI HERE>>>>>

%    The current tutorial uses an image that has already been exported from
%    Blender with the method above and which is included in the iset3d
%    repository.
%
%    This tutorial works very similarly to tutorials that operate on scenes
%    exported from Cinema 4D, but to parse and workt with the Blender
%    exported pbrt files you need to call functions with _Blender as part
%    of their name.  These functions were written to understand the dialect
%    of pbrt created by the Blender exporter.
%
%    To use your own output from the Blender-to-pbrt exporter:
%    Put the output (a pbrt file, a 'meshes' folder, and a 'textures' 
%    folder) into a new folder within the local/scenes directory of your 
%    iset3d installation. This folder will be ignored by github, so it 
%    won't be synced up with the repository. You will be able to point to
%    your new folder and your pbrt file below. 
%
%    This tutorial is adapted from t_piIntro_scenefromweb.m

% History:
%   11/xx/20  amn  Wrote it.

%% Initialize ISET and Docker
%
% We start up ISET and check that the user is configured for docker
clear; close all; ieInit;
if ~piDockerExists, piDockerConfig; end

%% Set the input folder name
%
% This is currently set to a folder included in the iset3d repository
% but you can change it to your new folder (as described in heading above)
sceneName = 'BlenderScene';

%% Set name of pbrt file exported from Blender
%
% This is currently set to a pbrt file included in the iset3d repository
% but you can change it to the pbrt file you exported from Blender
pbrtName = 'BlenderScene'; 

%% Set pbrt file path
%
% This is currently set to the file included in the iset3d repository
% but you can change it to the file path for your exported file
filePath = fullfile(piRootPath,'data','blender',sceneName);
fname = fullfile(filePath,[pbrtName,'.pbrt']);
if ~exist(fname,'file')
    error('File not found - see tutorial header for instructions'); 
end

%% Read scene
%
% piRead_Blender.m is an edited version of piRead.m
% that can read pbrt files exported from Blender
exporter = 'Blender';
thisR = piRead_Blender(fname,'exporter',exporter);


%% Save the recipe information
%
% piWrite_Blender.m is an edited version of piWrite.m
% that understands the exporter being set to 'Blender'
piWrite_Blender(thisR);

%% Render and display
%
% piRender_Blender.m is an edited version of piRender.m
% that understands the exporter being set to 'Blender'
scene = piRender_Blender(thisR,'render type','radiance');

% Name this render and display it
scene = sceneSet(scene,'name','Blender export');
sceneWindow(scene);

%% How to perform basic functions with images exported from Blender
%
% The rest of this tutorial is adapted from two of the intro tutorials
% (t_piIntro_simpletransforms.m, t_piIntro_material.m) to demonstrate how
% to perform some basic functions with images exported from Blender
% (see iset3d/tutorials/introduction for all of the intro tutorials)

%% Change render quality
%
% This is a low resolution for speed 
thisR.set('rays per pixel',64);
thisR.set('film resolution',[400 300]);

%% List the objects in this recipe
fprintf('\nThis recipe contains objects:\n');
for ii = 1:length(thisR.assets.groupobjs)
    fprintf('%s\n',thisR.assets.groupobjs(ii).name);
end
fprintf('\n');
  
%% Rotate an object
%
% Rotate the monkey head (Suzanne) 60 degrees along the head's x-axis.
% You have to know that the name of this object is 'Suzanne', which is
% something you'd figure out as part of understanding the blender scene.
% Same with names of other objects below.

% Loop through all assets and act on Suzanne
for ii = 1:length(thisR.assets.groupobjs)
    if piContains(thisR.assets.groupobjs(ii).name,'Suzanne')
        % The rotation is stored in angle-axis format, along the columns.
        thisR.assets.groupobjs(ii).rotate(1,1) = ...
            thisR.assets.groupobjs(ii).rotate(1,1) + 60;
    end
end

% Write and render
piWrite_Blender(thisR);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Rotate Suzanne');
sceneWindow(scene);

%% Translate an object
%
% Move the sphere along the sphere's negative x-axis.  Again, you 
% need to know the name of the object is 'sphere'.
for ii = 1:length(thisR.assets.groupobjs)
    if piContains(thisR.assets.groupobjs(ii).name,'sphere')
        % Do this by adjusting position
        thisR.assets.groupobjs(ii).position(1) = ...
            thisR.assets.groupobjs(ii).position(1) - 1.1;
    end
end

% Write and render
piWrite_Blender(thisR);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Translate sphere');
sceneWindow(scene);

%% Scale an object
%
% Scale the 'Cube' along the its z-axis
for ii = 1:length(thisR.assets.groupobjs)
    if piContains(thisR.assets.groupobjs(ii).name,'Cube')
        thisR.assets.groupobjs(ii).scale(3) = ...
            thisR.assets.groupobjs(ii).scale(3)*1.5;
    end
end

% Write and render
piWrite_Blender(thisR);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Scale cube');
sceneWindow(scene);

%% Move the camera farther away
%
% This works if we set object distance, but not if
% we set camera position directly.
distance = thisR.get('object distance');
thisR.set('object distance',distance*3);

% Write and render
piWrite_Blender(thisR);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Move camera farther away');
sceneWindow(scene);

%% Change the material of an object
%
% Change the material of the cube to 'matte'

% Get the material list
materialList = piMaterialList(thisR);

% Get the full name of the cube's material
objectName = 'Cube';
objectidx  = piContains(materialList,objectName);
objectLine = materialList{objectidx};
openidx  = strfind(objectLine,objectName);
closeidx = strfind(objectLine,':');
objectMaterialName = objectLine(openidx:closeidx(2)-1);

% Get the 'matte' material from the library
%
% The library is always part of any recipe,
% each field in the library struct is a material.
%
% You can look at list of available materials in variable
% theMaterials below, and try changing to others as well.
desiredMaterial = 'matte';
theMaterials = fieldnames(thisR.materials.lib);
targetMaterial = [];
for ii = 1:length('theMaterials')
    if (strcmp(theMaterials{ii},desiredMaterial))
        eval(['targetMaterial = thisR.materials.lib.' desiredMaterial ';']);
        break;
    end
end
if (~isempty(targetMaterial))
    % Assign the cube the 'matte' material
    fprintf('Changing material to %s\n',desiredMaterial);
    piMaterialAssign(thisR,objectMaterialName,targetMaterial);
else
    fprintf('Cannot find desired material %s, leaving alone\n',desiredMaterial);
end

% Because we changed the material assignment, we need to set the
% 'creatematerials' argument to true
piWrite_Blender(thisR,'creatematerials',true);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Change cube material to matte');
sceneWindow(scene);

