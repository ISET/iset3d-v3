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
%    exported from Cinema 4D, but to parse and work with the Blender
%    exported pbrt files you need to call functions with _Blender as part
%    of their name.  These functions were written to understand the dialect
%    of pbrt created by the Blender exporter.
%
%    To use your own output from the Blender-to-pbrt exporter:
%    Put the output (a pbrt file and a 'meshes' folder) into a new folder 
%    within the local/scenes directory of your iset3d installation. This 
%    folder will be ignored by github, so it won't be synced up with the 
%    repository. You will be able to point to your new folder and your pbrt 
%    file below. 
%
%    This tutorial is adapted from t_piIntro_scenefromweb.m

% History:
%   11/27/20  amn  Wrote it.
%   12/03/20  amn  Added color change section.
%   12/07/20  amn  Updated the Blender scene.

%% Initialize ISET and Docker
%
% We start up ISET and check that the user is configured for docker.
clear; close all; ieInit;
if ~piDockerExists, piDockerConfig; end

%% Set the input folder name
%
% This is currently set to a folder included in the iset3d repository
% but you can change it to your new folder (as described in heading above).
sceneName = 'BlenderScene';

%% Set name of pbrt file exported from Blender
%
% This is currently set to a pbrt file included in the iset3d repository
% but you can change it to the pbrt file you exported from Blender.
pbrtName = 'BlenderScene'; 

%% Set pbrt file path
%
% This is currently set to the file included in the iset3d repository
% but you can change it to the file path for your exported file.
filePath = fullfile(piRootPath,'data','blender',sceneName);
fname = fullfile(filePath,[pbrtName,'.pbrt']);
if ~exist(fname,'file')
    error('File not found - see tutorial header for instructions'); 
end

%% Read scene
%
% piRead_Blender.m is an edited version of piRead.m
% that can read pbrt files exported from Blender.
exporter = 'Blender';
thisR = piRead_Blender(fname,'exporter',exporter);

%% Change render quality
%
% Decrease the resolution to decrease rendering time.
raysperpixel = thisR.get('rays per pixel');
filmresolution = thisR.get('film resolution');
thisR.set('rays per pixel', raysperpixel/2);
thisR.set('film resolution',filmresolution/2);

%% Save the recipe information
%
% piWrite_Blender.m is an edited version of piWrite.m
% that understands the exporter being set to 'Blender'.
piWrite_Blender(thisR);

%% Render and display
%
% piRender_Blender.m is an edited version of piRender.m
% that understands the exporter being set to 'Blender'.
scene = piRender_Blender(thisR,'render type','radiance');

% Name this render and display it.
scene = sceneSet(scene,'name','Blender export');
sceneWindow(scene);

%% How to perform basic functions with images exported from Blender
%
% The rest of this tutorial is adapted from intro tutorials
% (t_piIntro_simpletransforms.m, t_piIntro_material.m) to demonstrate how 
% to perform some basic functions with images exported from Blender
% (see iset3d/tutorials/introduction for all of the intro tutorials).

%% List the names of the objects in this recipe
%
% You will need to know the names of the objects in your scene to work with
% them below. See the tutorial referenced in the header (on how to use the
% Blender-to-pbrt exporter) for notes on naming your objects in Blender.
fprintf('\nThis recipe contains objects:\n');
for ii = 1:length(thisR.assets.groupobjs)
    fprintf('%s\n',thisR.assets.groupobjs(ii).name);
end
fprintf('\n');
  
%% Translate an object
%
% Move the robot 70 cm along the y-axis.
% Note that this will move the robot in world coordinates. In the Blender
% scene included in this tutorial, the camera was aligned to the world
% coordinates. See the tutorial referenced in the header (on how to use the
% Blender-to-pbrt exporter) for how to set up your camera in Blender.
for ii = 1:length(thisR.assets.groupobjs)
    
    % As you can see in the object name list displayed above, all of the
    % objects that make up the robot contain the string 'Robot'
    % so translate all of the objects that contain that string.
    if piContains(thisR.assets.groupobjs(ii).name,'Robot')
        
        % Translate along the y-axis by adjusting the 2nd position
        % parameter.
        thisR.assets.groupobjs(ii).position(2) = ...
        thisR.assets.groupobjs(ii).position(2) + .7;
    end
