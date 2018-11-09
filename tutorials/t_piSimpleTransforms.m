%% t_slantedBarMTF.m
%
% This tutorial shows how you can rotate an object using iset3D. The object
% here is a cube with different colored sides. 
%
% Depends on: ISET3d, Docker, ISET
%
% TL ISETBIO Team, 2017

%% Initialize 
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read in the base scene

scenePath = fullfile(piRootPath,'data','V3','coloredCube');
sceneName = 'coloredCube.pbrt';

recipe = piRead(fullfile(scenePath,sceneName),'version',3);

%% Render the original scene first

% Set a working/output folder
recipe = recipeSet(recipe,'outputfile',...
    fullfile(piRootPath,'local','coloredCube','coloredCube.pbrt'));

% Write out file
piWrite(recipe);

[scene, ~] = piRender(recipe,'version',3);
ieAddObject(scene);
sceneWindow;

%% Rotate the cube
% Rotate 10 degrees clockwise around cube's y-axis

% Loop through all assets and rotate the one called "Cube"
for ii = 1:length(recipe.assets)
    if strcmp(recipe.assets(ii).name,'Cube')
        % The rotation is stored in angle-axis format, along the columns.  
        recipe.assets(ii).rotate(1,2) = ...
            recipe.assets(ii).rotate(1,2) + 10;
    end
end

% Write out file
piWrite(recipe);

[scene, ~] = piRender(recipe,'version',3);
ieAddObject(scene);
sceneWindow;

%% Rotate the cube again
% Another 10 degrees

% Loop through all assets and rotate the one called "Cube"
for ii = 1:length(recipe.assets)
    if strcmp(recipe.assets(ii).name,'Cube')
        % The rotation is stored in angle-axis format, along the columns.  
        recipe.assets(ii).rotate(1,2) = ...
            recipe.assets(ii).rotate(1,2) + 10;
    end
end

% Write out file
piWrite(recipe);

[scene, ~] = piRender(recipe,'version',3);
ieAddObject(scene);
sceneWindow;

%% Now try translating
% Move 15 cm along positive x-axis

% Loop through all assets and rotate the one called "Cube"
for ii = 1:length(recipe.assets)
    if strcmp(recipe.assets(ii).name,'Cube')  
        recipe.assets(ii).position(1) = ...
            recipe.assets(ii).position(1) + 0.15;
    end
end

% Write out file
piWrite(recipe);

[scene, result] = piRender(recipe,'version',3);
ieAddObject(scene);
sceneWindow;
