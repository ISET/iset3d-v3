%% Render a pbrt image exported from Blender
%
% Description:
%    A tutorial on rendering a pbrt image that was exported from Blender
%    using the Blender-to-pbrt exporter:
%    https://github.com/stig-atle/io_scene_pbrt

%    A tutorial on how to use the Blender exporter can be found here: 
%    https://github.com/ISET/iset3d/wiki/Blender

%    The current tutorial uses an image that was exported from Blender and 
%    which is included in the iset3d repository.

%    To use your own output from the Blender-to-pbrt exporter:
%    Put the output (a pbrt file and a 'meshes' folder) into a new folder 
%    within your iset3d installation: 
%    ~/iset3d/local/scenes/[your new folder]. This folder will be ignored 
%    by github, so it won't be synced up with the repository. You will be 
%    able to point to your new folder and your pbrt file below. 
%
%    This tutorial works very similarly to tutorials that operate on scenes
%    exported from Cinema 4D, but to parse and work with the Blender
%    exported pbrt files you need to call functions with _Blender as part
%    of their name.  These functions were written to understand the dialect
%    of pbrt created by the Blender exporter.
%
%    This tutorial is adapted from t_piIntro_scenefromweb.m

% History:
%   11/27/20  amn  Wrote it.
%   11/29/20  dhb  Edited it.
%   12/03/20  amn  Added color change section.
%   12/07/20  amn  Updated the Blender scene, added texture sections.
%   12/10/20  amn  Added a new texture section, added wiki link.

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
sceneSet(scene,'gamma',0.5);

%% How to perform basic functions with images exported from Blender
%
% The next part of this tutorial is adapted from intro tutorials
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
% Move the mirror 50 cm along the negative x-axis.
% Note that this will move the mirror in world coordinates. In the Blender
% scene included in this tutorial, the camera was aligned to the world
% coordinates. See the tutorial referenced in the header (on how to use the
% Blender-to-pbrt exporter) for how to set up your camera in Blender.
for ii = 1:length(thisR.assets.groupobjs)
    
    % As you can see in the object name list displayed above, all of the
    % objects that make up the mirror contain the string 'Mirror'
    % so you can translate all of the objects that contain that string.
    if piContains(thisR.assets.groupobjs(ii).name,'Mirror')
        
        % Translate along the x-axis by adjusting the 1st position
        % parameter.
        thisR.assets.groupobjs(ii).position(1) = ...
        thisR.assets.groupobjs(ii).position(1) - .5;
    end
end

% Write and render.
piWrite_Blender(thisR);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Translated mirror');
sceneWindow(scene);
sceneSet(scene,'gamma',0.5);

%% Rotate an object
%
% Rotate the monkey head 45 degrees along its y-axis.
for ii = 1:length(thisR.assets.groupobjs)
    if strcmp(thisR.assets.groupobjs(ii).name,'Monkey')
        % The rotation is stored in angle-axis format, along the columns.
        thisR.assets.groupobjs(ii).rotate(1,2) = ...
        thisR.assets.groupobjs(ii).rotate(1,2) - 45;
    end
end

% Write and render.
piWrite_Blender(thisR);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Rotated monkey');
sceneWindow(scene);
sceneSet(scene,'gamma',0.5);

%% Scale an object
%
% Scale the table top along its x-axis.
for ii = 1:length(thisR.assets.groupobjs)
    % Only the table top (and not the table legs, which are separate 
    % objects) will be scaled
    if strcmp(thisR.assets.groupobjs(ii).name,'Table')
        thisR.assets.groupobjs(ii).scale(1) = ...
        thisR.assets.groupobjs(ii).scale(1) * 1.5;
    end
end

% Write and render.
piWrite_Blender(thisR);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Scaled table top');
sceneWindow(scene);
sceneSet(scene,'gamma',0.5);

%% Just for fun, put it all together
%
% Make a happy robot.
for ii = 1:length(thisR.assets.groupobjs)
    % Move all robot-related objects 70 cm up, along the y-axis.
    if piContains(thisR.assets.groupobjs(ii).name,'Robot')
        thisR.assets.groupobjs(ii).position(2) = ...
        thisR.assets.groupobjs(ii).position(2) + .7;
    
        % Translate, rotate, and scale one of the robot's arms.
        if strcmp(thisR.assets.groupobjs(ii).name,'RobotArmLeft')
            % Translate along the y-axis.
            thisR.assets.groupobjs(ii).position(2) = ...
            thisR.assets.groupobjs(ii).position(2) + .2;
            % Rotate along its x-axis.
            thisR.assets.groupobjs(ii).rotate(1,1) = ...
            thisR.assets.groupobjs(ii).rotate(1,1) + 50;
            % Scale along its y-axis.
            thisR.assets.groupobjs(ii).scale(2) = ...
            thisR.assets.groupobjs(ii).scale(2) * 1.5;
        
        % Scale the robot's eyes and mouth.
        elseif piContains(thisR.assets.groupobjs(ii).name,'RobotEye') || ...
                   strcmp(thisR.assets.groupobjs(ii).name,'RobotMouth')
            % Scale along the object's y-axis.
            thisR.assets.groupobjs(ii).scale(2) = ...
            thisR.assets.groupobjs(ii).scale(2) * 2;
        end
    end 
