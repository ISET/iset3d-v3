%% Illustrate object rotation, translation, and scaling
%
% Description:
%    This tutorial shows how you can rotate and translate an object using
%    iset3D. The object here is a cube with different colored sides.
%
% Depends on: ISET3d, Docker, ISET
%
% TL ISETBIO Team, 2017

% History:
%  11/01/2020  dhb  Fix up read so scene is actually read.
%              dhb  The only asset in the scene is called 'root', not
%                   'Cube'.  Turns out we should be looking in the
%                   groupobjs field, not the root field.

%% Initialize 
clear; close all; ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read in the base scene
thisR = piRecipeDefault('scene name','coloredCube');

%% Render the original scene first
%
% Set a working/output folder
thisR = recipeSet(thisR,'outputfile',...
    fullfile(piRootPath,'local','coloredCube','coloredCube.pbrt'));

% Write out file and render
piWrite(thisR);
[scene, ~] = piRender(thisR,'version',3);
ieAddObject(scene);
sceneWindow;

%% Rotate the cube
%
% Rotate 10 degrees clockwise around cube's y-axis

% Loop through all assets and act on the cube.
for ii = 1:length(thisR.assets.groupobjs)
    if strcmp(thisR.assets.groupobjs(ii).name,'Cube')
        % The rotation is stored in angle-axis format, along the columns.  
        thisR.assets.groupobjs(ii).rotate(1,2) = ...
            thisR.assets.groupobjs(ii).rotate(1,2) + 10;
    end
end

% Write and render
piWrite(thisR);
[scene, ~] = piRender(thisR,'version',3);
ieAddObject(scene);
sceneWindow;

%% Rotate the cube again by another 10 degrees
for ii = 1:length(thisR.assets.groupobjs)
    if strcmp(thisR.assets.groupobjs(ii).name,'Cube')
        % The rotation is stored in angle-axis format, along the columns.  
        thisR.assets.groupobjs(ii).rotate(1,2) = ...
            thisR.assets.groupobjs(ii).rotate(1,2) + 10;
    end
end

% Write and render
piWrite(thisR);%
[scene, ~] = piRender(thisR,'version',3);
ieAddObject(scene);
sceneWindow;

%% Now translate
%
% Move cube 15 cm along positive x-axis
for ii = 1:length(thisR.assets.groupobjs)
    if strcmp(thisR.assets.groupobjs(ii).name,'Cube')
        % The rotation is stored in angle-axis format, along the columns.
        thisR.assets.groupobjs(ii).position(1) = ...
            thisR.assets.groupobjs(ii).position(1) + 0.15;
    end
end

% Write and render
piWrite(thisR);
[scene, result] = piRender(thisR,'version',3);
ieAddObject(scene);
sceneWindow;

%% Scale along x-axis
for ii = 1:length(thisR.assets.groupobjs)
    if strcmp(thisR.assets.groupobjs(ii).name,'Cube')
        % The rotation is stored in angle-axis format, along the columns.
        thisR.assets.groupobjs(ii).scale(1) = ...
            thisR.assets.groupobjs(ii).scale(1)*2;
    end
end

% Write and render
piWrite(thisR);
[scene, result] = piRender(thisR,'version',3);
ieAddObject(scene);
sceneWindow;
