%% Illustrate object rotation and translation
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
%                   'Cube'.

%% Initialize 
clear; close all; ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read in the base scene
recipe = piRecipeDefault('scene name','coloredCube');

%% Render the original scene first
%
% Set a working/output folder
recipe = recipeSet(recipe,'outputfile',...
    fullfile(piRootPath,'local','coloredCube','coloredCube.pbrt'));

% Write out file and render
piWrite(recipe);
[scene, ~] = piRender(recipe,'version',3);
ieAddObject(scene);
sceneWindow;

%% Rotate the cube
% Rotate 10 degrees clockwise around cube's y-axis

% Loop through all assets. There is only one in this scene and it is called
% 'root'.  We rotate that one.
for ii = 1:length(recipe.assets)
    if strcmp(recipe.assets(ii).name,'root')
        % The rotation is stored in angle-axis format, along the columns.  
        recipe.assets(ii).rotate(1,2) = ...
            recipe.assets(ii).rotate(1,2) + 10;
    end
end

% Write and render
piWrite(recipe);
[scene, ~] = piRender(recipe,'version',3);
ieAddObject(scene);
sceneWindow;

%% Rotate the cube again
%
% Another 10 degrees

% Loop through all assets and rotate the one called "Cube"
for ii = 1:length(recipe.assets)
    if strcmp(recipe.assets(ii).name,'root')
        % The rotation is stored in angle-axis format, along the columns.  
        recipe.assets(ii).rotate(1,2) = ...
            recipe.assets(ii).rotate(1,2) + 10;
    end
end

% Write out file
piWrite(recipe);%
[scene, ~] = piRender(recipe,'version',3);
ieAddObject(scene);
sceneWindow;

%% Now try translating
%
% Move 15 cm along positive x-axis

% Loop through all assets and rotate the one called "Cube"
for ii = 1:length(recipe.assets)
    if strcmp(recipe.assets(ii).name,'root')  
        recipe.assets(ii).position(1) = ...
            recipe.assets(ii).position(1) + 0.15;
    end
end

% Write and render
piWrite(recipe);
[scene, result] = piRender(recipe,'version',3);
ieAddObject(scene);
sceneWindow;