end

% Write and render.
piWrite_Blender(thisR);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Made a happy robot');
sceneWindow(scene);
sceneSet(scene,'gamma',0.5);

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
    % Assign the top sphere the 'matte' material.
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
sceneSet(scene,'gamma',0.5);

%% Change the color of an object
% 
% Change the color of the top sphere to cyan.
% This section depends on variables defined in the section above.

% Add a cyan diffuse component to the 'targetMaterial' defined above 
% (the 'matte' material).
targetMaterial.rgbkd = [0 1 1];

% Assign the top sphere the revised material.
piMaterialAssign(thisR,objectMaterialName,targetMaterial);

% Set the 'creatematerials' argument to true.
piWrite_Blender(thisR,'creatematerials',true);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Changed top sphere color to cyan');
sceneWindow(scene);
sceneSet(scene,'gamma',0.5);

%% How to add textures
%
% The next part of this tutorial demonstrates how to add textures to images
% exported from Blender, because the Blender exporter does not export 
% textures.

%% Add a 3D pbrt texture
% 
% Add the 'wrinkled' texture, which is included in pbrt, to the table
% (other 3D pbrt textures to try below instead of 'wrinkled' are 'fbm', 
% 'marble', and 'windy', among others).

% You will be creating a new texture. Select a name for this texture.
texturename = 'Wrinkled';

% Assign this new texture to the material of each table object (the table
% top and the table legs).
for ii = 1:length(thisR.materials.list)
    if piContains(thisR.assets.groupobjs(ii).name,'Table')
        thisR.materials.list{ii}.stringtype = 'matte';
        thisR.materials.list{ii}.texturekd = texturename;
    end
end

% Set up this new texture in the recipe.
tidx = length(thisR.textures.list);
tidx = tidx + 1;
thisR.textures.list{tidx,1}.name = texturename;
thisR.textures.list{tidx,1}.linenumber = tidx;
thisR.textures.list{tidx,1}.format = 'spectrum';

% The 'wrinkled' texture is included in pbrt (substitute in other 3D pbrt
% textures below).
thisR.textures.list{tidx,1}.type = 'wrinkled';

% Set the 'creatematerials' argument to true.
piWrite_Blender(thisR,'creatematerials',true);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Changed table texture');
sceneWindow(scene);
sceneSet(scene,'gamma',0.5);

%% Add a 2D pbrt texture
% 
% Add the 'checkerboard' texture, which is included in pbrt, to the floor
% (another 2D pbrt texture to try below instead of 'checkerboard' is 'uv').

% You will be creating a new texture. Select a name for this texture.
texturename = 'Checks';

% Assign this new texture to the material of the floor.
for ii = 1:length(thisR.materials.list)
    if strcmp(thisR.assets.groupobjs(ii).name,'Floor')
        thisR.materials.list{ii}.stringtype = 'matte';
        thisR.materials.list{ii}.texturekd = texturename;
    end
end

% Set up this new texture in the recipe.
tidx = length(thisR.textures.list);
tidx = tidx + 1;
thisR.textures.list{tidx,1}.name = texturename;
thisR.textures.list{tidx,1}.linenumber = tidx;
thisR.textures.list{tidx,1}.format = 'spectrum';

% The 'checkerboard' texture is included in pbrt (substitute in other 2D
% pbrt textures below).
thisR.textures.list{tidx,1}.type = 'checkerboard';

% You can specify the texture scaling factors for 2D textures.
thisR.textures.list{tidx,1}.floatuscale = 8;
thisR.textures.list{tidx,1}.floatvscale = 8;

% Set the 'creatematerials' argument to true.
piWrite_Blender(thisR,'creatematerials',true);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Changed floor texture');
sceneWindow(scene);
sceneSet(scene,'gamma',0.5);

%% Modify a texture that is already in the recipe
%
% In the above section, you added a texture to the recipe. You also
% assigned this texture to the material of the floor. Now, you can modify
% that existing texture.

% Modify the 'Checks' texture.
for ii = 1:length(thisR.textures.list)
    if strcmp(thisR.textures.list{ii}.name,'Checks')
        % Specify larger texture scaling factors.
        thisR.textures.list{ii}.floatuscale = 35.1;
        thisR.textures.list{ii}.floatvscale = 35.1;
    end
end

% Set the 'creatematerials' argument to true.
piWrite_Blender(thisR,'creatematerials',true);
scene = piRender_Blender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Changed existing floor texture');
sceneWindow(scene);
sceneSet(scene,'gamma',0.5);

%% End