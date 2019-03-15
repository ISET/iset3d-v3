%% t_piSimpleTransforms.m
% rotate an object using ISET3d
%
% Description:
%    This tutorial shows how you can rotate an object using iset3D. The
%    object here is a cube with different colored sides.
%
% Dependencies:
%   ISET3d, Docker, ISET
%
% History:
%    XX/XX/17  TL   ISETBIO Team, 2017
%	 03/14/19  JNM  Documentation pass

%% Initialize 
ieInit;
if ~piDockerExists, piDockerConfig; end

% Determine whether you are working in ISETBio or ISETCam
fprintf('Attempting to execute using %s.\n', piCamBio);

%% Read in the base scene
scenePath = fullfile(piRootPath, 'data', 'V3', 'coloredCube');
sceneName = 'coloredCube.pbrt';

recipe = piRead(fullfile(scenePath, sceneName), 'version', 3);

%% Render the original scene first
% Set a working/output folder
recipe = recipeSet(recipe, 'outputfile', ...
    fullfile(piRootPath, 'local', 'coloredCube', 'coloredCube.pbrt'));

% Write out file
piWrite(recipe);

% to reuse an existing rendered file of the correct size, uncomment the
% parameter key/value pair provided below.
[scene, ~] = piRender(recipe, 'version', 3); %, 'reuse', true);
ieAddObject(scene);
sceneWindow;

%% Rotate the cube 3 times
% Rotate 10 degrees clockwise around cube's y-axis the specified number of
% times requested.
numRotations = 3;
for rot = 1:numRotations
    % Loop through all assets and rotate the one called "Cube"
    for ii = 1:length(recipe.assets)
        if strcmp(recipe.assets(ii).name, 'Cube')
            % Rotation is stored in angle-axis format, along the columns.  
            recipe.assets(ii).rotate(1, 2) = ...
                recipe.assets(ii).rotate(1, 2) + 10;
        end
    end

    % Write out file
    piWrite(recipe);
    % to reuse an existing rendered file of the correct size, uncomment the
    % parameter key/value pair provided below.
    [scene, ~] = piRender(recipe, 'version', 3); %, 'reuse', true);
    ieAddObject(scene);
    sceneWindow;
end

%% Now try translating
% Move 15 cm along positive x-axis
%
% Loop through all assets and rotate the one called "Cube"
for ii = 1:length(recipe.assets)
    if strcmp(recipe.assets(ii).name, 'Cube')  
        recipe.assets(ii).position(1) = ...
            recipe.assets(ii).position(1) + 0.15;
    end
end

% Write out file
piWrite(recipe);

% to reuse an existing rendered file of the correct size, uncomment the
% parameter key/value pair provided below.
[scene, result] = piRender(recipe, 'version', 3); %, 'reuse', true);
ieAddObject(scene);
sceneWindow;