end

% Write and render.
piWrite_Blender(thisR);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Translated robot');
sceneWindow(scene);

%% Rotate an object
%
% Rotate the mirror 20 degrees along its y-axis.
for ii = 1:length(thisR.assets.groupobjs)
    if piContains(thisR.assets.groupobjs(ii).name,'Mirror')
        % The rotation is stored in angle-axis format, along the columns.
        thisR.assets.groupobjs(ii).rotate(1,2) = ...
        thisR.assets.groupobjs(ii).rotate(1,2) - 20;
    end
end

% Write and render.
piWrite_Blender(thisR);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Rotated mirror');
sceneWindow(scene);

%% Scale an object
%
% Scale the monkey head along its x-axis.
for ii = 1:length(thisR.assets.groupobjs)
    if strcmp(thisR.assets.groupobjs(ii).name,'Monkey')
        thisR.assets.groupobjs(ii).scale(1) = ...
        thisR.assets.groupobjs(ii).scale(1)*2;
    end
end

% Write and render.
piWrite_Blender(thisR);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Scaled monkey');
sceneWindow(scene);

%% Translate, rotate, and scale an object
%
% Just for fun: move, rotate, and scale the robot's arm
for ii = 1:length(thisR.assets.groupobjs)
    if strcmp(thisR.assets.groupobjs(ii).name,'RobotArmLeft')
        % Translate along the y-axis.
        thisR.assets.groupobjs(ii).position(2) = ...
        thisR.assets.groupobjs(ii).position(2) + .2;
        % Rotate along its x-axis.
        thisR.assets.groupobjs(ii).rotate(1,1) = ...
        thisR.assets.groupobjs(ii).rotate(1,1) + 50;
        % Scale along its y-axis.
        thisR.assets.groupobjs(ii).scale(2) = ...
        thisR.assets.groupobjs(ii).scale(2)*1.5;
    end
end

% Write and render.
piWrite_Blender(thisR);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Modified robot''s arm');
sceneWindow(scene);

%% Change the material of an object
%
% Change the material of the top sphere to 'matte'.

% Get the material list and select the material of the chosen object.
materialList = piMaterialList(thisR);
objectMaterialName = 'SphereTop_material';

% Get the 'matte' material from the library.
%
% The library is always part of any recipe.
% Each field in the library struct is a material.
%
% You can look at the list of available materials in variable
% 'theMaterials' below, and try changing to others as well.
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
    % Assign the cube the 'matte' material.
    fprintf('Changing material to %s\n',desiredMaterial);
    piMaterialAssign(thisR,objectMaterialName,targetMaterial);
else
    fprintf('Cannot find desired material %s, leaving alone\n',desiredMaterial);
end

% Because we changed the material assignment, we need to set the
% 'creatematerials' argument to true.
piWrite_Blender(thisR,'creatematerials',true);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Changed top sphere material to matte');
sceneWindow(scene);

%% Change the color of an object
% 
% Change the color of the top sphere to green.
% This section depends on variables defined in the section above.

% Add a green diffuse component to the 'targetMaterial' defined above 
% (the 'matte' material).
targetMaterial.rgbkd = [0 1 0];

% Assign the cube the revised material.
piMaterialAssign(thisR,objectMaterialName,targetMaterial);

% Because we changed the material assignment, we need to set the
% 'creatematerials' argument to true.
piWrite_Blender(thisR,'creatematerials',true);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Changed top sphere color to green');
sceneWindow(scene);

%% End